extends Node

# this is the generic animal class that all animal types with extend

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in the global player variables
onready var player = get_node("/root/Player_Globals")

# bring in our global action list
onready var global_action_list = get_node("/root/Actions")

# bring in our guild variables/functions
onready var guild = get_node("/root/Guild")

# bring in our items
onready var global_items_list = get_node("/root/Items")

# various hud scenes
onready var hud_selection_list_scn = preload("res://Entities/HUD/Selection_List.tscn")
onready var hud_unit_info_full_scn = preload("res://Entities/HUD/Info Screens/Animal_Info_Full.tscn")
onready var hud_trade_screen_scn = preload("res://Entities/HUD/Unit Actions/Trade_Screen.tscn")

# bring in our signals
onready var signals = get_node("/root/Signal_Manager")

onready var movement_grid_square = preload("res://Entities/Player/Movement_Grid_Square.tscn")

# unit info node
var hud_unit_info_full_node = null

# keep track of the trade screen (if it exists)
var hud_trade_screen_node

# the animal type
var type

# useful boolean for distinguishing between animals and units
var is_animal = true

# the animals position
var unit_pos_x = 0
var unit_pos_y = 0

# the animal's base movement
var base_move = 3

var unit_name = ""

# the animals sprite
var animal_sprite

# keep track of the unit's items
var item_limit = 0 # default

var current_items = [
]

# bring in any shaders that we can use on our unit sprite
onready var unit_spent_shader = preload("res://Sprites/Shaders/spent_unit.tres")

# keep track of whether or not the animal has acted
var has_acted = false

var flying = false

# whether or not the animal is awake
var unit_awake = true

# default bedtime (or ESCAPE time XD)
var bed_time = 21 # 9pm

# default wake-up time (if the animal stays in the party)
var wake_up_time = 8 # 8 AM

var escapes = true # the animal will leave the party at end of day (amed animals are generally single-day use. That's why they're so easy to tame)

var unit_id = 100 # buffer to not conflict with normal units

# a set of Vector2s that are currently eligible for movement (doesn't include distance)
var movement_set = []

# the unit's movement sound
onready var unit_move_sound = preload("res://Music/Unit_Move_Sound.wav")
var unit_move_sound_node = null

# this dict will be used to track the eligible movement tiles, as well as their total distance
var eligible_tile_tracker = {}

# list of coordinates that animals cannot move onto, for various reasons
onready var restricted_coordinates = [
		Vector2(player.guild_hall_x, player.guild_hall_y),
		Vector2(player.guild_hall_x + 1, player.guild_hall_y),
		Vector2(player.guild_hall_x, player.guild_hall_y + 1),
		Vector2(player.guild_hall_x + 1, player.guild_hall_y + 1),
		Vector2(player.guild_hall_x + 1, player.guild_hall_y + 2),
		Vector2(player.guild_hall_x, player.guild_hall_y + 2),
		Vector2(player.guild_hall_x - 1, player.guild_hall_y + 1),
		Vector2(player.guild_hall_x - 1, player.guild_hall_y),
		Vector2(player.guild_hall_x + 2, player.guild_hall_y + 1),
		Vector2(player.guild_hall_x + 2, player.guild_hall_y),
		Vector2(player.guild_hall_x, player.guild_hall_y - 1),
		Vector2(player.guild_hall_x + 1, player.guild_hall_y - 1),
]

# the initial action list for the animal
onready var initial_action_list = [
	global_action_list.COMPLETE_ACTION_LIST.MOVE,
	global_action_list.COMPLETE_ACTION_LIST.ANIMAL_INFO,
]

# a list of actions available to the unit after they've acted
onready var depleted_action_list = [
	global_action_list.COMPLETE_ACTION_LIST.ANIMAL_INFO,
]

onready var current_action_list = initial_action_list.duplicate()

# have 2 layers of potential tiles
onready var tileset_props_l1 = get_tree().get_nodes_in_group(constants.MAP_TILES_GROUP)[0]
onready var tileset_props_l2 = get_tree().get_nodes_in_group(constants.MAP_TILES_GROUP)[1]
onready var hidden_tiles = get_tree().get_nodes_in_group(constants.HIDDEN_TILES_GROUP)[0]

# make sure we have access to the main camera node
onready var camera = get_tree().get_nodes_in_group("Camera")[0]

# called from extended script
func animal_base_init():
	current_action_list = initial_action_list.duplicate()
	
	unit_id += guild.guild_animals.size()
	
	unit_move_sound_node = AudioStreamPlayer.new()
	unit_move_sound_node.stream = unit_move_sound
	unit_move_sound_node.volume_db = constants.GAME_VOLUME
	add_child(unit_move_sound_node)

func set_animal_position(pos):
	unit_pos_x = pos.x
	unit_pos_y = pos.y
	self.global_position = Vector2(pos.x*constants.TILE_WIDTH, 
								pos.y*constants.TILE_HEIGHT)

func set_has_acted_state(state):
	has_acted = state
	
func remove_used_shader():
	# remove the 'used' shader
	animal_sprite.material = null
	
func determine_action_list():
	# first, make sure the animal hasn't already acted
	if (!has_acted):
		# empty the action list
		current_action_list = initial_action_list.duplicate()
		
		# check for 'DEPOT' action
		var guild_spot_id = get_tree().get_current_scene().action_spots.tile_set.find_tile_by_name("Guild_Spot_1")
		if (get_tree().get_current_scene().action_spots.get_cellv(Vector2(unit_pos_x, unit_pos_y)) == guild_spot_id):
			current_action_list.append(global_action_list.COMPLETE_ACTION_LIST.DEPOT)
		
		# determine if we are adjacent to any units (for TRADE action)
		var adjacent_to_unit = false
		for tile in get_tree().get_current_scene().get_cardinal_tiles(self):
			if (player.party.is_unit_here(tile.tile.x, tile.tile.y)):
				adjacent_to_unit = true
				
		if (adjacent_to_unit):
			current_action_list.append(global_action_list.COMPLETE_ACTION_LIST.TRADE_ITEMS)
		
		# sort them
		current_action_list.sort()
		
# allow the unit to select another unit to trade with
func show_trade_selector():
	# change the state (reuse a state)
	player.player_state = player.PLAYER_STATE.SELECTING_TRADE_UNIT
	

	for tile in get_tree().get_current_scene().get_cardinal_tiles(self):
		if (player.party.is_unit_here(tile.tile.x, tile.tile.y)):
			show_movement_grid_square(tile.tile.x, tile.tile.y, true) # allow showing the square on a unit or restricted tile (since we aren't moving here')
		
		
# open the trade screen for the selected unit
func trade_with_unit_at_pos(target_x, target_y):
	# find the unit at this position
	var target_unit = player.party.get_unit_at_coordinates(target_x, target_y)
	if (target_unit != null):
		# we have the unit, now open the trade screen with this specific unit
		open_trade_screen(target_unit)

func open_trade_screen(target_unit):
	player.player_state = player.PLAYER_STATE.SELECTING_ACTION # change to another state so the cursor won't move
	clear_movement_grid_squares()
	
	camera = get_tree().get_nodes_in_group("Camera")[0]
	
	hud_trade_screen_node = hud_trade_screen_scn.instance()
	camera.add_child(hud_trade_screen_node)
	
	# set the active units
	hud_trade_screen_node.set_units(self, target_unit)

# add an item to the unit's inventory
func receive_item(item):
	if (current_items.size() < item_limit):
		global_items_list.add_item_to_unit(self, item)
		
	# otherwise... sorry? You probably shouldn't have gotten here ;) 
		
# quick function for checking if the unit's inventory is full
func is_inventory_full(item_removal_buffer = 0):
	# item removal buffer is used for instances where the unit may be losing items to receive items (i.e. crafting)
	return (current_items.size() - item_removal_buffer >= item_limit)
		
func show_action_list():
	# add a selection list istance to our camera
	var hud_selection_list_node = hud_selection_list_scn.instance()
	camera.add_hud_item(hud_selection_list_node)
	
	# populate the action list with the current list of actions this animal can take
	hud_selection_list_node.populate_selection_list(current_action_list, self)
	
# reset our action list to the initial action list
func reset_action_list():	
	current_action_list = initial_action_list.duplicate()
	
# this function is called once a selection is made in the selection list
func do_action(action):
	match (action):
		global_action_list.COMPLETE_ACTION_LIST.MOVE:
			# enable the animal's movement state
			enable_movement_state()
		global_action_list.COMPLETE_ACTION_LIST.ANIMAL_INFO:
			show_unit_info_full_screen()
			
func show_unit_info_full_screen():
	hud_unit_info_full_node = hud_unit_info_full_scn.instance()
	camera.add_child(hud_unit_info_full_node)
	
	hud_unit_info_full_node.set_unit(self)
	hud_unit_info_full_node.initialize_screen()
			
# we can now enable the animal's movement state + show movement grid
func enable_movement_state():
	# remove any existing movement squares
	clear_movement_grid_squares()
	
	# change the state
	player.player_state = player.PLAYER_STATE.SELECTING_MOVEMENT
	calculate_eligible_tiles()
	
func clear_movement_grid_squares():
	for square in get_tree().get_nodes_in_group(constants.GRID_SQUARE_GROUP):
		square.get_parent().remove_child(square)
		
# calculate all of the eligible tiles the animal can move to, as well as their
# distance. 
func calculate_eligible_tiles():
	# clear out the eligible movement set
	movement_set.clear()
	
	# clear our eligible_tile_tracker (as we are calculating a new set of tiles)
	eligible_tile_tracker = {}
	
	# calculate the eligible tiles + distance, using the flood fill algorithm
	flood_fill(unit_pos_x, unit_pos_y, base_move, {})
	
# flood fill is the best approach for calculating eligible tiles
# it's a recursive function
func flood_fill(foc_x, foc_y, remaining_move, visited_tiles):
	
	# first, let's find our boundaries
	var left_bound = unit_pos_x - (base_move * 2) # accomodate for half-tiles (roads)
	var right_bound = unit_pos_x + (base_move * 2) # accomodate for half-tiles (roads)
	var up_bound = unit_pos_y - (base_move * 2) # accomodate for half-tiles (roads)
	var down_bound = unit_pos_y + (base_move * 2) # accomodate for half-tiles (roads)
	
	# if we're out of remaining move, skip
	if (remaining_move <= 0):
		return
		
	# if we've hit a boundary, skip
	if (foc_x < left_bound || foc_x > right_bound || 
		foc_y < up_bound || foc_y > down_bound):
		return
	
	# otherwise, calculate the distance
	var tile_name_l1 = tileset_props_l1.get_tile_at_coordinates(Vector2(foc_x, foc_y))
	var tile_name_l2 = tileset_props_l2.get_tile_at_coordinates(Vector2(foc_x, foc_y))

	# usually, tiles cost 1 movement. Some tiles may take more movement to move on to.
	# to determine this, we add the movement costs of both layers and subtract it from
	# the remaining movement the unit has.
	var total_tile_cost = 0 # we'll need this later for a*
	
	if (!flying): # if the unit is flying, all tiles should have a cost of '1'
		# subtract the cost of the l1 tiles (if they exist. Else, we DEFINITELY can't move there!)
		if (tile_name_l1 != null):
			var l1_cost = tileset_props_l1.get_movement_cost(tile_name_l1)
			remaining_move -= l1_cost
			total_tile_cost += l1_cost
		else:
			remaining_move -= constants.CANT_MOVE
			total_tile_cost = constants.CANT_MOVE
		
		# subtract the cost of the l2 tiles, if they exist
		if (tile_name_l2 != null):
			var l2_cost = tileset_props_l2.get_movement_cost(tile_name_l2)
			remaining_move -= l2_cost
			total_tile_cost += l2_cost
	else:
		total_tile_cost = 1
		remaining_move -= 1
		
	# if the tile is hidden, we can't move there
	var hidden_tile = (hidden_tiles.get_tile_at_coordinates(Vector2(foc_x, foc_y)) != null)
	if (hidden_tile):
		remaining_move -= constants.CANT_MOVE
		total_tile_cost = constants.CANT_MOVE
		
	# the tile is eligible if the remaining_move is >= 0
	if (foc_x == unit_pos_x && foc_y == unit_pos_y):
		remaining_move = base_move # we're still at the origin tile
	else:
		if (remaining_move >= 0):
			movement_set.push_back(Vector2(foc_x, foc_y))
			show_movement_grid_square(foc_x, foc_y)
	
	# whether or not we need to flood out from this tile
	var initiate_recursion = true
	
	# if we've already been here in this recursion chain, don't recurse (otherwise, StackOverflow)
	if (visited_tiles.get(String(foc_x) + "_" + String(foc_y)) != null):
		if (foc_x != unit_pos_x || foc_y != unit_pos_y):
			initiate_recursion = false
	
	# mark the tile as visited
	var tile_visited = visited_tiles.get(String(foc_x) + "_" + String(foc_y))
	if (tile_visited == null):
		visited_tiles[String(foc_x) + "_" + String(foc_y)] = true

	# mark the distance of the tile
	if (eligible_tile_tracker.get(String(foc_x) + "_" + String(foc_y)) == null):
		eligible_tile_tracker[String(foc_x) + "_" + String(foc_y)] = {
			"pos_x": foc_x,
			"pos_y": foc_y,
			"distance": base_move - remaining_move,
			"tile_cost": total_tile_cost
		}
	else:
		if (eligible_tile_tracker.get(String(foc_x) + "_" + String(foc_y)).distance > base_move - remaining_move):
			# we've got a cheaper path to get to this tile!
			eligible_tile_tracker[String(foc_x) + "_" + String(foc_y)] = {
				"pos_x": foc_x,
				"pos_y": foc_y,
				"distance": base_move - remaining_move,
				"tile_cost": total_tile_cost
			}
			
			# we want to recurse from here, to make sure adjacent tiles are updated
			# with a cheaper distance
			initiate_recursion = true

	if (initiate_recursion):
		flood_fill(foc_x + 1, foc_y, remaining_move, visited_tiles); # tile to the east
		flood_fill(foc_x - 1, foc_y, remaining_move, visited_tiles); # tile to the west
		flood_fill(foc_x, foc_y + 1, remaining_move, visited_tiles); # tile to the south
		flood_fill(foc_x, foc_y - 1, remaining_move, visited_tiles); # tile to the north
	
func show_movement_grid_square(pos_x, pos_y, show_on_unit_and_restricted = false):
	# if there is a unit here, don't show the square
	var unit_here = false
	if (!show_on_unit_and_restricted):
		for unit in player.party.get_all_units():
			if (unit.unit_pos_x == pos_x && unit.unit_pos_y == pos_y):
				unit_here = true
			
	# make sure the tile is not in a restricted location
	var restricted = false
	if (!show_on_unit_and_restricted):
		for restricted_tile in restricted_coordinates:
			if (restricted_tile == Vector2(pos_x, pos_y)):
				restricted = true
	
	if (!unit_here && !restricted):
		var square = movement_grid_square.instance()
		add_child(square)
	
		square.set_square_position(pos_x, pos_y)
	
func move_unit_if_eligible(target_x, target_y):
	var can_move = false
	
	# make sure the unit can actually move to this tile
	for eligible in movement_set:
		if (eligible.x == target_x && eligible.y == target_y):
			can_move = true
	
	# make sure the tile isn't restricted
	var restricted = false
	for restricted_tile in restricted_coordinates:
		if (restricted_tile == Vector2(target_x, target_y)):
			can_move = false
	
	if (!can_move):
		return
		
	clear_movement_grid_squares()
		
	enable_animate_movement_state()
	initiate_movement(a_star(target_x, target_y))
	
# once we've received the path the unit will take, this function will actually move
# the unit based on a timer
func initiate_movement(path):
	var current_time = .001
	var self_pos = self.global_position
	
	for tile in path:
		while (self_pos.x != (tile.pos_x * constants.TILE_WIDTH)):
			var change = 1
			if (self_pos.x > tile.pos_x * constants.TILE_WIDTH):
				change *= -1

			var timer = Timer.new()
			timer.wait_time = current_time
			timer.connect("timeout", self, "animate_movement", 
					[Vector2(self_pos.x + change, self_pos.y), timer])
			# move the tracker variable
			self_pos.x += change
			add_child(timer)
			timer.start()
			current_time += constants.MOVE_ANIM_SPEED # change into a constant
			
		while (self_pos.y != (tile.pos_y * constants.TILE_HEIGHT)):
			var change = 1
			if (self_pos.y > tile.pos_y * constants.TILE_HEIGHT):
				change *= -1
			var timer = Timer.new()
			timer.wait_time = current_time
			timer.connect("timeout", self, "animate_movement", 
					[Vector2(self_pos.x, self_pos.y + change), timer])
			# move the tracker variable
			self_pos.y += change
			add_child(timer)
			timer.start()
			current_time += constants.MOVE_ANIM_SPEED # change into a constant
		
	# after the unit has moved, we need to end their action
	var timer = Timer.new()
	timer.wait_time = current_time - constants.MOVE_ANIM_SPEED
	timer.connect("timeout", self, "end_action", [true, timer])
	add_child(timer)
	timer.start()
	

	# make sure the units coordinates reflect this change in position
	# and do a final teleportation to the global position just to make sure
	set_animal_position(Vector2(path.back().pos_x, path.back().pos_y))
	
func animate_movement(vector2, timer):
	self.global_position = vector2
	timer.stop()
	remove_child(timer)
	
# the pathfinding algorithm for moving the unit to the target
# via the shortest path
func a_star(target_x, target_y):
	# establish our open list
	var open_list = []
	
	# establish our closed list
	var closed_list = []
	
	# our final, shortest path
	var path = []
	
	var start_tile = eligible_tile_tracker.get(String(unit_pos_x) + "_" + String(unit_pos_y))
	
	eligible_tile_tracker[String(target_x) + "_" + String(target_y)].g = 0
	eligible_tile_tracker[String(target_x) + "_" + String(target_y)].h = 0
	eligible_tile_tracker[String(target_x) + "_" + String(target_y)].f = 0
	
	# g = the distance between the current node and the start node
	# h = heuristic - the estimated distance from this node to the target
	# f = g + h
	start_tile.parent = null
	start_tile.g = 0
	start_tile.h = 0
	start_tile.f = 0 # for the start tile, leave f at 0
		
	open_list.push_front(start_tile)

	while open_list.size() > 0:
		var cheapest_tile = open_list[0]
		# god, why can't gdscript keep track of the index
		var cheapest_tile_index = 0
		var index = 0
		
		# grab the tile with the lowest f value
		for tile in open_list:
			if tile.f < cheapest_tile.f:
				cheapest_tile = tile
				cheapest_tile_index = index
			index+=1
		
		# remove the tile from the open_list, and add to the close_list
		open_list.remove(cheapest_tile_index)
		closed_list.push_back(cheapest_tile)
		
		# if we've found the target, congrats!
		if (cheapest_tile.pos_x == target_x && 
			cheapest_tile.pos_y == target_y):
			
			# generate the path
			var current = cheapest_tile
			while current != null:
				path.append({"pos_x": current.pos_x, "pos_y": current.pos_y})
				current = current.parent
			path.invert()
			# we're done!
			break

		# generate a list of children (adjacent nodes)
		var children = []
		
		# tile to the right
		if (eligible_tile_tracker.get(String(cheapest_tile.pos_x+1) + "_" + 
								String(cheapest_tile.pos_y))):
			children.push_back(eligible_tile_tracker.get(String(cheapest_tile.pos_x+1) + "_" + 
								String(cheapest_tile.pos_y)))
		
		# tile to the left
		if (eligible_tile_tracker.get(String(cheapest_tile.pos_x-1) + "_" + 
								String(cheapest_tile.pos_y))):
			children.push_back(eligible_tile_tracker.get(String(cheapest_tile.pos_x-1) + "_" + 
								String(cheapest_tile.pos_y)))
								
		# tile above
		if (eligible_tile_tracker.get(String(cheapest_tile.pos_x) + "_" + 
								String(cheapest_tile.pos_y-1))):
			children.push_back(eligible_tile_tracker.get(String(cheapest_tile.pos_x) + "_" + 
								String(cheapest_tile.pos_y-1)))
		
		# tile below
		if (eligible_tile_tracker.get(String(cheapest_tile.pos_x) + "_" + 
								String(cheapest_tile.pos_y+1))):
			children.push_back(eligible_tile_tracker.get(String(cheapest_tile.pos_x) + "_" + 
								String(cheapest_tile.pos_y+1)))
		
		for child in children:
			
			# if the child is in the closed list, continue
			var hasChild = false
			
			for closed in closed_list:
				if (closed.pos_x == child.pos_x && closed.pos_y == child.pos_y):
					hasChild = true
			
			if (hasChild):
				continue
				
			# make sure that the unit can actually walk here
			if (child.tile_cost > base_move):
				continue

			# keep track of the parent
			var parent = cheapest_tile
			
			# create the f, g, and h values, unless the child is the target
			# in that case, leave the h cost as 0
			var g = cheapest_tile.g + child.tile_cost
			#child.g = child.parent.g + child.tile_cost
			# experiment with different heuristics for more interesting
			# pathfinding
			var h = abs(child.pos_x - target_x) + abs(child.pos_y - target_y)
			if (child.pos_x == target_x && child.pos_y == target_y):
				h = 0
			
			var f = g + h
			
			# if the child is already in the open list,
			# and the current child's g cost is higher than
			# what's in the open list, continue
			var addTileBool = true
			
			for open in open_list:
				if (open.pos_x == child.pos_x && open.pos_y == child.pos_y):
					if (g > open.g):
						addTileBool = false



			# add the child to the open list!
			if (addTileBool == true):
				child.parent = parent
				child.g = g
				child.h = h
				child.f = f
				open_list.push_back(child)

	# return the path
	return path
	
func enable_animate_movement_state():
	player.player_state = player.PLAYER_STATE.ANIMATING_MOVEMENT
	# play movement sound
	unit_move_sound_node.play()
	
# when the action list is cancelled, go back to selecting a tile
func cancel_select_list():
	player.player_state = player.PLAYER_STATE.SELECTING_TILE
	
func end_action(success = false, timer = null):
	if (timer):
		timer.stop()
		remove_child(timer)
	
	if (success): # if the action was successfully completed
		# stop the unit move sound, in case they are moving
		unit_move_sound_node.stop()

		# deplete the unit's action list
		current_action_list = depleted_action_list.duplicate()
	
		# add the 'unit_spent' shader to the unit's sprite
		animal_sprite.material = unit_spent_shader
	
		# the unit has 'acted'
		set_has_acted_state(true)
		player.party.remove_from_yet_to_act(unit_id)
	
	# determine the next player state
	player.determine_next_state()

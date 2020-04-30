extends Node

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in the global player variables
onready var player = get_node("/root/Player_Globals")

# bring in our items
onready var global_items_list = get_node("/root/Items")

# bring in our abilities
onready var global_ability_list = get_node("/root/Abilities")

# bring in our global action list
onready var global_action_list = get_node("/root/Actions")

# bring in our signals
onready var signals = get_node("/root/Signal_Manager")

onready var movement_grid_square = preload("res://Entities/Player/Movement_Grid_Square.tscn")

# various hud scenes
onready var hud_selection_list_scn = preload("res://Entities/HUD/Selection_List.tscn")
onready var hud_unit_info_full_scn = preload("res://Entities/HUD/Unit_Info_Full.tscn")

# bring in any shaders that we can use on our unit sprite
onready var unit_spent_shader = preload("res://Sprites/Shaders/spent_unit.tres")

# have 2 layers of potential tiles
onready var tileset_props_l1 = get_tree().get_nodes_in_group(constants.MAP_TILES_GROUP)[0]
onready var tileset_props_l2 = get_tree().get_nodes_in_group(constants.MAP_TILES_GROUP)[1]
onready var hidden_tiles = get_tree().get_nodes_in_group(constants.HIDDEN_TILES_GROUP)[0]

# keep track of the actual underlying map actions (which can differ even for the same icon)
onready var map_actions = get_tree().get_nodes_in_group(constants.MAP_ACTIONS_GROUP)[0]

# make sure we have access to the main camera node
onready var camera = get_tree().get_nodes_in_group("Camera")[0]

# keep track of our overworld sprite
var unit_sprite_node

# keep track of the unit's portrait sprite
var unit_portrait_sprite

# units can inherit from this class to access common variables

# a set of Vector2s that are currently eligible for movement (doesn't' include distance)
var movement_set = []

# the unit's movement sound
onready var unit_move_sound = preload("res://Music/Unit_Move_Sound.wav")
var unit_move_sound_node = null

# this dict will be used to track the eligible movement tiles, as well as their total distance
var eligible_tile_tracker = {}

# keep track of whether or not the unit has acted
var has_acted = false

# the unit's position on the map
onready var unit_pos_x = player.guild_hall_x
onready var unit_pos_y = player.guild_hall_y

# the unit's base movement (can be modified)
var base_move = 0

# the unit's base wake-up time (default 8am)
var wake_up_time = 8

# by default, all unit's are asleep
var unit_awake = false

# the unit's bed time (default 9pm)
var bed_time = 21

# keep track of the unit's items
var item_limit = 5 # default

# keep track of the player's meal limit
var meal_limit = 1

var current_items = [
]

var unit_abilities = [
]

# active locations a unit can shelter in at night
onready var shelter_locations = [
	global_action_list.COMPLETE_ACTION_LIST.RETURN_TO_GUILD
]

# a unique ID to identify this unit
var unit_id = 0

# the unit's name
var unit_name = ""

# the unit's class
var unit_class = ""

# the unit's age
var age = 0

# keep track of the unit's starting ability
var starting_ability

# a short bio about the unit
var unit_bio = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."

# a basic unit's skill starting levels
var skill_levels = {
	"fishing": 1,
	"mining": 1,
	"woodcutting": 1,
	"woodworking": 1,
	"smithing": 1,
}

var skill_xp = {
	"fishing": 0,
	"mining": 0,
	"woodcutting": 0,
	"woodworking": 0,
	"smithing": 0,
}

# list of actions that are available to the unit
onready var initial_action_list = [
	global_action_list.COMPLETE_ACTION_LIST.MOVE,
	global_action_list.COMPLETE_ACTION_LIST.INFO,
]

# a list of actions available to the unit after they've acted
onready var depleted_action_list = [
	global_action_list.COMPLETE_ACTION_LIST.INFO,
]

# extra actions that specific units can do (this list is checked when populating 'exclusive' actions)
onready var extra_actions = [
	
]

onready var current_action_list = initial_action_list.duplicate()

# a tracker variable
var item_in_use = null

# initialize the unit (all units will need to call this)
func unit_base_init():	
	unit_move_sound_node = AudioStreamPlayer.new()
	unit_move_sound_node.stream = unit_move_sound
	unit_move_sound_node.volume_db = constants.GAME_VOLUME
	add_child(unit_move_sound_node)

# set unit position
func set_unit_pos(target_x, target_y):
	unit_pos_x = target_x
	unit_pos_y = target_y
	self.global_position = Vector2(target_x*constants.TILE_WIDTH, 
								target_y*constants.TILE_HEIGHT)
	
# function for determining the action list, based on the current location
func determine_action_list():
	# first, make sure the unit hasn't already acted
	if (!has_acted):
		# empty the action list
		current_action_list = initial_action_list.duplicate()
		
		# if there are any actions on our tile, based on the icon
		var current_tile_actions = map_actions.get_actions_at_coordinates(Vector2(unit_pos_x, unit_pos_y))
		var adjacent_tile_actions = []
		var new_actions = []
		
		if (current_tile_actions.size() > 0):
			new_actions += current_tile_actions
	
		# check special actions (for unique locations on the map)
		current_action_list += get_tree().get_current_scene().populate_unique_actions(self)
	
		# check adjacent tiles
		
		# north
		var north = map_actions.get_actions_at_coordinates(Vector2(unit_pos_x, unit_pos_y - 1))
		if (north.size() > 0):
			adjacent_tile_actions += north
		
		# south
		var south = map_actions.get_actions_at_coordinates(Vector2(unit_pos_x, unit_pos_y + 1))
		if (south.size() > 0):
			adjacent_tile_actions += south
		
		# east
		var east = map_actions.get_actions_at_coordinates(Vector2(unit_pos_x + 1, unit_pos_y))
		if (east.size() > 0):
			adjacent_tile_actions += east
		
		# west
		var west = map_actions.get_actions_at_coordinates(Vector2(unit_pos_x - 1, unit_pos_y))
		if (west.size() > 0):
			adjacent_tile_actions += west
		
		# make sure adjacent tiles apply (most actions require actually being on the tile)
		for action in adjacent_tile_actions:
			if (action):
				if (map_actions.adjacent_applicable.has(action)):
					new_actions.append(action)
				
		# update the action list	
		current_action_list += new_actions
		
		# remove any 'exclusive' actions that this unit does not have access to
		var index = 0
		for action in current_action_list:
			if (global_action_list.exclusive_actions.has(action)):
				# this action is exlusive, see if the unit can do it
				if (!extra_actions.has(action)):
					current_action_list.remove(index)
					index -= 1
			index += 1
		
		# sort them
		current_action_list.sort()
	
func show_action_list():
	# add a selection list istance to our camera
	var hud_selection_list_node = hud_selection_list_scn.instance()
	camera.add_hud_item(hud_selection_list_node)
	
	# populate the action list with the current list of actions this unit can take
	hud_selection_list_node.populate_selection_list(current_action_list, self)
	
# reset our action list to the initial action list
func reset_action_list():	
	current_action_list = initial_action_list.duplicate()
	
func set_has_acted_state(state):
	has_acted = state
	
func remove_used_shader():
	# remove the 'used' shader
	unit_sprite_node.material = null

# we can now enable the unit's movement state + show movement grid
func enable_movement_state():
	# remove any existing movement squares
	clear_movement_grid_squares()
	
	# change the state
	player.player_state = player.PLAYER_STATE.SELECTING_MOVEMENT
	calculate_eligible_tiles()
	
# function for allowing the unit to cross various things (rivers for example)
func cross_water():
	# remove any existing movement squares
	clear_movement_grid_squares()

	# change the state
	player.player_state = player.PLAYER_STATE.CROSSING_WATER
	
	# clear the movement set
	movement_set.clear()
	
	# clear our eligible_tile_tracker (as we are adding a new set of tiles)
	eligible_tile_tracker = {}
	
	# determine which tiles are being crossed
	var overworld_scn = get_tree().get_current_scene()
	var tiles = overworld_scn.get_cardinal_tiles(self)
	
	var water_id = overworld_scn.l1_tiles.tile_set.find_tile_by_name('water')
	
	for tile in tiles:
		if (overworld_scn.l1_tiles.get_cellv(tile.tile) == water_id):
			# next to water. Determine if the tile adjacent to that is moveable
			var adj = tile.tile
			adj[tile.cord] += tile.direction
			var mvmt_cost = overworld_scn.l1_tiles.get_movement_cost(overworld_scn.l1_tiles.get_tile_at_coordinates(adj))
			if (overworld_scn.l2_tiles.get_tile_at_coordinates(adj) != null):
				mvmt_cost += overworld_scn.l2_tiles.get_movement_cost(overworld_scn.l2_tiles.get_tile_at_coordinates(adj))
	
			if (mvmt_cost < constants.CANT_MOVE && !player.party.is_unit_here(adj.x, adj.y)):
				eligible_tile_tracker[String(adj.x) + "_" + String(adj.y)] = {
					"pos_x": adj.x,
					"pos_y": adj.y,
					"distance": 0,
					"tile_cost": 0
				}
				movement_set.push_back(Vector2(adj.x, adj.y))
	
				show_movement_grid_square(adj.x, adj.y)
	
	print ('here??')
	if (movement_set.size() == 0):
		# the path is blocked...
		player.player_state = player.PLAYER_STATE.ANIMATING_MOVEMENT # use to temporarily halt any input
		player.hud.typeTextWithBuffer(global_action_list.PATH_BLOCKED, false, 'finished_viewing_text_generic')
		yield(signals, "finished_viewing_text_generic")
		player.player_state = player.PLAYER_STATE.SELECTING_TILE
		return
	
# function for allowing the unit to position themself around the guild hall
func postion_around_guild():
	# remove any existing movement squares
	clear_movement_grid_squares()

	# change the state
	player.player_state = player.PLAYER_STATE.POSITIONING_UNIT

	# clear the movement set
	movement_set.clear()

	# clear our eligible_tile_tracker (as we are adding a new set of tiles)
	eligible_tile_tracker = {}

	var coordinates = [
		Vector2(player.guild_hall_x + 1, player.guild_hall_y + 2),
		Vector2(player.guild_hall_x, player.guild_hall_y + 2),
		Vector2(player.guild_hall_x - 1, player.guild_hall_y + 1),
		Vector2(player.guild_hall_x - 1, player.guild_hall_y),
		Vector2(player.guild_hall_x + 2, player.guild_hall_y + 1),
		Vector2(player.guild_hall_x + 2, player.guild_hall_y),
		Vector2(player.guild_hall_x, player.guild_hall_y - 1),
		Vector2(player.guild_hall_x + 1, player.guild_hall_y - 1),
		Vector2(player.guild_hall_x - 1, player.guild_hall_y + 2),
		Vector2(player.guild_hall_x + 2, player.guild_hall_y + 2),
		Vector2(player.guild_hall_x - 1, player.guild_hall_y - 1),
		Vector2(player.guild_hall_x + 2, player.guild_hall_y - 1),
	]


	for foc in coordinates:
		if (!get_tree().get_current_scene().unit_exists_at_coordinates(foc.x, foc.y)):
			eligible_tile_tracker[String(foc.x) + "_" + String(foc.y)] = {
				"pos_x": foc.x,
				"pos_y": foc.y,
				"distance": 0,
				"tile_cost": 0
			}
			movement_set.push_back(Vector2(foc.x, foc.y))
			
			show_movement_grid_square(foc.x, foc.y)
			
	# now show those tiles
	
# this function is called once a selection is made in the selection list
func do_action(action):
	match (action):
		global_action_list.COMPLETE_ACTION_LIST.MOVE:
			# enable the unit's movement state
			enable_movement_state()
		global_action_list.COMPLETE_ACTION_LIST.INFO:
			show_unit_info_full_screen()
		_: #default
			# do something
			player.enable_state(player.PLAYER_STATE.SELECTING_TILE)
		
# when the action list is cancelled, go back to selecting a tile
func cancel_select_list():
	player.player_state = player.PLAYER_STATE.SELECTING_TILE
		
func show_unit_info_full_screen():
	var hud_unit_info_full_node = hud_unit_info_full_scn.instance()
	camera.add_child(hud_unit_info_full_node)
	
	hud_unit_info_full_node.set_unit(self)
	hud_unit_info_full_node.initialize_screen()

func end_action(success = false, timer = null):
	if (timer):
		timer.stop()
		remove_child(timer)
	
	item_in_use = null
	
	if (success): # if the action was successfully completed
		# stop the unit move sound, in case they are moving
		unit_move_sound_node.stop()

		# deplete the unit's action list
		current_action_list = depleted_action_list.duplicate()
	
		# add the 'unit_spent' shader to the unit's sprite
		unit_sprite_node.material = unit_spent_shader
	
		# the unit has 'acted'
		set_has_acted_state(true)
		player.party.remove_from_yet_to_act(unit_id)
	
	# determine the next player state
	player.determine_next_state()
	
# add an item to the unit's inventory
func receive_item(item):
	if (current_items.size() < item_limit):
		global_items_list.add_item_to_unit(self, item)
		
	# otherwise... sorry? You probably shouldn't have gotten here ;) 
	
# quick function for checking if the unit's inventory is full
func is_inventory_full(item_removal_buffer = 0):
	# item removal buffer is used for instances where the unit may be losing items to receive items (i.e. crafting)
	return (current_items.size() - item_removal_buffer >= item_limit)
	
# function for gaining xp in a specific skill
func gain_xp(xp, skill):
	skill_xp[skill] += xp
	
	# so that the player can gain multiple levels at once (xp can carry over)
	while (skill_xp[skill] >= constants.experience_required[skill_levels[skill]]):
		skill_xp[skill] -= constants.experience_required[skill_levels[skill]]
		
		# level up!
		skill_levels[skill] += 1
	
func enable_animate_movement_state(timer = null):
	player.player_state = player.PLAYER_STATE.ANIMATING_MOVEMENT
	unit_move_sound_node.play()
	if (timer):
		timer.stop()
		remove_child(timer)
	
func clear_movement_grid_squares():
	for square in get_tree().get_nodes_in_group(constants.GRID_SQUARE_GROUP):
		square.get_parent().remove_child(square)

func position_unit_if_eligible(target_x, target_y, expend_action = false):
	var can_move = false
	
	# make sure the unit can actually move to this tile
	for eligible in movement_set:
		if (eligible.x == target_x && eligible.y == target_y && 
		!player.party.is_unit_asleep_at(target_x, target_y)):
			can_move = true
	
	if (!can_move):
		return
		
	clear_movement_grid_squares()
	
	set_unit_pos(target_x, target_y)
	
	if (expend_action):
		player.player_state = player.PLAYER_STATE.ANIMATING_MOVEMENT
		# break an item (if necessary)
		if (item_in_use != null):
			global_items_list.item_broke(item_in_use, self)
			yield(signals, "finished_viewing_text_generic")
			yield(get_tree().create_timer(.1), "timeout")
			item_in_use = null
		
		end_action(true) # action successful
	else:
		item_in_use = null
		player.player_state = player.PLAYER_STATE.SELECTING_TILE
	
func move_unit_if_eligible(target_x, target_y):
	var can_move = false
	
	# make sure the unit can actually move to this tile
	for eligible in movement_set:
		if (eligible.x == target_x && eligible.y == target_y):
			can_move = true
	
	if (!can_move):
		return
		
	clear_movement_grid_squares()
		
	enable_animate_movement_state()
	initiate_movement(a_star(target_x, target_y))

# functions global to all unit types
func show_movement_grid_square(pos_x, pos_y):
	# if there is a unit here, don't show the square
	var unit_here = false
	for unit in player.party.get_all_units():
		if (unit.unit_pos_x == pos_x && unit.unit_pos_y == pos_y):
			unit_here = true
	
	if (!unit_here):
		var square = movement_grid_square.instance()
		add_child(square)
	
		square.set_square_position(pos_x, pos_y)

# function for returning a unit to a specific location (usually at night / bedtime)
func return_to(location):
	# if asleep, make the unit invisible
	if (!unit_awake):
		unit_sprite_node.visible = false
	
	match(location):
		global_action_list.COMPLETE_ACTION_LIST.RETURN_TO_GUILD:
			# update coordinates
			set_unit_pos(player.guild_hall_x, player.guild_hall_y)
		global_action_list.COMPLETE_ACTION_LIST.RETURN_TO_CAMP:
			# stay put, and switch to 'camp' icon
			unit_sprite_node.visible = true
			unit_sprite_node.animation = "camping"

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
	set_unit_pos(path.back().pos_x, path.back().pos_y)

	pass
	
func animate_movement(vector2, timer):
	self.global_position = vector2
	timer.stop()
	remove_child(timer)

# calculate all of the eligible tiles the unit can move to, as well as their
# distance. 
func calculate_eligible_tiles():
	# clear out the eligible movement set
	movement_set.clear()
	
	# clear our eligible_tile_tracker (as we are calculating a new set of tiles)
	eligible_tile_tracker = {}
	
	# calculate the eligible tiles + distance, using the flood fill algorithm
	flood_fill(unit_pos_x, unit_pos_y, base_move, {})
	
# should have started with this...
# flood fill is the best approach for calculating eligible tiles
# it's a recursive function
func flood_fill(foc_x, foc_y, remaining_move, visited_tiles):
	
	# first, let's find our boundaries
	var left_bound = unit_pos_x - base_move
	var right_bound = unit_pos_x + base_move
	var up_bound = unit_pos_y - base_move
	var down_bound = unit_pos_y + base_move
	
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

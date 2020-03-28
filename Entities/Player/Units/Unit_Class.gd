extends Node

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in the global player variables
onready var player = get_node("/root/Player_Globals")

onready var movement_grid_square = preload("res://Entities/Player/Movement_Grid_Square.tscn")

# various hud scenes
onready var hud_selection_list_scn = preload("res://Entities/HUD/Selection_List.tscn")
onready var hud_unit_info_full_scn = preload("res://Entities/HUD/Unit_Info_Full.tscn")

# have 2 layers of potential tiles
onready var tileset_props_l1 = get_tree().get_nodes_in_group(constants.MAP_TILES_GROUP)[0]
onready var tileset_props_l2 = get_tree().get_nodes_in_group(constants.MAP_TILES_GROUP)[1]

# make sure we have access to the main camera node
onready var camera = get_tree().get_nodes_in_group("Camera")[0]

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

# the unit's position on the map
var unit_pos_x = 0
var unit_pos_y = 0

# the unit's base movement (can be modified)
var base_move = 0

# the unit's base wake-up time (default 8am)
var wake_up_time = 8

# the unit's name
var unit_name = ""

# the unit's class
var unit_class = ""

# the unit's age
var age = 0

# a short bio about the unit
var unit_bio = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."

# a basic unit's skill starting levels
var skill_levels = {
	"fishing": 1,
	"mining": 1,
	"woodcutting": 1
}

var skill_xp = {
	"fishing": 1,
	"mining": 1,
	"woodcutting": 1
}

enum BASIC_ACTIONS {
	MOVE,
	TEST1,
	TEST2,
	TEST3,
	INFO
}

# list of actions that are available to the unit
const initial_action_list = [
	BASIC_ACTIONS.MOVE,
	BASIC_ACTIONS.TEST1,
	BASIC_ACTIONS.TEST2,
	BASIC_ACTIONS.TEST3,
	BASIC_ACTIONS.INFO,
]

var current_action_list = initial_action_list

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
	
	
func show_action_list():
	# add a selection list istance to our camera
	var hud_selection_list_node = hud_selection_list_scn.instance()
	camera.add_hud_item(hud_selection_list_node)
	
	# populate the action list with the current list of actions this unit can take
	hud_selection_list_node.populate_selection_list(current_action_list, self)
	
# reset our action list to the initial action list
func reset_action_list():
	current_action_list = initial_action_list

# we can now enable the unit's movement state + show movement grid
func enable_movement_state():
	# remove any existing movement squares
	clear_movement_grid_squares()
	
	# change the state
	player.player_state = player.PLAYER_STATE.SELECTING_MOVEMENT
	calculate_eligible_tiles()
	

# this function is called once a selection is made in the selection list
func do_action(action):
	match (action):
		BASIC_ACTIONS.MOVE:
			# enable the unit's movement state
			enable_movement_state()
		BASIC_ACTIONS.INFO:
			show_unit_info_full_screen()
		_: #default
			# do something
			enable_select_tile_state()
			
# when the action list is cancelled, go back to selecting a tile
func cancel_select_list():
	player.player_state = player.PLAYER_STATE.SELECTING_TILE
		
func show_unit_info_full_screen():
	var hud_unit_info_full_node = hud_unit_info_full_scn.instance()
	camera.add_child(hud_unit_info_full_node)
	
	hud_unit_info_full_node.set_unit(self)
	hud_unit_info_full_node.initialize_screen()

func enable_select_tile_state(timer = null):
	player.player_state = player.PLAYER_STATE.SELECTING_TILE
	unit_move_sound_node.stop()
	if (timer):
		timer.stop()
		remove_child(timer)
	
func enable_animate_movement_state(timer = null):
	player.player_state = player.PLAYER_STATE.ANIMATING_MOVEMENT
	unit_move_sound_node.play()
	if (timer):
		timer.stop()
		remove_child(timer)
	
func clear_movement_grid_squares():
	for square in get_tree().get_nodes_in_group(constants.GRID_SQUARE_GROUP):
		square.get_parent().remove_child(square)
	
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
	var square = movement_grid_square.instance()
	add_child(square)
	
	square.set_square_position(pos_x, pos_y)

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
		
	# change the player state so the unit can start selecting tiles again
	var timer = Timer.new()
	timer.wait_time = current_time - constants.MOVE_ANIM_SPEED
	timer.connect("timeout", self, "enable_select_tile_state", [timer])
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

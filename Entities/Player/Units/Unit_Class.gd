extends Node

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in the global player variables
onready var player = get_node("/root/Player_Globals")

onready var movement_grid_square = preload("res://Entities/Player/Movement_Grid_Square.tscn")

# have 2 layers of potential tiles
onready var tileset_props_l1 = get_tree().get_nodes_in_group(constants.MAP_TILES_GROUP)[0]
onready var tileset_props_l2 = get_tree().get_nodes_in_group(constants.MAP_TILES_GROUP)[1]

# units can inherit from this class to access common variables

# keep track of the eligible tiles the unit can currently move to
var eligible_movement_tiles = []

# this dict will be used to track the eligible movement tiles, as well as their total distance
var eligible_tile_tracker = {}

# the unit's position on the map
var unit_pos_x = 0
var unit_pos_y = 0

# the unit's base movement (can be modified)
var base_move = 0

# the unit's name
var unit_name = ""

# set unit position
func set_unit_pos(target_x, target_y):
	unit_pos_x = target_x
	unit_pos_y = target_y
	self.global_position = Vector2(target_x*constants.TILE_WIDTH, 
								target_y*constants.TILE_HEIGHT)
	

# we can now enable the unit's movement state + show movement grid
func enable_movement_state():
	# remove any existing movement squares
	clear_movement_grid_squares()
	
	# change the state
	player.player_state = player.PLAYER_STATE.SELECTING_MOVEMENT
	calculate_eligible_tiles()

func clear_movement_grid_squares():
	for square in get_tree().get_nodes_in_group(constants.GRID_SQUARE_GROUP):
		square.get_parent().remove_child(square)
	
func move_unit_if_eligible(target_x, target_y):
	var can_move = false
	
	# make sure the unit can actually move to this tile
	for eligible in eligible_movement_tiles:
		if (eligible.x == target_x && eligible.y == target_y):
			can_move = true
	
	if (!can_move):
		return

	set_unit_pos(target_x, target_y)
	clear_movement_grid_squares()
	player.player_state = player.PLAYER_STATE.SELECTING_TILE

# functions global to all unit types
func show_movement_grid_square(pos_x, pos_y):
	var square = movement_grid_square.instance()
	add_child(square)
	
	square.set_square_position(pos_x, pos_y)

# calculate all of the eligible tiles the unit can move to, as well as their
# distance. 
func calculate_eligible_tiles():
	# clear out the eligible movement tiles
	eligible_movement_tiles.clear()
	
	# clear our eligible_tile_tracker (as we are calculating a new set of tiles)
	eligible_tile_tracker = {}
	
	# calculate the eligible tiles + distance, using the flood fill algorithm
	flood_fill(unit_pos_x, unit_pos_y, base_move, {})
	
	print(eligible_tile_tracker)
	
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
	
	# subtract the cost of the l1 tiles (if they exist. Else, we DEFINITELY can't move there!)
	if (tile_name_l1 != null):
		remaining_move -= tileset_props_l1.get_movement_cost(tile_name_l1)
	else:
		remaining_move -= constants.CANT_MOVE
	
	# subtract the cost of the l2 tiles, if they exist
	if (tile_name_l2 != null):
		remaining_move -= tileset_props_l2.get_movement_cost(tile_name_l2)
		
	# the tile is eligible if the remaining_move is >= 0
	if (foc_x == unit_pos_x && foc_y == unit_pos_y):
		remaining_move = base_move # we're still at the origin tile
	else:
		if (remaining_move >= 0):
			eligible_movement_tiles.push_back(Vector2(foc_x, foc_y))
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
			"distance": base_move - remaining_move
		}
	else:
		if (eligible_tile_tracker.get(String(foc_x) + "_" + String(foc_y)).distance > base_move - remaining_move):
			# we've got a cheaper path to get to this tile!
			eligible_tile_tracker[String(foc_x) + "_" + String(foc_y)] = {
				"pos_x": foc_x,
				"pos_y": foc_y,
				"distance": base_move - remaining_move
			}
			
			# we want to recurse from here, to make sure adjacent tiles are updated
			# with a cheaper distance
			initiate_recursion = true

	if (initiate_recursion):
		flood_fill(foc_x + 1, foc_y, remaining_move, visited_tiles); # tile to the east
		flood_fill(foc_x - 1, foc_y, remaining_move, visited_tiles); # tile to the west
		flood_fill(foc_x, foc_y + 1, remaining_move, visited_tiles); # tile to the south
		flood_fill(foc_x, foc_y - 1, remaining_move, visited_tiles); # tile to the north

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

# create a  set of tiles that we are iterating through, to track the current distance
var s_tiles = {}

# the unit's position on the map
var unit_pos_x = 0
var unit_pos_y = 0

# the unit's base movement (can be modified)
var base_move = 0

# the unit's name
var unit_name = ""

# for the spiral algorithm
enum direction {
	CLOCKWISE
	COUNTERCLOCKWISE
}

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
	
	# clear our s_tiles tracker (for visited tiles)
	s_tiles = {}
	
	# calculate the distance, using the flood fill algorithm
	flood_fill(unit_pos_x, unit_pos_y, base_move, {})
	
#	spiral(s_tiles, direction.COUNTERCLOCKWISE)
#	spiral(s_tiles, direction.CLOCKWISE)
#	spiral(s_tiles, direction.COUNTERCLOCKWISE)
#	spiral(s_tiles, direction.CLOCKWISE)
	
	# we've calculated the distance of all tiles, now let's determine if they
	# are eligible for movement, or not
#	for tile in s_tiles:
#		var tileObj = s_tiles[tile]
#		# if the distance is less than the unit's movement, and we're not already there
#		if (tileObj.distance > 0 && tileObj.distance <= base_move): 
#			eligible_movement_tiles.push_back(Vector2(tileObj.pos_x, tileObj.pos_y))
#			show_movement_grid_square(tileObj.pos_x, tileObj.pos_y)

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

	# usually, movement cost is 1. Some tiles may take more movement to move on to
	# to determine this, we add the movement costs of both layers
	# start by setting it to the distance of the last tile
	
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
		remaining_move = base_move # we're still at the base
	else:
		if (remaining_move >= 0):
			eligible_movement_tiles.push_back(Vector2(foc_x, foc_y))
			show_movement_grid_square(foc_x, foc_y)

	print('FOC X ' + String(foc_x))
	print('FOC_Y ' + String(foc_y))
	print('REMAINING MOVE ' + String(remaining_move))
	print(" ")
	
	var initiate_recursion = true
	
	# if we've already been here in this recursion chain, skip (otherwise, StackOverflow)
	if (visited_tiles.get(String(foc_x) + "_" + String(foc_y)) != null):
		if (foc_x == unit_pos_x && foc_y == unit_pos_y):
			pass
		else:
			print("SKIPPING")
			print(String(foc_x) + "_" + String(foc_y))
			print(visited_tiles.get(String(foc_x) + "_" + String(foc_y)))
			print(" ")
			
			initiate_recursion = false
	
	# mark the tile as visited
	var tile_visited = visited_tiles.get(String(foc_x) + "_" + String(foc_y))
	if (tile_visited == null):
		visited_tiles[String(foc_x) + "_" + String(foc_y)] = true

	# mark the distance of the tile
	if (s_tiles.get(String(foc_x) + "_" + String(foc_y)) == null):
		s_tiles[String(foc_x) + "_" + String(foc_y)] = base_move - remaining_move
	else:
		if (s_tiles.get(String(foc_x) + "_" + String(foc_y)) > base_move - remaining_move):
			# we've got a cheaper path to get here!
			s_tiles[String(foc_x) + "_" + String(foc_y)] = base_move - remaining_move
			initiate_recursion = true

	if (initiate_recursion):
		flood_fill(foc_x + 1, foc_y, remaining_move, visited_tiles); # tile to the east
		flood_fill(foc_x - 1, foc_y, remaining_move, visited_tiles); # tile to the west
		flood_fill(foc_x, foc_y + 1, remaining_move, visited_tiles); # tile to the south
		flood_fill(foc_x, foc_y - 1, remaining_move, visited_tiles); # tile to the north


# I can't claim to have come up with this 'Spiral' algorithm...
# tbh, I grabbed it off of StackOverflow
func spiral(s_tiles, dir):
	# width and height of the range of tiles
	# i.e move 1 = 3x3, move 2 = 5x5
	var sq_size = (base_move*2) + 1 
	
	# current focus. Will start at the "origin", but will be shifted
	# to the actual world map coordinates
	var foc_x = 0 
	var foc_y = 0
	
	# keep track of all the tiles we're iterating over, as well as their distance
	# to the unit

	s_tiles[String(foc_x) + "_" + String(foc_y)] = {
		"pos_x": foc_x + unit_pos_x,
		"pos_y": foc_y + unit_pos_y,
		"distance": 0
	} # the starting tile, distance of 0

	
	var change_x
	if (dir == direction.CLOCKWISE):
		change_x = 0
	else:
		change_x = -1

	var change_y
	if (dir == direction.CLOCKWISE):
		change_y = -1
	else:
		change_y = 0
	
	for _i in range(pow(sq_size,2)):
		# calculate the distance, based on the tile's neighbors
		var shortest_distance = constants.CANT_MOVE # by default, assume we can't move to the tile
		
		if (s_tiles.get(String(foc_x+1) + "_" + String(foc_y)) != null): # tile to the right
			var neighbor_right_dist = s_tiles.get(String(foc_x+1) + "_" + String(foc_y)).distance
			if (neighbor_right_dist < shortest_distance):
				shortest_distance = neighbor_right_dist
			
		if (s_tiles.get(String(foc_x-1) + "_" + String(foc_y)) != null): # tile to the left
			var neighbor_left_dist = s_tiles.get(String(foc_x-1) + "_" + String(foc_y)).distance
			if (neighbor_left_dist < shortest_distance):
				shortest_distance = neighbor_left_dist
				
		if (s_tiles.get(String(foc_x) + "_" + String(foc_y-1)) != null): # tile to the north
			var neighbor_up_dist = s_tiles.get(String(foc_x) + "_" + String(foc_y-1)).distance
			if (neighbor_up_dist < shortest_distance):
				shortest_distance = neighbor_up_dist
			
		if (s_tiles.get(String(foc_x) + "_" + String(foc_y+1)) != null): # tile to the south
			var neighbor_down_dist = s_tiles.get(String(foc_x) + "_" + String(foc_y+1)).distance
			if (neighbor_down_dist < shortest_distance):
				shortest_distance = neighbor_down_dist
		
		var tile_name_l1 = tileset_props_l1.get_tile_at_coordinates(Vector2(foc_x + unit_pos_x, foc_y + unit_pos_y))
		var tile_name_l2 = tileset_props_l2.get_tile_at_coordinates(Vector2(foc_x + unit_pos_x, foc_y + unit_pos_y))
		
		# usually, movement cost is 1. Some tiles may take more movement to move on to
		var new_tile_distance = shortest_distance
		
		# add the cost of the l1 tiles (if they exist. Else, we DEFINITELY can't move there!)
		if (tile_name_l1 != null):
			new_tile_distance += tileset_props_l1.get_movement_cost(tile_name_l1)
		else:
			new_tile_distance = constants.CANT_MOVE
			
		# add the cost of the l2 tiles, if they exist
		if (tile_name_l2 != null):
			new_tile_distance += tileset_props_l2.get_movement_cost(tile_name_l2)
		
		# update the distance of this particular tile
		if (!(foc_x == 0 && foc_y == 0)):
			s_tiles[String(foc_x) + "_" + String(foc_y)] = {
				"pos_x": foc_x + unit_pos_x,
				"pos_y": foc_y + unit_pos_y,
				"distance": new_tile_distance
			}
		else:
			new_tile_distance = 0
		
		# now, we need to update the distance of all adjacent neighbors
		
		# neighbor right
		var tile_name_right_l1 = tileset_props_l1.get_tile_at_coordinates(Vector2(foc_x + unit_pos_x + 1, foc_y + unit_pos_y))
		var tile_name_right_l2 = tileset_props_l2.get_tile_at_coordinates(Vector2(foc_x + unit_pos_x + 1, foc_y + unit_pos_y))
		var tile_right_move_cost = 0
		
		if (tile_name_right_l1 != null):
			tile_right_move_cost += tileset_props_l1.get_movement_cost(tile_name_right_l1)
		else:
			tile_right_move_cost += constants.CANT_MOVE
		if (tile_name_right_l2 != null):
			tile_right_move_cost += tileset_props_l1.get_movement_cost(tile_name_right_l1)

		var current_tile_right_distance = constants.CANT_MOVE
		
		if (s_tiles.get(String(foc_x+1) + "_" + String(foc_y)) != null):
			current_tile_right_distance = s_tiles.get(String(foc_x+1) + "_" + String(foc_y)).distance
		
		if (current_tile_right_distance > (new_tile_distance + tile_right_move_cost)):
			s_tiles[String(foc_x+1) + "_" + String(foc_y)] = {
				"pos_x": (foc_x+1) + unit_pos_x,
				"pos_y": foc_y + unit_pos_y,
				"distance": new_tile_distance + tile_right_move_cost
			}
		
		# neighbor down
		var tile_name_down_l1 = tileset_props_l1.get_tile_at_coordinates(Vector2(foc_x + unit_pos_x, foc_y + unit_pos_y+1))
		var tile_name_down_l2 = tileset_props_l2.get_tile_at_coordinates(Vector2(foc_x + unit_pos_x, foc_y + unit_pos_y+1))
		var tile_down_move_cost = 0
		
		if (tile_name_down_l1 != null):
			tile_down_move_cost += tileset_props_l1.get_movement_cost(tile_name_down_l1)
		else:
			tile_down_move_cost += constants.CANT_MOVE
		if (tile_name_down_l2 != null):
			tile_down_move_cost += tileset_props_l1.get_movement_cost(tile_name_down_l1)

		var current_tile_down_distance = constants.CANT_MOVE
		
		if (s_tiles.get(String(foc_x) + "_" + String(foc_y+1)) != null):
			current_tile_down_distance = s_tiles.get(String(foc_x) + "_" + String(foc_y+1)).distance
		
		if (current_tile_down_distance > (new_tile_distance + tile_down_move_cost)):
			s_tiles[String(foc_x) + "_" + String(foc_y+1)] = {
				"pos_x": foc_x + unit_pos_x,
				"pos_y": (foc_y+1) + unit_pos_y,
				"distance": new_tile_distance + tile_down_move_cost
			}
			

		# neighbor left
		var tile_name_left_l1 = tileset_props_l1.get_tile_at_coordinates(Vector2(foc_x + unit_pos_x - 1, foc_y + unit_pos_y))
		var tile_name_left_l2 = tileset_props_l2.get_tile_at_coordinates(Vector2(foc_x + unit_pos_x - 1, foc_y + unit_pos_y))
		var tile_left_move_cost = 0
		
		if (tile_name_left_l1 != null):
			tile_left_move_cost += tileset_props_l1.get_movement_cost(tile_name_left_l1)
		else:
			tile_left_move_cost += constants.CANT_MOVE
		if (tile_name_left_l2 != null):
			tile_left_move_cost += tileset_props_l1.get_movement_cost(tile_name_left_l1)

		var current_tile_left_distance = constants.CANT_MOVE
		
		if (s_tiles.get(String(foc_x-1) + "_" + String(foc_y)) != null):
			current_tile_left_distance = s_tiles.get(String(foc_x-1) + "_" + String(foc_y)).distance
		
		if (current_tile_left_distance > (new_tile_distance + tile_left_move_cost)):
			s_tiles[String(foc_x-1) + "_" + String(foc_y)] = {
				"pos_x": (foc_x-1) + unit_pos_x,
				"pos_y": foc_y + unit_pos_y,
				"distance": new_tile_distance + tile_left_move_cost
			}
			
		# neighbor up
		var tile_name_up_l1 = tileset_props_l1.get_tile_at_coordinates(Vector2(foc_x + unit_pos_x, foc_y + unit_pos_y-1))
		var tile_name_up_l2 = tileset_props_l2.get_tile_at_coordinates(Vector2(foc_x + unit_pos_x, foc_y + unit_pos_y-1))
		var tile_up_move_cost = 0
		
		if (tile_name_up_l1 != null):
			tile_up_move_cost += tileset_props_l1.get_movement_cost(tile_name_up_l1)
		else:
			tile_up_move_cost += constants.CANT_MOVE
		if (tile_name_up_l2 != null):
			tile_up_move_cost += tileset_props_l1.get_movement_cost(tile_name_up_l1)

		var current_tile_up_distance = constants.CANT_MOVE
		
		if (s_tiles.get(String(foc_x) + "_" + String(foc_y-1)) != null):
			current_tile_up_distance = s_tiles.get(String(foc_x) + "_" + String(foc_y-1)).distance
		
		if (current_tile_up_distance > (new_tile_distance + tile_up_move_cost)):
			s_tiles[String(foc_x) + "_" + String(foc_y-1)] = {
				"pos_x": foc_x + unit_pos_x,
				"pos_y": (foc_y-1) + unit_pos_y,
				"distance": new_tile_distance + tile_up_move_cost
			}

		if (dir == direction.CLOCKWISE):
			if ((foc_x == foc_y) ||
				(foc_x < 0 && foc_x == -foc_y) ||
				(foc_x > 0 && foc_x == 1-foc_y)):
				var temp_c_x = change_x
				var temp_c_y = change_y
				change_x = -temp_c_y
				change_y = temp_c_x
		else:
			if ((foc_x == foc_y) ||
				(foc_y < 0 && foc_y == -foc_x) ||
				(foc_y > 0 && foc_y == 1-foc_x)):
				var temp_c_x = change_x
				var temp_c_y = change_y
				change_x = temp_c_y
				change_y = -temp_c_x
		foc_x += change_x
		foc_y += change_y

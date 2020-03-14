extends Node

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

onready var movement_grid_square = preload("res://Entities/Player/Movement_Grid_Square.tscn")

# have 2 layers of potential tiles
onready var tileset_props_l1 = get_tree().get_nodes_in_group(constants.MAP_TILES_GROUP)[0]
onready var tileset_props_l2 = get_tree().get_nodes_in_group(constants.MAP_TILES_GROUP)[1]

# units can inherit from this class to access common variables

# the unit's position on the map
var unit_pos_x = 0
var unit_pos_y = 0

# the unit's base movement (can be modified)
var base_move = 0

# the unit's name
var unit_name = ""

# functions global to all unit types
func show_movement_grid_square(pos_x, pos_y):
	var square = movement_grid_square.instance()
	add_child(square)
	square.set_square_position(pos_x, pos_y)

# calculate all of the eligible tiles the unit can move to, as well as their
# distance. I can't claim to have come up with this 'Spiral' algorithm...
# tbh, I grabbed it off of StackOverflow
func calculate_eligible_tiles():
	# width and height of the range of tiles
	# i.e move 1 = 3x3, move 2 = 5x5
	var sq_size = (base_move*2) + 1 
	
	# current focus. Will start at the "origin", but will be shifted
	# to the actual world map coordinates
	var foc_x = 0 
	var foc_y = 0
	
	# keep track of all the tiles we're iterating over, as well as their distance
	# to the unit
	var tiles = {}
	tiles[String(foc_x) + "_" + String(foc_y)] = 0 # the starting tile, distance of 0

	var change_x = 0
	var change_y = -1
	for _i in range(pow(sq_size,2)):
		# calculate the distance, based on the tile's neighbors
		if (!(foc_x == 0 && foc_y == 0)):
			var shortest_distance = constants.CANT_MOVE # by default, assume we can't move to the tile
			
			if (tiles.get(String(foc_x+1) + "_" + String(foc_y)) != null): # tile to the right
				var neighbor_right_dist = tiles.get(String(foc_x+1) + "_" + String(foc_y))
				if (neighbor_right_dist < shortest_distance):
					shortest_distance = neighbor_right_dist
				
			if (tiles.get(String(foc_x-1) + "_" + String(foc_y)) != null): # tile to the left
				var neighbor_left_dist = tiles.get(String(foc_x-1) + "_" + String(foc_y))
				if (neighbor_left_dist < shortest_distance):
					shortest_distance = neighbor_left_dist
					
			if (tiles.get(String(foc_x) + "_" + String(foc_y-1)) != null): # tile to the north
				var neighbor_up_dist = tiles.get(String(foc_x) + "_" + String(foc_y-1))
				if (neighbor_up_dist < shortest_distance):
					shortest_distance = neighbor_up_dist
				
			if (tiles.get(String(foc_x) + "_" + String(foc_y+1)) != null): # tile to the south
				var neighbor_down_dist = tiles.get(String(foc_x) + "_" + String(foc_y+1))
				if (neighbor_down_dist < shortest_distance):
					shortest_distance = neighbor_down_dist
			
			var tile_name_l1 = tileset_props_l1.get_tile_at_coordinates(Vector2(foc_x + unit_pos_x, foc_y + unit_pos_y))
			var tile_name_l2 = tileset_props_l2.get_tile_at_coordinates(Vector2(foc_x + unit_pos_x, foc_y + unit_pos_y))
			
			# usually, movement cost is 1. Some tiles may take more movement to move on to
			var new_tile_distance = shortest_distance

			if (tile_name_l2 != null): 
				print("with " + String(tile_name_l2))
			print("Tile: " + String(foc_x + unit_pos_x) + ", " + String(foc_y + unit_pos_y))
			
			# add the cost of the l1 tiles (if they exist. Else, we DEFINITELY can't move there!)
			if (tile_name_l1 != null):
				new_tile_distance += tileset_props_l1.get_movement_cost(tile_name_l1)
			else:
				new_tile_distance = constants.CANT_MOVE
				
			# add the cost of the l2 tiles, if they exist
			if (tile_name_l2 != null):
				new_tile_distance += tileset_props_l2.get_movement_cost(tile_name_l2)
			
			print("cost is " + String(new_tile_distance))
			print(" ")
			
			# update the distance of this particular tile
			tiles[String(foc_x) + "_" + String(foc_y)] = new_tile_distance
		
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
			
			if (tiles.get(String(foc_x+1) + "_" + String(foc_y)) != null):
				current_tile_right_distance = tiles.get(String(foc_x+1) + "_" + String(foc_y))
			
			if (current_tile_right_distance > (new_tile_distance + tile_right_move_cost)):
				tiles[String(foc_x+1) + "_" + String(foc_y)] = new_tile_distance + tile_right_move_cost
			
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
			
			if (tiles.get(String(foc_x) + "_" + String(foc_y+1)) != null):
				current_tile_down_distance = tiles.get(String(foc_x) + "_" + String(foc_y+1))
			
			if (current_tile_down_distance > (new_tile_distance + tile_down_move_cost)):
				tiles[String(foc_x) + "_" + String(foc_y+1)] = new_tile_distance + tile_down_move_cost
				
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
			
			if (tiles.get(String(foc_x-1) + "_" + String(foc_y)) != null):
				current_tile_left_distance = tiles.get(String(foc_x-1) + "_" + String(foc_y))
			
			if (current_tile_left_distance > (new_tile_distance + tile_left_move_cost)):
				tiles[String(foc_x-1) + "_" + String(foc_y)] = new_tile_distance + tile_left_move_cost
				
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
			
			if (tiles.get(String(foc_x) + "_" + String(foc_y-1)) != null):
				current_tile_up_distance = tiles.get(String(foc_x) + "_" + String(foc_y-1))
			
			if (current_tile_up_distance > (new_tile_distance + tile_up_move_cost)):
				tiles[String(foc_x) + "_" + String(foc_y-1)] = new_tile_distance + tile_up_move_cost
			
			

			# shifted to the actual location on map
			if (new_tile_distance <= base_move): # if within the units movement
				show_movement_grid_square(foc_x + unit_pos_x, foc_y + unit_pos_y)
				# DO STUFF...

		if ((foc_x == foc_y) ||
			(foc_x < 0 && foc_x == -foc_y) ||
			(foc_x > 0 && foc_x == 1-foc_y)):
			var temp_c_x = change_x
			var temp_c_y = change_y
			change_x = -temp_c_y
			change_y = temp_c_x
		foc_x += change_x
		foc_y += change_y

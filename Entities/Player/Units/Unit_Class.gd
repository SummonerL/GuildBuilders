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

# a set of Vector2s that are currently eligible for movement (doesn't' include distance)
var movement_set = []

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
	for eligible in movement_set:
		if (eligible.x == target_x && eligible.y == target_y):
			can_move = true
	
	if (!can_move):
		return
		
	a_star(target_x, target_y)

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
		#print("OPEN LIST")
		#print(open_list)
		#print(" ")
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
			
		if (path.size() > 0):
			print("SHOULDNT BE HERE")

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
			child.parent = cheapest_tile
			
			# create the f, g, and h values, unless the child is the target
			# in that case, leave the f cost as 0
			if (child.pos_x != target_x || child.pos_y != target_y):
				child.g = child.parent.g + child.tile_cost
				# experiment with different heuristics for more interesting
				# pathfinding
				child.h = abs(child.pos_x - target_x) + abs(child.pos_y + target_y) + child.tile_cost
				#child.h = pow(child.pos_x - target_x, 2) + pow(child.pos_y - target_y, 2)
				child.f = child.g + child.h
			
			

			
			# if the child is already in the open list,
			# and the current child's g cost is higher than
			# what's in the open list, continue
			var addTile = true
			for open in open_list:
				if (open.pos_x == child.pos_x && open.pos_y == child.pos_y):
					if (child.g > open.g):
						addTile = false
			
			# add the child to the open list!
			if (addTile):
				open_list.push_back(child)
	
	
	print (path)
	print ("Moving to " + String(target_x) + ", " + String(target_y))
	pass

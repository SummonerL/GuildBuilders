extends TileMap

const CANT_MOVE = 999999
const NORMAL_MOVE = 1

const TILES = {2: 'WATER', 3: 'GRASSLAND', 
				4: 'GRASSLAND_DEC1', 5: 'GRASSLAND_DEC2',
				6: 'GRASSLAND_DEC3', 7: 'SAND',
				8: 'GRASSLAND_TREE', 9: 'SAND_TREE',
				10: 'HILL', 11: 'DUNE', 
				12: 'BOULDER', 13: 'OCEAN', 17: 'MOUNTAIN',
				19: 'GUILD',
				22: 'CEDAR_TREE',
				23: 'ASH_TREE',
				24: 'FIR_TREE',
				25: 'CAVE'}

const TILE_INFO_HUD_NAME = { 
	'WATER':  'Water',
	'GRASSLAND': 'Grass',
	'GRASSLAND_DEC1':  'Grass', 
	'GRASSLAND_DEC2': 'Grass', 
	'GRASSLAND_DEC3': 'Grass',
	'SAND': 'Sand', 
	'GRASSLAND_TREE': 'Trees',
	'CEDAR_TREE': 'Cedar',
	'ASH_TREE': 'Ash',
	'FIR_TREE': 'Fir',
	'SAND_TREE': 'Tree',
	'HILL': 'Hill',
	'DUNE': 'Dune', 
	'BOULDER': 'Stone',
	'CAVE': 'Cave',
	'OCEAN': 'Ocean',
	'MOUNTAIN': 'Mount',
	'GUILD': 'Guild'
}


enum MOVEMENT_COST {
	WATER = CANT_MOVE,
	GRASSLAND = NORMAL_MOVE,
	GRASSLAND_DEC1 = NORMAL_MOVE,
	GRASSLAND_DEC2 = NORMAL_MOVE,
	GRASSLAND_DEC3 = NORMAL_MOVE,
	SAND = NORMAL_MOVE,
	GRASSLAND_TREE = NORMAL_MOVE + 1,
	CEDAR_TREE = NORMAL_MOVE + 1,
	ASH_TREE = NORMAL_MOVE + 1,
	FIR_TREE = NORMAL_MOVE + 1,
	SAND_TREE = NORMAL_MOVE + 1,
	HILL = NORMAL_MOVE + 1,
	DUNE = NORMAL_MOVE + 1,
	BOULDER = NORMAL_MOVE + 1, # boulders are l2 tiles, so they get added to whatever they sit on top of
	CAVE = 1, # l2 tiles, so add the l1 tile first
	OCEAN = CANT_MOVE,
	MOUNTAIN = NORMAL_MOVE + 2 # very difficult to move onto a mountain
	GUILD = CANT_MOVE
}

func get_tile_at_coordinates(vec2):
	var tile = get_cellv(vec2)
	if (tile >= 0):
		return TILES[get_cellv(vec2)]
	else:
		return null
	
func get_movement_cost(tile):
	return MOVEMENT_COST[tile]

extends TileMap

const CANT_MOVE = 999999
const NORMAL_MOVE = 1

const TILES = {2: 'WATER', 3: 'GRASSLAND', 
				4: 'GRASSLAND_DEC1', 5: 'GRASSLAND_DEC2',
				6: 'GRASSLAND_DEC3', 7: 'SAND',
				8: 'GRASSLAND_TREE', 9: 'SAND_TREE',
				10: 'HILL', 11: 'DUNE', 
				12: 'BOULDER', 13: 'OCEAN', 14: 'FISH_ICON'}

enum MOVEMENT_COST {
	WATER = CANT_MOVE,
	GRASSLAND = NORMAL_MOVE,
	GRASSLAND_DEC1 = NORMAL_MOVE,
	GRASSLAND_DEC2 = NORMAL_MOVE,
	GRASSLAND_DEC3 = NORMAL_MOVE,
	SAND = NORMAL_MOVE,
	GRASSLAND_TREE = NORMAL_MOVE + 1,
	SAND_TREE = NORMAL_MOVE + 1,
	HILL = NORMAL_MOVE + 1,
	DUNE = NORMAL_MOVE + 1,
	BOULDER = NORMAL_MOVE + 1, # boulders are l2 tiles, so they get added to whatever they sit on top of
	OCEAN = CANT_MOVE,
	FISH_ICON = 0
}

func get_tile_at_coordinates(vec2):
	var tile = get_cellv(vec2)
	if (tile >= 0):
		return TILES[get_cellv(vec2)]
	else:
		return null
	
func get_movement_cost(tile):
	return MOVEMENT_COST[tile]

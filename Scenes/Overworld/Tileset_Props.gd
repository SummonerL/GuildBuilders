extends TileMap

const CANT_MOVE = 999999
const NORMAL_MOVE = 1

const TILES = {
				0: 'HIDDEN',
				2: 'WATER', 3: 'GRASSLAND', 
				4: 'GRASSLAND_DEC1', 5: 'GRASSLAND_DEC2',
				6: 'GRASSLAND_DEC3',
				36: 'GRASSLAND_DEC4',
				37: 'GRASSLAND_DEC5',
				38: 'GRASSLAND_DEC6',
				70: 'MARSH_DEC1',
				71: 'MARSH_DEC2',
				73: 'MARSH_DEC3',
				74: 'MARSH_DEC4',
				72: 'SWAMP',
				
				7: 'SAND',
				
				41: 'DIRT',
				49: 'ROAD',
				
				8: 'GRASSLAND_TREE', 9: 'SAND_TREE',
				10: 'HILL', 11: 'DUNE', 
				
				12: 'BOULDER',
				58: 'IRON',
				68: 'GOLD',
				
				13: 'OCEAN', 17: 'MOUNTAIN',
				42: 'LEDGE',
				43: 'LEDGE',
				44: 'LEDGE',
				45: 'LEDGE',
				46: 'LEDGE',
				
				19: 'GUILD',
				22: 'CEDAR_TREE',
				23: 'ASH_TREE',
				24: 'FIR_TREE',
				57: 'BIRCH_TREE',
				80: 'RUBBER_TREE',
				84: 'CYPRESS_TREE',
				
				25: 'CAVE',
				26: 'TOWER',
				47: 'MILL',
				48: 'INN',
				50: 'LAMP',
				51: 'SIGN',
				52: 'FOUNTAIN',
				53: 'STALL',
				54: 'STALL_IMMOVABLE',
				76: 'GRAVE',
				
				31: 'CABIN',
				82: 'CABIN',
				
				34: 'HOUSE',
				55: 'HOUSE',
				40: 'BARN',
				60: 'KEEP',
				67: 'HUT',
				61: 'BIRDHOUSE',
				
				35: 'BRIDGE',
				75: 'BRIDGE',
				78: 'BRIDGE',
				79: 'BRIDGE',
				83: 'DOCK',
				
				39: 'FENCE',
				56: 'WALL',
				59: 'FENCE',

				28: 'NPC_MAN',	
				29: 'NPC_WOMAN',
				32: 'NPC_GIRL',
				33: 'NPC_BOY',
				63: 'CAT',
				86: 'GATOR',
				69: 'HORSE',
				64: 'GUARD',
				85: 'GHOST',
				65: 'KING',
				66: 'GOBLIN',
				77: 'BEAVER'
				}

const TILE_INFO_HUD_NAME = { 
	'WATER':  'Water',
	'GRASSLAND': 'Grass',
	'GRASSLAND_DEC1':  'Grass', 
	'GRASSLAND_DEC2': 'Grass', 
	'GRASSLAND_DEC3': 'Grass',
	'GRASSLAND_DEC4': 'Grass',
	'GRASSLAND_DEC5': 'Grass',
	'GRASSLAND_DEC6': 'Grass',
	'MARSH_DEC1': 'Marsh',
	'MARSH_DEC2': 'Marsh',
	'MARSH_DEC3': 'Marsh',
	'MARSH_DEC4': 'Marsh',
	'SWAMP': 'Swamp',
	'SAND': 'Sand', 
	'DIRT': 'Dirt',
	'ROAD': 'Road',
	
	'GRASSLAND_TREE': 'Trees',
	'CEDAR_TREE': 'Cedar',
	'ASH_TREE': 'Ash',
	'FIR_TREE': 'Fir',
	'BIRCH_TREE': 'Birch',
	'RUBBER_TREE': 'Rubbr',
	'CYPRESS_TREE': 'Cyprs',
	
	'SAND_TREE': 'Tree',
	'HILL': 'Hill',
	'DUNE': 'Dune', 
	
	'BOULDER': 'Stone',
	'IRON': 'Iron',
	'GOLD': 'Gold',
	
	'CAVE': 'Cave',
	'OCEAN': 'Ocean',
	'MOUNTAIN': 'Mount',
	
	'LEDGE': 'Ledge',
	
	'GUILD': 'Guild',
	'TOWER': 'Tower',
	'MILL': 'Mill',
	'INN': 'Inn',
	'LAMP': 'Lamp',
	'SIGN': 'Sign',
	'FOUNTAIN': 'Fount',
	'STALL': 'Stall',
	'STALL_IMMOVABLE': 'Stall',
	'GRAVE': 'Grave',
	
	'NPC_MAN': 'Man',
	'NPC_WOMAN': 'Woman',
	'NPC_GIRL': 'Girl',
	'NPC_BOY': 'Boy',
	'CAT': 'Cat',
	'GATOR': 'Gator',
	'HORSE': 'Horse',
	'GUARD': 'Guard',
	'GHOST': 'Ghost',
	'KING': 'King',
	'GOBLIN': 'Gobln',
	'BEAVER': 'Beavr',
	
	'CABIN': 'Cabin',
	'HOUSE': 'House',
	'BARN': 'Barn',
	'KEEP': 'Keep',
	'HUT': 'Hut',
	'BIRDHOUSE': 'Bird',
	
	'BRIDGE': 'Bridg',
	'DOCK': 'Dock',
	'FENCE': 'Fence',
	'WALL': 'Wall',
}


const MOVEMENT_COST = {
	WATER = CANT_MOVE,
	GRASSLAND = NORMAL_MOVE,
	GRASSLAND_DEC1 = NORMAL_MOVE,
	GRASSLAND_DEC2 = NORMAL_MOVE,
	GRASSLAND_DEC3 = NORMAL_MOVE,
	GRASSLAND_DEC4 = NORMAL_MOVE,
	GRASSLAND_DEC5 = NORMAL_MOVE,
	GRASSLAND_DEC6 = NORMAL_MOVE,
	MARSH_DEC1 = NORMAL_MOVE + 1,
	MARSH_DEC2 = NORMAL_MOVE + 1,
	MARSH_DEC3 = NORMAL_MOVE + 1,
	MARSH_DEC4 = NORMAL_MOVE + 1,
	SWAMP = CANT_MOVE,
	SAND = NORMAL_MOVE,
	DIRT = NORMAL_MOVE,
	ROAD = .5, # costs half the normal amount
	GRASSLAND_TREE = NORMAL_MOVE + 1,
	CEDAR_TREE = NORMAL_MOVE + 1,
	ASH_TREE = NORMAL_MOVE + 1,
	FIR_TREE = NORMAL_MOVE + 1,
	BIRCH_TREE = NORMAL_MOVE + 1,
	SAND_TREE = NORMAL_MOVE + 1,
	RUBBER_TREE = NORMAL_MOVE + 1,
	CYPRESS_TREE = 1, # this is an l2 tile and will get added to the base
	
	HILL = NORMAL_MOVE + 1,
	DUNE = NORMAL_MOVE + 1,
	
	BOULDER = NORMAL_MOVE + 1, # boulders are l2 tiles, so they get added to whatever they sit on top of
	IRON = NORMAL_MOVE + 1,
	GOLD = NORMAL_MOVE + 1,
	
	CAVE = 1, # l2 tiles, so add the l1 tile first
	OCEAN = CANT_MOVE,
	MOUNTAIN = NORMAL_MOVE + 2, # very difficult to move onto a mountain
	LEDGE = NORMAL_MOVE + 2, # l2 tiles (get added to l1 cost)
	
	
	GUILD = CANT_MOVE,
	TOWER = CANT_MOVE,
	MILL = CANT_MOVE,
	INN = CANT_MOVE,
	LAMP = CANT_MOVE,
	SIGN = CANT_MOVE,
	FOUNTAIN = CANT_MOVE,
	STALL = 0, # gets added to l1
	STALL_IMMOVABLE = CANT_MOVE,
	GRAVE = CANT_MOVE,
	
	NPC_MAN = CANT_MOVE,
	NPC_WOMAN = CANT_MOVE,
	NPC_GIRL = CANT_MOVE,
	NPC_BOY = CANT_MOVE,
	CAT = CANT_MOVE,
	GATOR = CANT_MOVE,
	HORSE = CANT_MOVE,
	GUARD = CANT_MOVE,
	KING = CANT_MOVE,
	GHOST = CANT_MOVE,
	GOBLIN = CANT_MOVE,
	BEAVER = CANT_MOVE,
	
	CABIN = CANT_MOVE,
	HOUSE = CANT_MOVE,
	BARN = CANT_MOVE,
	KEEP = CANT_MOVE,
	HUT = CANT_MOVE,
	BIRDHOUSE = 0, # (l2) doesnt effect movement cost
	
	BRIDGE = -(CANT_MOVE - 1), # makes water movable
	DOCK = -(CANT_MOVE - 1), # makes water movable
	FENCE = CANT_MOVE,
	WALL = CANT_MOVE,
	
}

func get_tile_at_coordinates(vec2):
	var tile = get_cellv(vec2)
	if (tile >= 0):
		return TILES[get_cellv(vec2)]
	else:
		return null
		
func get_id_at_coordinates(vec2):
	var tile = get_cellv(vec2)
	if (tile >= 0):
		return tile
	else:
		return null
	
func get_movement_cost(tile):
	return MOVEMENT_COST[tile]

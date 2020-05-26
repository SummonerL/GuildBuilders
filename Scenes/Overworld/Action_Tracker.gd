extends TileMap

# bring in our global action list
onready var global_action_list = get_node("/root/Actions")

# bring in our items
onready var global_items_list = get_node("/root/Items")

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# our various animal scenes
onready var dove_scn = preload("res://Entities/Player/Animals/Bird.tscn")

var map_icons

const ACTIONS = {
	0: 'FISH_SPOT_1',
	1: 'FISH_SPOT_2',
	
	2: 'WOODCUTTING_SPOT_1',
	3: 'WOODCUTTING_SPOT_2',
	5: 'WOODCUTTING_SPOT_3',
	9: 'WOODCUTTING_SPOT_4',
	
	6: 'MINING_SPOT_1',
	10: 'MINING_SPOT_2',
	
	13: 'BEAST_MASTERY_SPOT_1',
	14: 'BEAST_MASTERY_SPOT_2',
	
	4: 'GUILD_SPOT_1',
	
	7: 'CAVE_CONNECTOR_1',
	8: 'CAVE_CONNECTOR_2',
	11: 'CAVE_CONNECTOR_3',
	12: 'CAVE_CONNECTOR_4'
}

# keep track of the kind of resources that can be gained on specific action spots
onready var ITEMS_AT_SPOT = {
	'FISH_SPOT_1': [global_items_list.item_jumbofish],
	'FISH_SPOT_2': [],
	'WOODCUTTING_SPOT_1': [global_items_list.item_cedar_logs],
	'WOODCUTTING_SPOT_2': [global_items_list.item_ash_logs],
	'WOODCUTTING_SPOT_3': [global_items_list.item_fir_logs],
	'WOODCUTTING_SPOT_4': [global_items_list.item_birch_logs],
	'MINING_SPOT_1': [global_items_list.item_stone],
	'MINING_SPOT_2': [global_items_list.item_iron_ore],
}

# keep track of the animals that can be found at specific spots
onready var ANIMALS_AT_SPOT = {
	'BEAST_MASTERY_SPOT_1': [dove_scn],
}

# specific actions associated with these tiles
onready var associated_actions = {
	'FISH_SPOT_1': [global_action_list.COMPLETE_ACTION_LIST.FISH],
	'FISH_SPOT_2': [global_action_list.COMPLETE_ACTION_LIST.FISH],
	'WOODCUTTING_SPOT_1': [global_action_list.COMPLETE_ACTION_LIST.CHOP],
	'WOODCUTTING_SPOT_2': [global_action_list.COMPLETE_ACTION_LIST.CHOP],
	'WOODCUTTING_SPOT_3': [global_action_list.COMPLETE_ACTION_LIST.CHOP],
	'WOODCUTTING_SPOT_4': [global_action_list.COMPLETE_ACTION_LIST.CHOP],
	'MINING_SPOT_1': [global_action_list.COMPLETE_ACTION_LIST.MINE],
	'MINING_SPOT_2': [global_action_list.COMPLETE_ACTION_LIST.MINE],
	'BEAST_MASTERY_SPOT_1': [global_action_list.COMPLETE_ACTION_LIST.CHECK_BIRDHOUSE],
	'BEAST_MASTERY_SPOT_2': [global_action_list.COMPLETE_ACTION_LIST.PET_CAT],
	
	'GUILD_SPOT_1': [global_action_list.COMPLETE_ACTION_LIST.DEPOT, 
					global_action_list.COMPLETE_ACTION_LIST.POSIT,
					global_action_list.COMPLETE_ACTION_LIST.DINE,
					global_action_list.COMPLETE_ACTION_LIST.CRAFT],
					
	'CAVE_CONNECTOR_1': [global_action_list.COMPLETE_ACTION_LIST.TUNNEL],
	'CAVE_CONNECTOR_2': [global_action_list.COMPLETE_ACTION_LIST.TUNNEL],
	'CAVE_CONNECTOR_3': [global_action_list.COMPLETE_ACTION_LIST.TUNNEL],
	'CAVE_CONNECTOR_4': [global_action_list.COMPLETE_ACTION_LIST.TUNNEL]
}

# level requirements for specific spots
onready var level_requirements = {
	'WOODCUTTING_SPOT_1': 1,
	'WOODCUTTING_SPOT_2': 2,
	'WOODCUTTING_SPOT_3': 3,
	'WOODCUTTING_SPOT_4': 4,
	
	'FISH_SPOT_1': 1,
	
	'MINING_SPOT_1': 1,
	'MINING_SPOT_2': 3,
	
	'BEAST_MASTERY_SPOT_1': 1
}

# matching connections (used for tunneling)
onready var matching_connections = {
	'CAVE_CONNECTOR_1': 'CAVE_CONNECTOR_2',
	'CAVE_CONNECTOR_2': 'CAVE_CONNECTOR_1',
	'CAVE_CONNECTOR_3': 'CAVE_CONNECTOR_4',
	'CAVE_CONNECTOR_4': 'CAVE_CONNECTOR_3',
}

# river actions (used for crossing)
onready var river_actions = [global_action_list.COMPLETE_ACTION_LIST.CROSS]

# npc actions
onready var npc_actions = [global_action_list.COMPLETE_ACTION_LIST.TALK]

# sign actions
onready var sign_actions = [global_action_list.COMPLETE_ACTION_LIST.READ_SIGN]

# tower actions
onready var tower_actions = [global_action_list.COMPLETE_ACTION_LIST.CLIMB_TOWER]

# keep track of individual tiles that have been interacted with in a particular day. This will allow us to 'deplete' certain
# tiles. This will be an object, where the key represents the location on the map, and the value is the remaining items @ that location
onready var used_tile_items = {
	
}

# list of actions in which still apply when adjacent
onready var adjacent_applicable = [
	global_action_list.COMPLETE_ACTION_LIST.FISH,
	global_action_list.COMPLETE_ACTION_LIST.PET_CAT
]

func get_action_spot_at_coordinates(vec2):
	var tile = get_cellv(vec2)
	if (tile >= 0):
		return ACTIONS[get_cellv(vec2)]
	else:
		return null
		
func get_actions_at_spot(spot):
	return associated_actions[spot]

func get_level_requirement_at_spot(spot):
	return level_requirements[spot]

func get_actions_at_coordinates(vec2):
	var tile = get_cellv(vec2)
	if (tile >= 0):
		return associated_actions[ACTIONS[get_cellv(vec2)]]
	else:
		return []

func get_items_at_coordinates(x, y):
	var spot = get_action_spot_at_coordinates(Vector2(x, y))
	
	# first, see if the oject exists in used_tile_items
	if (used_tile_items.get(String(x) + "_" + String(y)) != null):
		
		# return the array of items
		return used_tile_items.get(String(x) + "_" + String(y))
	else:
		# set the tile as used, and create the initial list of items
		used_tile_items[String(x) + '_' + String(y)] = ITEMS_AT_SPOT[spot].duplicate()
		
		return used_tile_items[String(x) + '_' + String(y)]

func set_items_at_coordinates(x, y, item_array, clear_icon_if_empty = true):		
	# when a tile has been used, update the items that remain there
	if (used_tile_items.get(String(x) + "_" + String(x)) != null):
		used_tile_items[String(x) + '_' + String(y)] = item_array.duplicate()
		
	# if the item array is empty, clear the map icon
	if (item_array.size() <= 0 && clear_icon_if_empty):
		map_icons = get_tree().get_nodes_in_group(constants.MAP_ICONS_GROUP)[0]
		
		var tileset = map_icons.get_tileset()
		
		map_icons.set_cellv(Vector2(x, y), tileset.find_tile_by_name("empty_spot"))

func remove_map_icon_at_coordinates(x, y):
		map_icons = get_tree().get_nodes_in_group(constants.MAP_ICONS_GROUP)[0]
		
		var tileset = map_icons.get_tileset()
		
		map_icons.set_cellv(Vector2(x, y), tileset.find_tile_by_name("empty_spot"))

func get_cave_connection(connection):
	return matching_connections[connection]

func reset_used_tiles():
	# at the beginning of a day, all tiles should reset
	used_tile_items = {}

func get_items_at_spot(spot):	
	return ITEMS_AT_SPOT[spot]
	
func get_animals_at_spot(spot):
	return ANIMALS_AT_SPOT[spot]
	
	

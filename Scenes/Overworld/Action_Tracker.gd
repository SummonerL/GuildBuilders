extends TileMap

# bring in our global action list
onready var global_action_list = get_node("/root/Actions")

# bring in our items
onready var global_items_list = get_node("/root/Items")

const ACTIONS = {
	0: 'FISH_SPOT_1',
	1: 'FISH_SPOT_2',
	2: 'WOODCUTTING_SPOT_1',
	3: 'WOODCUTTING_SPOT_2'
}

# keep track of the kind of resources that can be gained on specific action spots
onready var ITEMS_AT_SPOT = {
	'FISH_SPOT_1': [global_items_list.item_musclefish],
	'FISH_SPOT_2': [],
	'WOODCUTTING_SPOT_1': [global_items_list.item_softwood],
	'WOODCUTTING_SPOT_2': []
}

# specific actions associated with these tiles
onready var associated_actions = {
	'FISH_SPOT_1': global_action_list.COMPLETE_ACTION_LIST.FISH,
	'FISH_SPOT_2': global_action_list.COMPLETE_ACTION_LIST.FISH,
	'WOODCUTTING_SPOT_1': global_action_list.COMPLETE_ACTION_LIST.CHOP,
	'WOODCUTTING_SPOT_2': global_action_list.COMPLETE_ACTION_LIST.CHOP
}

# list of actions in which still apply when adjacent
onready var adjacent_applicable = [
	global_action_list.COMPLETE_ACTION_LIST.FISH
]

func get_action_spot_at_coordinates(vec2):
	var tile = get_cellv(vec2)
	if (tile >= 0):
		return ACTIONS[get_cellv(vec2)]
	else:
		return null
		
func get_action_at_spot(spot):
	return associated_actions[spot]

func get_action_at_coordinates(vec2):
	var tile = get_cellv(vec2)
	if (tile >= 0):
		return associated_actions[ACTIONS[get_cellv(vec2)]]
	else:
		return null

func get_items_at_spot(spot):
	return ITEMS_AT_SPOT[spot]
	
	

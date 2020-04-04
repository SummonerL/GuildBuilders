extends TileMap

# bring in our global action list
onready var global_action_list = get_node("/root/Actions")

const ICONS = {
	14: 'FISH',
	15: 'MINE',
	16: 'CHOP'
}

# list of actions in which still apply when adjacent
onready var adjacent_applicable = [
	global_action_list.COMPLETE_ACTION_LIST.FISH
]

# actions associated with these icons
onready var associated_actions = {
	'FISH': global_action_list.COMPLETE_ACTION_LIST.FISH,
	'MINE': global_action_list.COMPLETE_ACTION_LIST.MINE,
	'CHOP': global_action_list.COMPLETE_ACTION_LIST.CHOP
}

func get_icon_at_coordinates(vec2):
	var tile = get_cellv(vec2)
	if (tile >= 0):
		return ICONS[get_cellv(vec2)]
	else:
		return null

func get_action_at_coordinates(vec2):
	var tile = get_cellv(vec2)
	if (tile >= 0):
		return associated_actions[ICONS[get_cellv(vec2)]]
	else:
		return null

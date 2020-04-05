extends Node

# this file will keep track of all of the actions that are available to a unit
# some of these actions will be available only when specific conditions are met, 
# such as being on a tile with a map icon (woodcutting, fishing, etc)

# bring in our items
onready var global_items_list = get_node("/root/Items")

# bring in the global player variables
onready var player = get_node("/root/Player_Globals")

enum COMPLETE_ACTION_LIST {
	MOVE,
	FISH,
	MINE,
	CHOP,
	INFO
}

const ACTION_LIST_NAMES = [
	'MOVE',
	'FISH',
	'MINE',
	'CHOP',
	'INFO'
]

func do_action(action, unit):
	match (action):
		COMPLETE_ACTION_LIST.MOVE:
			# let the unit handle this action
			unit.do_action(action)
		COMPLETE_ACTION_LIST.FISH:
			initiate_fish_action(unit)
		COMPLETE_ACTION_LIST.MINE:
			pass
		COMPLETE_ACTION_LIST.CHOP:
			pass
		COMPLETE_ACTION_LIST.INFO:
			# let the unit handle this action
			unit.do_action(action)

func initiate_fish_action(unit):
	# first, determine if the unit has a fishing rod
	var rod = null
	for item in unit.current_items:
		if (item.type == global_items_list.ITEM_TYPES.ROD):
			rod = item
	
	if (rod):
		print('CAN FISH')
	else:
		player.hud.typeTextWithBuffer(unit.CANT_FISH_WITHOUT_ROD)

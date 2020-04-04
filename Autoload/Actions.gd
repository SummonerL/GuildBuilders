extends Node

# this file will keep track of all of the actions that are available to a unit
# some of these actions will be available only when specific conditions are met, 
# such as being on a tile with a map icon (woodcutting, fishing, etc)

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

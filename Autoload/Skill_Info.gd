extends Node

# variables functions for keeping track of skill information,
# such as level requirements, recipes, etc.

# bring in our constants
onready var constants = get_node("/root/Game_Constants")

# bring in our items
onready var global_item_list = get_node("/root/Items")

enum UNLOCK_TYPES {
	RECIPE,
	ABILITY,
	RESOURCE
}

# global list of skill unlocks
onready var SKILL_UNLOCKS = {
	
	# woodcutting
	constants.WOODWORKING: [
		{
			'unlock_text': ' can now chop Ash Trees!',
			'type': UNLOCK_TYPES.RESOURCE,
			'level_required': 2,
		}
	],
	
	
	# woodworking
	constants.WOODWORKING: [
		{
			'type': UNLOCK_TYPES.RECIPE,
			'level_required': 1,
			'item': global_item_list.item_wooden_handle,
			'no_tool_required': true,
			'resources_required': [
				{
					'item': global_item_list.item_cedar_logs,
					'quantity': 1
				}
			]
		},
		{
			'unlock_text': ' can now craft Flexible Rods!',
			'type': UNLOCK_TYPES.RECIPE,
			'level_required': 2,
			'item': global_item_list.item_flexible_rod,
			'resources_required': [
				{
					'item': global_item_list.item_ash_logs,
					'quantity': 2
				}
			]
		},
		{
			'unlock_text': ' can now craft Wooden Stilts!',
			'type': UNLOCK_TYPES.RECIPE,
			'level_required': 3,
			'item': global_item_list.item_wooden_stilts,
			'resources_required': [
				{
					'item': global_item_list.item_fir_logs,
					'quantity': 2
				}
			]
		},
		{
			'unlock_text': ' can now craft Walking Sticks!',
			'type': UNLOCK_TYPES.RECIPE,
			'level_required': 5,
			'item': global_item_list.item_walking_stick,
			'resources_required': [
				{
					'item': global_item_list.item_hardwood,
					'quantity': 2
				}
			]
		}
	]
}

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
	RESOURCE,
	TOOL
}

# global list of skill unlocks
onready var SKILL_UNLOCKS = {
	# fishing
	constants.FISHING: [
		{
			'unlock_text': ' can now catch Jumbofish!',
			'skill_info_text': 'Can catch Jumbofish',
			'type': UNLOCK_TYPES.RESOURCE,
			'level_required': 1,
		}
	],
	
	
	# woodcutting
	constants.WOODCUTTING: [
		{
			'unlock_text': ' can now chop Cedar Trees!',
			'skill_info_text': 'Can chop Cedar Trees',
			'type': UNLOCK_TYPES.RESOURCE,
			'level_required': 1,
		},
		{
			'unlock_text': ' can now chop Ash Trees!',
			'skill_info_text': 'Can chop Ash Trees',
			'type': UNLOCK_TYPES.RESOURCE,
			'level_required': 2,
		},
		{
			'unlock_text': ' can now chop Fir Trees!',
			'skill_info_text': 'Can chop Fir Trees',
			'type': UNLOCK_TYPES.RESOURCE,
			'level_required': 3,
		}
	],
	
	
	# woodworking
	constants.WOODWORKING: [
		{
			'skill_info_text': 'Can craft Wooden Handles',
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
			'skill_info_text': 'Can craft Flexible Rods',
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
			'skill_info_text': 'Can craft Wooden Stilts',
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
			'skill_info_text': 'Can craft Walking Sticks',
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

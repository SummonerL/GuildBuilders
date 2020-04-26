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
			'can_text': 'Catch',
			'skill_info_text': 'Jumbofish',
			'type': UNLOCK_TYPES.RESOURCE,
			'level_required': 1,
		}
	],
	
	
	# woodcutting
	constants.WOODCUTTING: [
		{
			'unlock_text': ' can now chop Cedar Trees!',
			'can_text': 'Chop',
			'skill_info_text': 'Cedar Trees',
			'type': UNLOCK_TYPES.RESOURCE,
			'level_required': 1,
		},
		{
			'unlock_text': ' can now chop Ash Trees!',
			'can_text': 'Chop',
			'skill_info_text': 'Ash Trees',
			'type': UNLOCK_TYPES.RESOURCE,
			'level_required': 2,
		},
		{
			'unlock_text': ' can now chop Fir Trees!',
			'can_text': 'Chop',
			'skill_info_text': 'Fir Trees',
			'type': UNLOCK_TYPES.RESOURCE,
			'level_required': 3,
		}
	],
	
	
	# woodworking
	constants.WOODWORKING: [
		{
			'can_text': 'Craft',
			'skill_info_text': 'Wooden Handle',
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
			'can_text': 'Craft',
			'skill_info_text': 'Flexible Rod',
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
			'can_text': 'Craft',
			'skill_info_text': 'Wooden Stilts',
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
			'can_text': 'Craft',
			'skill_info_text': 'Walking Stick',
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

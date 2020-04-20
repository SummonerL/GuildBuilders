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
	# woodworking
	constants.WOODWORKING: {
		1: [
			{
				'type': UNLOCK_TYPES.RECIPE,
				'item': global_item_list.item_wooden_handle,
				'no_tool_required': true,
				'resources_required': [
					{
						'item': global_item_list.item_softwood,
						'quantity': 1
					}
				]
			},
			{
				'type': UNLOCK_TYPES.RECIPE,
				'item': global_item_list.item_wooden_handle,
				'no_tool_required': true,
				'resources_required': [
					{
						'item': global_item_list.item_softwood,
						'quantity': 1
					}
				]
			},
			{
				'type': UNLOCK_TYPES.RECIPE,
				'item': global_item_list.item_wooden_handle,
				'no_tool_required': true,
				'resources_required': [
					{
						'item': global_item_list.item_softwood,
						'quantity': 1
					}
				]
			},
			{
				'type': UNLOCK_TYPES.RECIPE,
				'item': global_item_list.item_wooden_handle,
				'no_tool_required': true,
				'resources_required': [
					{
						'item': global_item_list.item_softwood,
						'quantity': 1
					}
				]
			}
		],
		5: [
			{
				'type': UNLOCK_TYPES.RECIPE,
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
	
}

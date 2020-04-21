extends Node

# this file will keep track of the items that a unit can obtain throughout the course of the game
# each item should consist of a name, description, type, and any other properties specific to the item type

# bring in our abilities
onready var global_ability_list = get_node("/root/Abilities")

enum ITEM_TYPES {
	ROD	,
	AXE,
	SAW,
	FISH,
	WOOD,
	CRAFTING_PART,
	UTILITY
}

# tools
onready var item_softwood_rod = {
	"name": "Softwood Rod",
	"description": "A simple wooden fishing rod. Allows the unit to catch fish.",
	"type": ITEM_TYPES.ROD
}

onready var item_sturdy_axe = {
	"name": "Sturdy Axe",
	"description": "A simple stone axe. Allows the unit to gather wood.",
	"type": ITEM_TYPES.AXE
}

onready var item_handsaw = {
	"name": "Handsaw",
	"description": "A basic handsaw. Allows the unit to work with wood.",
	"type": ITEM_TYPES.SAW,
	"xp": 3 # xp upon crafting
}

# useful objects
onready var item_walking_stick = {
	"name": "Walking Stick",
	"description": "A sturdy walking stick made of hardwood. Increases a unit\'s movement by 1 when held. This effect can only be gained once.",
	"type": ITEM_TYPES.UTILITY,
	"xp": 5, # xp upon receiving
}

# fish
onready var item_musclefish = {
	"name": "Musclefish",
	"description": "Eating this will allow the unit to carry an additional 3 items that day.",
	"type": ITEM_TYPES.FISH,
	"xp": 2, # xp upon receiving
	"connected_ability": global_ability_list.ability_food_musclefish
}

# wood
onready var item_softwood = {
	"name": "Softwood",
	"description": "A light-colored wood that is easy to cut. Can be used to craft various items.",
	"type": ITEM_TYPES.WOOD,
	"xp": 2 # xp upon receiving
}

onready var item_hardwood = {
	"name": "Hardwood",
	"description": "A dark, heavy wood that takes some effort to cut through. Can be used to craft various items.",
	"type": ITEM_TYPES.WOOD,
	"xp": 3 # xp upon receiving
}

# misc crafting materials
onready var item_wooden_handle = {
	"name": "Wooden Handle",
	"description": "A handle made of softwood. Can be used to craft various items.",
	"type": ITEM_TYPES.CRAFTING_PART,
	"xp": 2
}

# a helper function for adding items to a unit
func add_item_to_unit(unit, item):
	
	# determine if the unit's stats should be modified based on the item
	
	unit.current_items.append(item)
	
# a helper function for removing items from a unit
func remove_item_from_unit(unit, _item, index):
	unit.current_items.remove(index)

# a helper function for determining if a unit has a given tool type
func unit_has_tool(unit, tool_type):
	
	var found_item_index = -1
	var index = 0
	# returns the (index of) the best version of that tool that the unit has
	for item in unit.current_items:
		if (item.type == tool_type):
			found_item_index = index
		index += 1
		
	return found_item_index

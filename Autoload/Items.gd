extends Node

# this file will keep track of the items that a unit can obtain throughout the course of the game
# each item should consist of a name, description, type, and any other properties specific to the item type

enum ITEM_TYPES {
	ROD	
}

const item_softwood_rod = {
	"name": "Softwood Rod",
	"description": "A simple wooden fishing rod. Allows the unit to catch fish.",
	"type": ITEM_TYPES.ROD
}

# a helper function for adding items to a unit
func add_item_to_unit(unit, item):
	unit.current_items.append(item)
	
# a helper function for removing items from a unit
func remove_item_from_ubnit(unit, item, index):
	unit.current_items.remove(index)

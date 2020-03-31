extends Node

# this file will keep track of the items that the player can obtain throughout the course of the game
# each item should consist of a name, description, type, and any other properties specific to the item type

enum ITEM_TYPES {
	ROD	
}

const item_softwood_rod = {
	"name": "Softwood Rod",
	"description": "A simple wooden fishing rod. Allows the unit to catch fish.",
	"type": ITEM_TYPES.ROD
}

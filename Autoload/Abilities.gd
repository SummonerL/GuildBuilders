extends Node

# this file will keep track of the abilities that a unit can gain throughout the course of the game
# each ability should consist of a name, description and any other properties specific to the item type

# bring in our global action list
onready var global_action_list = get_node("/root/Actions")

enum ABILITY_TYPES {
	UNIT,
	FOOD
}

const ABILITY_INSOMNIAC_NAME = 'Insomniac'
const ABILITY_ROUGHING_IT_NAME = 'Roughing It'
const ABILITY_GROWING_BOY_NAME = 'Growing Boy'

# food (daily) abilities
const ABILITY_FOOD_MUSCLEFISH_NAME = 'Food Effect'

# unit abilities
const ability_insomniac = {
	"name": ABILITY_INSOMNIAC_NAME,
	"description": "This unit wakes up at 3AM.",
	"type": ABILITY_TYPES.UNIT
}

const ability_roughing_it = {
	"name": ABILITY_ROUGHING_IT_NAME,
	"description": "This unit does not have to return home at night.",
	"type": ABILITY_TYPES.UNIT
}

const ability_growing_boy = {
	"name": ABILITY_GROWING_BOY_NAME,
	"description": "This unit can benefit from an additional meal every day.",
	"type": ABILITY_TYPES.UNIT
}

# food (daily) abilities
const ability_food_musclefish = {
	"name": ABILITY_FOOD_MUSCLEFISH_NAME,
	"description": "This unit can carry an additional 3 items for the remainder of the day.",
	"type": ABILITY_TYPES.FOOD
}

# a helper function for adding abilities to a unit
func add_ability_to_unit(unit, ability):
	unit.unit_abilities.append(ability)
	
	on_add_to_unit(unit, ability)
	
# a helper function for removing abilities from a unit
func remove_ability_from_unit(unit, ability, index):
	unit.unit_abilities.remove(index)
	
	on_remove_from_unit(unit, ability)

# when a specific ability is added to a unit
func on_add_to_unit(unit, ability):
	match(ability.name):
		ABILITY_INSOMNIAC_NAME:
			unit.wake_up_time = 3
		ABILITY_ROUGHING_IT_NAME:
			# add the 'camp' option to their list of locations to return to
			unit.shelter_locations.append(global_action_list.COMPLETE_ACTION_LIST.RETURN_TO_CAMP)
		ABILITY_FOOD_MUSCLEFISH_NAME:
			# add 3 to the unit's max inventory space
			unit.item_limit += 3
		ABILITY_GROWING_BOY_NAME:
			# increase the unit's meal limit by 1
			unit.meal_limit += 1

# when a specific ability is removed from a unit
func on_remove_from_unit(unit, ability):
	match(ability.name):
		ABILITY_FOOD_MUSCLEFISH_NAME:
			# remove 3 from the unit's max inventory space
			unit.item_limit -= 3
			if (unit.item_limit < 0):
				unit.item_limit = 0

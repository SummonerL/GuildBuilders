extends Node

# this file will keep track of the abilities that a unit can gain throughout the course of the game
# each ability should consist of a name, description and any other properties specific to the item type

# bring in our global action list
onready var global_action_list = get_node("/root/Actions")

const ABILITY_INSOMNIAC_NAME = 'Insomniac'
const ABILITY_ROUGHING_IT_NAME = 'Roughing It'
const ABILITY_GROWING_BOY_NAME = 'Growing Boy'

const ability_insomniac = {
	"name": ABILITY_INSOMNIAC_NAME,
	"description": "This unit wakes up at 3AM."
}

const ability_roughing_it = {
	"name": ABILITY_ROUGHING_IT_NAME,
	"description": "This unit does not have to return home at night."
}

const ability_growing_boy = {
	"name": ABILITY_GROWING_BOY_NAME,
	"description": "This unit can benefit from an additional meal every day."
}

# a helper function for adding abilities to a unit
func add_ability_to_unit(unit, ability):
	unit.unit_abilities.append(ability)
	
	on_add_to_unit(unit, ability)
	
# a helper function for removing abilities from a unit
func remove_ability_from_ubnit(unit, ability, index):
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

# when a specific ability is removed from a unit
func on_remove_from_unit(_unit, _ability):
	pass

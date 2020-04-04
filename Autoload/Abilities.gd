extends Node

# this file will keep track of the abilities that a unit can gain throughout the course of the game
# each ability should consist of a name, description and any other properties specific to the item type

const ABILITY_EARLY_RISER_NAME = 'Early Riser'
const ABILITY_ROUGHING_IT = 'Roughing It'
const ABILITY_GROWING_BOY = 'Growing Boy'

const ability_early_riser = {
	"name": ABILITY_EARLY_RISER_NAME,
	"description": "This unit wakes up 3 hours earlier than usual."
}

const ability_roughing_it = {
	"name": ABILITY_ROUGHING_IT,
	"description": "This unit does not have to return home at night."
}

const ability_growing_boy = {
	"name": ABILITY_GROWING_BOY,
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
		ABILITY_EARLY_RISER_NAME:
			unit.wake_up_time -= 3

# when a specific ability is removed from a unit
func on_remove_from_unit(_unit, _ability):
	pass

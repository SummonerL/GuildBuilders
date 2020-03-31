extends Node

# this file will keep track of the abilities that a unit can gain throughout the course of the game
# each ability should consist of a name, description and any other properties specific to the item type

const ABILITY_RELIABLE_NAME = 'Reliable'

const ability_reliable = {
	"name": ABILITY_RELIABLE_NAME,
	"description": "This unit wakes up 3 hours earlier than usual."
}

# a helper function for adding abilities to a unit
func add_ability_to_unit(unit, ability):
	unit.unit_abilities.append(ability)
	
	on_add_to_unit(unit, ability)

# when a specific ability is added to a unit
func on_add_to_unit(unit, ability):
	match(ability.name):
		ABILITY_RELIABLE_NAME:
			unit.wake_up_time -= 3

# when a specific ability is removed from a unit
func on_remove_from_unit(unit, ability):
	pass

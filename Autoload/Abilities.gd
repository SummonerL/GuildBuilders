extends Node

# this file will keep track of the abilities that a unit can gain throughout the course of the game
# each ability should consist of a name, description and any other properties specific to the item type

# bring in our global action list
onready var global_action_list = get_node("/root/Actions")

enum ABILITY_TYPES {
	UNIT,
	FOOD,
	DAILY
}

const ABILITY_INSOMNIAC_NAME = 'Insomniac'
const ABILITY_ROUGHING_IT_NAME = 'Roughing It'
const ABILITY_GROWING_BOY_NAME = 'Growing Boy'
const ABILITY_ARTISTIC_NAME = 'Artistic'
const ABILITY_CONCENTRATION_NAME = 'Concentration'
const ABILITY_RIVER_QUEEN_NAME = 'River Queen'

# food (daily) abilities
const ABILITY_FOOD_MUSCLEFISH_NAME = 'Food Effect'

# other daily abilities
const ABILITY_INSPIRED_NAME = 'Inspired'
const ABILITY_HUNGRY_NAME = 'Hungry'

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

const ability_artistic = {
	"name": ABILITY_ARTISTIC_NAME,
	"description": "When crafting at the guild, all other units at the guild become Inspired (their movement increases by 1 for the remainder of the day).",
	"type": ABILITY_TYPES.UNIT
}

const ability_concentration = {
	"name": ABILITY_CONCENTRATION_NAME,
	"description": "When crafting at the guild, this unit receives double XP. However, this unit must be the only unit at the guild to receive this bonus.",
	"type": ABILITY_TYPES.UNIT
}

const ability_river_queen = {
	"name": ABILITY_RIVER_QUEEN_NAME,
	"description": "This unit can jump over rivers.",
	"type": ABILITY_TYPES.UNIT
}

# food (daily) abilities
const ability_food_musclefish = {
	"name": ABILITY_FOOD_MUSCLEFISH_NAME,
	"description": "This unit can carry an additional 3 items for the remainder of the day.",
	"type": ABILITY_TYPES.FOOD
}

# other daily abilities
const ability_inspired = {
	"name": ABILITY_INSPIRED_NAME,
	"description": "This unit\'s movement is increased by 1 for the remainder of the day.",
	"type": ABILITY_TYPES.DAILY
}

const ability_hungry = {
	"name": ABILITY_HUNGRY_NAME,
	"description": "This unit cannot use it\'s starting ability.",
	"type": ABILITY_TYPES.DAILY
}


# a helper function for adding abilities to a unit
func add_ability_to_unit(unit, ability, front = false):
	if (front):
		unit.unit_abilities.insert(0, ability)
	else:
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
			unit.wake_up_time -= 5
		ABILITY_ROUGHING_IT_NAME:
			# add the 'camp' option to their list of locations to return to
			unit.shelter_locations.append(global_action_list.COMPLETE_ACTION_LIST.RETURN_TO_CAMP)
		ABILITY_GROWING_BOY_NAME:
			# increase the unit's meal limit by 1
			unit.meal_limit += 1
			
			
		ABILITY_FOOD_MUSCLEFISH_NAME:
			# add 3 to the unit's max inventory space
			unit.item_limit += 3		
			
				
		ABILITY_INSPIRED_NAME:
			# increases the unit's movement by 1
			unit.base_move += 1
		ABILITY_HUNGRY_NAME:
			# remove the unit's starting ability
			var index = 0
			var starting_ability_index = -1
			var starting_ability = null
			for abil in unit.unit_abilities:
				if (abil.type == ABILITY_TYPES.UNIT):
					starting_ability_index = index
					starting_ability = abil
				index += 1
				
			if (starting_ability_index >= 0):
				remove_ability_from_unit(unit, starting_ability, starting_ability_index)

# when a specific ability is removed from a unit
func on_remove_from_unit(unit, ability):
	match(ability.name):
		ABILITY_INSOMNIAC_NAME:
					unit.wake_up_time += 5
		ABILITY_ROUGHING_IT_NAME:
			# remove the 'camp' option from their list of locations to return to
			var location_index = 0
			for location in unit.shelter_locations:
				if (location == global_action_list.COMPLETE_ACTION_LIST.RETURN_TO_CAMP):
					unit.shelter_locations.remove(location_index)
					return
				location_index += 1
		ABILITY_GROWING_BOY_NAME:
			# increase the unit's meal limit by 1
			unit.meal_limit -= 1
			if (unit.meal_limit <= 0):
				unit.meal_limit = 0
			

		ABILITY_FOOD_MUSCLEFISH_NAME:
			# remove 3 from the unit's max inventory space
			unit.item_limit -= 3
			if (unit.item_limit < 0):
				unit.item_limit = 0
				
				
		ABILITY_INSPIRED_NAME:
			# remove 1 from the unit's base_move
			unit.base_move -= 1
			if (unit.base_move < 0):
				unit.base_move = 0
		ABILITY_HUNGRY_NAME:
			# add the unit's starting ability back
			add_ability_to_unit(unit, unit.starting_ability, true)

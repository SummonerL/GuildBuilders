extends Node

# this file will keep track of the abilities that a unit can gain throughout the course of the game
# each ability should consist of a name, description and any other properties specific to the item type

# bring in our global action list
onready var global_action_list = get_node("/root/Actions")

# bring in our items
onready var global_items_list = get_node("/root/Items")

enum ABILITY_TYPES {
	UNIT,
	FOOD,
	DAILY,
	HUNGER
}

const ABILITY_INSOMNIAC_NAME = 'Insomniac'
const ABILITY_ROUGHING_IT_NAME = 'Roughing It'
const ABILITY_GROWING_BOY_NAME = 'Growing Boy'
const ABILITY_ARTISTIC_NAME = 'Artistic'
const ABILITY_CONCENTRATION_NAME = 'Concentration'
const ABILITY_RIVER_QUEEN_NAME = 'River Queen'
const ABILITY_TUNNELER_NAME = 'Tunneler'
const ABILITY_GEM_HUNTER_NAME = 'Gem Hunter'

# food (daily) abilities
const ABILITY_WELL_FED_NAME = 'Status: Well-Fed'
const ABILITY_FED_NAME = 'Status: Fed'
const ABILITY_FOOD_MUSCLEFISH_NAME = 'Food Effect'
const ABILITY_FOOD_CATFISH_NAME = 'Food Effect'

# other daily abilities
const ABILITY_INSPIRED_NAME = 'Status: Inspired'
const ABILITY_HUNGRY_NAME = 'Status: Hungry'
const ABILITY_ECSTATIC_NAME = 'Status: Ecstatic'
const ABILITY_CALM_NAME = 'Status: Calm'
const ABILITY_RELAXED_NAME = 'Status: Relaxed'
const ABILITY_SENSE_OF_DUTY_NAME = 'A Sense of Duty'

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
	"description": "This unit can jump over rivers and other small bodies of water.",
	"type": ABILITY_TYPES.UNIT
}

const ability_tunneler = {
	"name": ABILITY_TUNNELER_NAME,
	"description": "This unit can travel between caves in the same region.",
	"type": ABILITY_TYPES.UNIT
}

const ability_gem_hunter = {
	"name": ABILITY_GEM_HUNTER_NAME,
	"description": "When this unit finds a gemstone, it becomes ecstatic (its movement increases by 4 for the remainder of the day).",
	"type": ABILITY_TYPES.UNIT
}



# food (daily) abilities
const ability_well_fed = {
	"name": ABILITY_WELL_FED_NAME,
	"description": "This unit does not have to eat for the next 2 days.",
	"type": ABILITY_TYPES.FOOD
}
const ability_fed = {
	"name": ABILITY_FED_NAME,
	"description": "This unit does not have to eat until tomorrow. ",
	"type": ABILITY_TYPES.FOOD
}

const ability_food_musclefish = {
	"name": ABILITY_FOOD_MUSCLEFISH_NAME,
	"description": "This unit can carry an additional 3 items for the remainder of the day.",
	"type": ABILITY_TYPES.FOOD
}

const ability_food_catfish = {
	"name": ABILITY_FOOD_CATFISH_NAME,
	"description": "For the remainder of the day, petting cats will grant this unit an additional 'Relaxed' effect (10% bonus XP).",
	"type": ABILITY_TYPES.FOOD
}

# daily abilities
const ability_inspired = {
	"name": ABILITY_INSPIRED_NAME,
	"description": "This unit\'s movement is increased by 1 for the remainder of the day.",
	"type": ABILITY_TYPES.DAILY
}

const ability_ecstatic = {
	"name": ABILITY_ECSTATIC_NAME,
	"description": "This unit\'s movement is increased by 4 for the remainder of the day.",
	"type": ABILITY_TYPES.DAILY
}

const ability_calm = {
	"name": ABILITY_CALM_NAME,
	"description": "This unit receives 10% more XP for the remainder of the day.",
	"type": ABILITY_TYPES.DAILY
}

const ability_relaxed = {
	"name": ABILITY_RELAXED_NAME,
	"description": "This unit receives 10% more XP for the remainder of the day.",
	"type": ABILITY_TYPES.DAILY
}

const ability_a_sense_of_duty = {
	"name": ABILITY_SENSE_OF_DUTY_NAME,
	"description": "This unit woke up 2 hours earlier than usual.",
	"type": ABILITY_TYPES.DAILY
}

# hunger ability
const ability_hungry = {
	"name": ABILITY_HUNGRY_NAME,
	"description": "This unit cannot use it\'s starting ability.",
	"type": ABILITY_TYPES.HUNGER
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
	# as some abilities may be gained during the removal of others, return an array containing any new abilities
	# instead of adding them immediately, allow the caller to handle that.
	var gained_abilities = []
	
	unit.unit_abilities.remove(index)
	
	gained_abilities += on_remove_from_unit(unit, ability)
	
	return gained_abilities

# when a specific ability is added to a unit
func on_add_to_unit(unit, ability):
	match(ability.name):
		# unit abilities
		ABILITY_INSOMNIAC_NAME:
			unit.wake_up_time -= 5
		ABILITY_ROUGHING_IT_NAME:
			# add the 'camp' option to their list of locations to return to
			unit.shelter_locations.append(global_action_list.COMPLETE_ACTION_LIST.RETURN_TO_CAMP)
		ABILITY_GROWING_BOY_NAME:
			# increase the unit's meal limit by 1
			unit.meal_limit += 1
		ABILITY_TUNNELER_NAME:
			# add the tunneling action to the unit
			unit.extra_actions.append(global_action_list.COMPLETE_ACTION_LIST.TUNNEL)
		ABILITY_RIVER_QUEEN_NAME:
			# add the 'cross' action to the unit (if it doesn't already exist)
			if (!unit.extra_actions.has(global_action_list.COMPLETE_ACTION_LIST.CROSS)):
				unit.extra_actions.append(global_action_list.COMPLETE_ACTION_LIST.CROSS)
			
		# food abilities / effects
		ABILITY_WELL_FED_NAME:
			# add remove 'fed' ability from the player, if it exists (to prevent confusion)
			var index = 0
			var fed_ability_index = -1
			for abil in unit.unit_abilities:
				if (abil.name == ABILITY_FED_NAME):
					fed_ability_index = index
				index += 1
				
			if (fed_ability_index >= 0):
				remove_ability_from_unit(unit, ability_fed, fed_ability_index)
		ABILITY_FOOD_MUSCLEFISH_NAME:
			# add 3 to the unit's max inventory space
			unit.item_limit += 3		
			
				
		# daily abilities / effects / statuses
		ABILITY_INSPIRED_NAME:
			# increases the unit's movement by 1
			unit.base_move += 1
		ABILITY_ECSTATIC_NAME:
			# increases the unit's movement by 4
			unit.base_move += 4
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
		ABILITY_CALM_NAME:
			# the unit receives 10% more XP for the rest of the day
			unit.general_bonus_xp += .1
		ABILITY_RELAXED_NAME:
			# the unit receives 10% more XP for the rest of the day
			unit.general_bonus_xp += .1
		ABILITY_SENSE_OF_DUTY_NAME:
			unit.wake_up_time -= 2

# when a specific ability is removed from a unit
func on_remove_from_unit(unit, ability):
	# as some abilities may be gained during the removal of others, return an array containing any new abilities
	# instead of adding them immediately, allow the caller to handle that.
	var gained_abilities = []
	
	match(ability.name):
		# unit abilities
		ABILITY_INSOMNIAC_NAME:
					unit.wake_up_time += 5
		ABILITY_ROUGHING_IT_NAME:
			# remove the 'camp' option from their list of locations to return to
			var location_index = 0
			for location in unit.shelter_locations:
				if (location == global_action_list.COMPLETE_ACTION_LIST.RETURN_TO_CAMP):
					unit.shelter_locations.remove(location_index)
					return gained_abilities
				location_index += 1
		ABILITY_GROWING_BOY_NAME:
			# increase the unit's meal limit by 1
			unit.meal_limit -= 1
			if (unit.meal_limit <= 0):
				unit.meal_limit = 0
		ABILITY_TUNNELER_NAME:
			# remove the tunneling action from the unit
			var action_index = 0
			for action in unit.extra_actions:
				if (action == global_action_list.COMPLETE_ACTION_LIST.TUNNEL):
					unit.extra_actions.remove(action_index)
					return gained_abilities
				action_index += 1
		ABILITY_RIVER_QUEEN_NAME:
			# remove the 'cross' action from the unit (if the unit doesn't have wooden stilts)
			if (global_items_list.unit_has_item(unit, global_items_list.item_wooden_stilts, 1).size() > 0):
				var action_index = 0
				for action in unit.extra_actions:
					if (action == global_action_list.COMPLETE_ACTION_LIST.CROSS):
						unit.extra_actions.remove(action_index)
						return gained_abilities
					action_index += 1

		# food abilities / effects
		ABILITY_WELL_FED_NAME:
			# add the 'fed' ability to the player
			gained_abilities.append(ability_fed)
		ABILITY_FOOD_MUSCLEFISH_NAME:
			# remove 3 from the unit's max inventory space
			unit.item_limit -= 3
			if (unit.item_limit < 0):
				unit.item_limit = 0
				
				
		# daily abilities / effects / statuses
		ABILITY_INSPIRED_NAME:
			# remove 1 from the unit's base_move
			unit.base_move -= 1
			if (unit.base_move < 0):
				unit.base_move = 0
		ABILITY_ECSTATIC_NAME:
			# remove 4 from the unit's base_move
			unit.base_move -= 4
			if (unit.base_move < 0):
				unit.base_move = 0
		ABILITY_HUNGRY_NAME:
			# add the unit's starting ability back
			add_ability_to_unit(unit, unit.starting_ability, true)
		ABILITY_CALM_NAME:
			# remove the additional bonus XP the unit received
			unit.general_bonus_xp -= .1
		ABILITY_RELAXED_NAME:
			# remove the additional bonus XP the unit received
			unit.general_bonus_xp -= .1
		ABILITY_SENSE_OF_DUTY_NAME:
			unit.wake_up_time += 2
			
	return gained_abilities
	
# useful function for determining whether or not a unit has an ability
func unit_has_ability(unit, ability):
	var has_ability = false
	
	for abil in unit.unit_abilities:
		if (ability == abil.name):
			has_ability = true
			
	return has_ability
	

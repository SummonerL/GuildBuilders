extends Node

# this file will keep track of the items that a unit can obtain throughout the course of the game
# each item should consist of a name, description, type, and any other properties specific to the item type

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in our abilities
onready var global_ability_list = get_node("/root/Abilities")

# bring in our global action list
onready var global_action_list = get_node("/root/Actions")

# bring in our signals
onready var signals = get_node("/root/Signal_Manager")

# bring in the global player variables
onready var player = get_node("/root/Player_Globals")

# bring in our guild variables/functions
onready var guild = get_node("/root/Guild")

onready var map_actions = get_tree().get_nodes_in_group(constants.MAP_ACTIONS_GROUP)[0]

enum ITEM_TYPES {
	ROD	,
	AXE,
	PICKAXE,
	SAW,
	HAMMER,
	SCISSORS,
	TAPPER,
	FISH,
	WOOD,
	ORE,
	GEM,
	CLOTHING,
	CRAFTING_PART,
	UTILITY,
	DIPLOMATIC_GIFT,
}

const BROKE_TEXT = ' broke...'

# tools
onready var item_flexible_rod = {
	"name": "Flexible Rod",
	"description": "A simple fishing rod made from ash wood. Allows the unit to catch fish.",
	"type": ITEM_TYPES.ROD,
	"can_discard": true,
	"xp": 3 # xp upon crafting
}

onready var item_sturdy_axe = {
	"name": "Sturdy Axe",
	"description": "A simple stone axe. Allows the unit to gather wood.",
	"type": ITEM_TYPES.AXE,
	"can_discard": true,
	"xp": 2
}

onready var item_sturdy_pickaxe = {
	"name": "Sturdy Pickaxe",
	"description": "A simple stone pickaxe. Allows the unit to mine for ore. 5% chance of finding a gemstone.",
	"type": ITEM_TYPES.PICKAXE,
	"level_required": 1,
	"can_discard": true,
	"xp": 2,
	"gemstone_chance": 5 # chance of collecting a gemstone when mining
}

onready var item_handsaw = {
	"name": "Handsaw",
	"description": "A basic handsaw. Allows the unit to work with wood.",
	"type": ITEM_TYPES.SAW,
	"can_discard": true,
	"xp": 2 # xp upon crafting
}

onready var item_hammer = {
	"name": "Hammer",
	"description": "A basic hammer. Allows the unit to smith various items.",
	"type": ITEM_TYPES.HAMMER,
	"can_discard": true,
	"xp": 2 # xp upon crafting
}

onready var item_scissors = {
	"name": "Scissors",
	"description": "A pair of metal scissors. Allows the unit to fashion various items.",
	"type": ITEM_TYPES.SCISSORS,
	"can_discard": true,
	"xp": 3 # xp upon crafting
}

onready var item_tree_tapper = {
	"name": "Tree Tapper",
	"description": "A small, metal tube used to collect resources from certain trees.",
	"type": ITEM_TYPES.TAPPER,
	"can_discard": true,
	"xp": 3 # xp upon crafting
}


# useful objects
onready var item_wooden_stilts = {
	"name": "Wooden Stilts",
	"description": "Sturdy wooden legs that allow a unit to cross rivers and other small bodies of water. This item can only be used once.",
	"type": ITEM_TYPES.UTILITY,
	"can_discard": true,
	"can_stack_effect": false,
	"stat_effected": "extra_actions",
	"stat_effected_value": [global_action_list.COMPLETE_ACTION_LIST.CROSS],
	"duplicate_ability": global_ability_list.ABILITY_RIVER_QUEEN_NAME, # if an ability invalidates this
	"xp": 3, # xp upon receiving
}

onready var item_wooden_pipe = {
	"name": "Wooden Pipe",
	"description": "A hand-crafted pipe made of cedar wood. When used, units become calm (they receive 10% more XP for the remainder of the day).",
	"type": ITEM_TYPES.UTILITY,
	"can_discard": true,
	"can_use": true,
	"use_text": " became calm.",
	"use_ability" : global_ability_list.ability_calm,
	"use_breaks": true, # breaks on use
	"xp": 2, # xp upon receiving
}

onready var item_birdhouse = {
	"name": "Birdhouse",
	"description": "A wooden birdhouse crafted from birch wood. If a birdhouse is placed, there is a 25% chance a bird will be found inside every morning.",
	"type": ITEM_TYPES.UTILITY,
	"can_discard": true,
	"can_use": true,
	"can_place": true,
	"place_type": guild.PLACEABLE_ITEM_TYPES.BIRDHOUSES,
	"associated_l2": "birdhouse", # name of the l2 tile associated with this item (for displaying on the overworld)
	"associated_data": {
		"place_type": guild.PLACEABLE_ITEM_TYPES.BIRDHOUSES,
		"occupied": false,
		"bird_chance": 25, # 25 percent chance of a bird appearing
	},
	"associated_action_spot": "Beast_Mastery_Spot_1", # which action spot gets tagged when placed
	"use_text": " placed the birdhouse.",
	"xp": 3, # xp upon receiving
}
onready var item_walking_stick = {
	"name": "Walking Stick",
	"description": "A sturdy walking stick made of hardwood. Increases a unit\'s movement by 1 when held. This effect can only be gained once.",
	"type": ITEM_TYPES.UTILITY,
	"can_discard": true,
	"can_stack_effect": false, # this effect can not be added more than once
	"stat_effected": "base_move",
	"stat_effected_value": 1,
	"xp": 5, # xp upon receiving
}

onready var item_wooden_basket = {
	"name": "Wooden Basket",
	"description": "A basket made from thin strips of ash wood. Increases the unit\'s inventory space by 4. This effect can only be gained once.",
	"type": ITEM_TYPES.UTILITY,
	"can_discard": true,
	"can_stack_effect": false, # this effect can not be added more than once
	"stat_effected": "item_limit",
	"stat_effected_value": 4,
	"xp": 3, # xp upon receiving
}

onready var item_rubber_boots = { # crafted from latex
	"name": "Rubber Boots",
	"description": "A pair of boots made from rubber. When held, marsh terrain costs 1 less movement.",
	"type": ITEM_TYPES.CLOTHING,
	"can_discard": true,
	"can_stack_effect": false, # this effect can not be added more than once
	"xp": 3, # xp upon receiving
}

onready var item_guild_photo = { # friend wanted - quest reward
	"name": "Guild Photo",
	"description": "An old photograph of the founding members of the guild. As long as this item is in the depot, a random unit at the guild hall will wake up with A Sense of Duty (they will wake up 2 hours earlier than usual).",
	"type": ITEM_TYPES.UTILITY,
	"can_discard": false,
	"depot_ability": guild.GUILD_ABILITIES.RANDOM_UNIT_SENSE_OF_DUTY
}

onready var item_cheap_ring = { # used in diplomacy
	"name": "Cheap Ring",
	"description": "A plain ring made from gold. When held, increases the amount of favor gained during meetings with diplomatic leaders by 1. This effect can only be gained once.",
	"type": ITEM_TYPES.UTILITY,
	"can_discard": true,
	"can_stack_effect": false, # this effect can not be added more than once
	"stat_effected": "diplomacy_points",
	"stat_effected_value": 1,
	"xp": 3, # xp upon receiving
}

onready var item_amethyst_ring = { # used in diplomacy
	"name": "Amethyst Ring",
	"description": "A gold ring with an amethyst setting. When held, increases the amount of favor gained during meetings with diplomatic leaders by 2. This effect can only be gained once.",
	"type": ITEM_TYPES.UTILITY,
	"can_discard": true,
	"can_stack_effect": false, # this effect can not be added more than once
	"stat_effected": "diplomacy_points",
	"stat_effected_value": 2,
	"xp": 3, # xp upon receiving
}

onready var item_letter = { # used for diplomacy
	"name": "Letter",
	"description": "A letter that can be given to any diplomatic leader for 2 points of favor. Letters can be delivered personally or via animal.",
	"type": ITEM_TYPES.DIPLOMATIC_GIFT,
	"favor_increase": 2, # how many points of favor this item gives
	"can_discard": true,
	"xp": 1 # xp to write
}

onready var item_paper = { # used for writing letters
	"name": "Sheet of Paper",
	"description": "A thin strip of birch wood. Use this item to write a diplomatic letter.",
	"can_use": true,
	"triggers_action": global_action_list.COMPLETE_ACTION_LIST.WRITE_LETTER, # using this item triggers another action
	"associated_skill": constants.DIPLOMACY,
	"level_requirement_for_action": 3, # should match whatever is in skill info
	"use_linked_item": item_letter,
	"type": ITEM_TYPES.UTILITY,
	"can_discord": true,
	"xp": 2 # xp to craft
}

# fish
onready var item_jumbofish = {
	"name": "Jumbofish",
	"description": "After eating this, the unit will not have to eat for 2 days.",
	"type": ITEM_TYPES.FISH,
	"can_discard": true,
	"xp": 2, # xp upon receiving
	"connected_ability": global_ability_list.ability_well_fed,
	"can_stack_effect": false # this effect can not be added more than once
}

onready var item_musclefish = {
	"name": "Musclefish",
	"description": "Eating this will allow the unit to carry an additional 3 items that day.",
	"type": ITEM_TYPES.FISH,
	"can_discard": true,
	"xp": 2, # xp upon receiving
	"connected_ability": global_ability_list.ability_food_musclefish,
	"can_stack_effect": true # this effect can be added more than once
}

onready var item_catfish = {
	"name": "Catfish",
	"description": "After eating this, for the remainder of the day, petting cats will grant the unit an additional 'Relaxed' effect (10% bonus XP).",
	"type": ITEM_TYPES.FISH,
	"can_discard": true,
	"xp": 2, # xp upon receiving
	"connected_ability": global_ability_list.ability_food_catfish,
	"can_stack_effect": false # this effect can not be added more than once
}

# wood
onready var item_cedar_logs = {
	"name": "Cedar Logs",
	"description": "A light-colored wood that is quite aromatic. Can be used to craft various items.",
	"type": ITEM_TYPES.WOOD,
	"can_discard": true,
	"xp": 1 # xp upon receiving
}

onready var item_ash_logs = {
	"name": "Ash Logs",
	"description": "A hardwood that is surprisingly flexible. Can be used to craft various items.",
	"type": ITEM_TYPES.WOOD,
	"can_discard": true,
	"xp": 2 # xp upon receiving
}

onready var item_fir_logs = {
	"name": "Fir Logs",
	"description": "A softwood that feels quite sturdy. Can be used to craft various items.",
	"type": ITEM_TYPES.WOOD,
	"can_discard": true,
	"xp": 2 # xp upon receiving
}

onready var item_birch_logs = {
	"name": "Birch Logs",
	"description": "A pale hardwood that is good for painting. Can be used to craft various items.",
	"type": ITEM_TYPES.WOOD,
	"can_discard": true,
	"xp": 2 # xp upon receiving
}

# may remove
onready var item_softwood = {
	"name": "Softwood",
	"description": "A light-colored wood that is easy to cut. Can be used to craft various items.",
	"type": ITEM_TYPES.WOOD,
	"can_discard": true,
	"xp": 2 # xp upon receiving
}

onready var item_hardwood = {
	"name": "Hardwood",
	"description": "A dark, heavy wood that takes some effort to cut through. Can be used to craft various items.",
	"type": ITEM_TYPES.WOOD,
	"can_discard": true,
	"xp": 3 # xp upon receiving
}



# ore / gemstones
onready var item_stone = {
	"name": "Stone",
	"description": "A small block of stone. Can be used to craft various items.",
	"type": ITEM_TYPES.ORE,
	"xp": 1, # xp upon receiving
	"level_to_mine": 1 # required level to mine (should match what's in skill_unlocks)
}

onready var item_amethyst = {
	"name": "Amethyst",
	"description": "A small, amethyst gemstone. Its violet hue is quite soothing. Can be used to craft various items.",
	"type": ITEM_TYPES.GEM,
	"xp": 2, # xp upon receiving
	"level_to_mine": 1 # required level to mine (should match what's in skill_unlocks)
}

onready var item_iron_ore = {
	"name": "Iron Ore",
	"description": "A small block of iron ore. Can be used to craft various items.",
	"type": ITEM_TYPES.ORE,
	"xp": 2, # xp upon receiving
	"level_to_mine": 3 # required level to mine (should match what's in skill_unlocks)
}

onready var item_gold = {
	"name": "Gold",
	"description": "A small chunk of gold ore. Can be used to craft various items.",
	"type": ITEM_TYPES.ORE,
	"xp": 3, # xp upon receiving
	"level_to_mine": 5 # required level to mine (should match what's in skill_unlocks)
}


onready var gemstone_list = [
	item_amethyst
]

# misc crafting materials
onready var item_wooden_handle = {
	"name": "Wooden Handle",
	"description": "A handle made of softwood. Can be used to craft various items.",
	"type": ITEM_TYPES.CRAFTING_PART,
	"xp": 1
}

onready var item_latex = {
	"name": "Latex",
	"description": "A milky substance collected from a rubber tree. Can be used to craft various items.",
	"type": ITEM_TYPES.CRAFTING_PART
}

# a helper function for adding items to a unit
func add_item_to_unit(unit, item):
	
	# determine if the unit's stats should be modified based on the item
	if (unit.get("is_animal") == null):
		# if there is a duplicate ability with this effect, which the unit already has
		if (item.has('duplicate_ability') && global_ability_list.unit_has_ability(unit, item.duplicate_ability)):
			# no need to add the effect
			pass
		# if this item's affect can not be stacked and we already have this item, make sure not to add the effect
		elif (item.has('can_stack_effect') && !item.can_stack_effect) && ((unit_has_item(unit, item, 1)).size() > 0):
			# do not add the effect to the unit
			pass
		else: 
			# we can add the effect
			if (item.has('stat_effected')):
				unit[item.stat_effected] += item.stat_effected_value
		
		# add custom effects below

	unit.current_items.append(item)
	
	
# a helper function for removing items from a unit
func remove_item_from_unit(unit, index):
	var item = unit.current_items[index]
	
	# go ahead and remove the item from the unit
	unit.current_items.remove(index)
	
	# determine if the unit's stats should be modified when removing the item

	if (unit.get("is_animal") == null):
		# if there is a duplicate ability with this effect, which the unit already has
		if (item.has('duplicate_ability') && global_ability_list.unit_has_ability(unit, item.duplicate_ability)):
			# no need to remove the effect
			pass
		# if this item's affect can not be stacked and we still have this item, make sure not to remove the effect
		elif (item.has('can_stack_effect') && !item.can_stack_effect) && ((unit_has_item(unit, item, 1)).size() > 0):
			# do not remove the effect from the unit (because we still have that item)
			pass
		else: 
			# we can remove the effect
			if (item.has('stat_effected')):
				if (typeof(unit[item.stat_effected]) == TYPE_ARRAY):
					var i = 0
					for el in unit[item.stat_effected]:
						if (item.stat_effected_value.has(el)):
							# remove it from array
							unit[item.stat_effected].remove(i)
							i -= 1
						i += 1
				else:
					unit[item.stat_effected] -= item.stat_effected_value
				
			# add custom effect removals below

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
	
# a helper function for determining if a unit has a specific item
func unit_has_item(unit, item, quantity):
	# returns an array of indexes for this/these items
	var item_indexes = []
	var current_index = 0
	
	for unit_item in unit.current_items:
		if unit_item == item:
			item_indexes.append(current_index)
			if item_indexes.size() >= quantity:
				return item_indexes
		current_index += 1
		
	# if they don't have enough of that item, return an empty array
	return []
	
# oh no! an item broke!
func item_broke(item, unit):
	var index = unit_has_item(unit, item, 1)
	
	if (index.size() > 0):
		index = index[0]
		player.hud.dialogueState = player.hud.STATES.INACTIVE 
		player.hud.typeTextWithBuffer(item.name + BROKE_TEXT, false, 'finished_viewing_text_generic')
		
		yield(signals, "finished_viewing_text_generic")
		
		remove_item_from_unit(unit, index)

	
	

extends Node

# autoloaded script for guild variables / functions

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# keep track of the global player variables
onready var player = get_node("/root/Player_Globals")

# bring in our items
onready var global_items_list = get_node("/root/Items")

# bring in our global action list
onready var global_action_list = get_node("/root/Actions")

# bring in our abilities
onready var global_ability_list = get_node("/root/Abilities")

# bring in our signals
onready var signals = get_node("/root/Signal_Manager")

# various hud scenes
onready var hud_selection_list_scn = preload("res://Entities/HUD/Selection_List.tscn")
onready var hud_depot_screen_scn = preload("res://Entities/HUD/Guild Actions/Depot_Screen.tscn")
onready var hud_dining_screen_scn = preload("res://Entities/HUD/Guild Actions/Dining_Screen.tscn")
onready var hud_guild_info_screen_scn = preload("res://Entities/HUD/Info Screens/Guild_Info_Screen.tscn")
onready var hud_quest_completion_screen_scn = preload("res://Entities/HUD/Quest_Completion_Window.tscn")

const SENT_TO_DEPOT_TEXT = 'Items sent to depot...'

const QUEST_HORSE_RESCUE_NAME = 'Horse Rescue'
const QUEST_FRIEND_WANTED_NAME = 'Friend Wanted'
const QUEST_GRAVEDIGGER_NAME = 'Gravedigger'

# keep track of the camera
var camera

# keep track of all the items currently in the depot
var current_items = []

# keep track of the depot screen (if it exists)
var hud_depot_screen_node

# keep track of the dining screen (if it exists)
var hud_dining_screen_node

# keep track of the guild info screen (if it exists)
var hud_guild_info_screen_node

# keep track of the quest completion screen (if it exists)
var hud_quest_completion_screen_node

# the guild can have a few different special abilities as the player progresses through the game. Here is a list of those abilities
enum GUILD_ABILITIES {
	RANDOM_UNIT_SENSE_OF_DUTY # a random unit gains A Sense of Duty (related to 'Friend in Need' quest)
}

var current_guild_abilities = [
	
]

# ------------ QUESTS -----------------
# keep track of the quests that are in progress and completed
var main_in_progress = []
var side_in_progress = []
var main_completed = []

var side_completed = []

# quick multiline helper
func ml(str_array):
	var return_str = ""
	for string in str_array:
		return_str += string
	return return_str

onready var quest_friend_wanted = {
	"name": QUEST_FRIEND_WANTED_NAME,
	"start_prompt": "Hear Brother Samuel out?",
	"statuses": [
		"A former member of the guild named Brother Samuel has asked you to bring over some wooden pipes and listen to his tale.",
		"You completed the quest!"
	],
	"progress_conditions": [
		{
			# requirements to move past progress 0
			"items_required": [
				# two wooden pipes
				global_items_list.item_wooden_pipe,
				global_items_list.item_wooden_pipe,
			],
			"items_for": "Samuel",
			"set_dialogue": 3
		}
	],
	"completion_text": "Brother Samuel gave you an old Guild Photo.",
	"current_progress": 0,
	"reward": global_items_list.item_guild_photo
}

onready var quest_horse_rescue = {
	"name": QUEST_HORSE_RESCUE_NAME,
	"start_prompt": "Listen to Farmer Fred?",
	"statuses": [
		"Farmer Fred has lost his horse, Skyheart. He suspects she was taken by a band of goblins, and has asked you to investigate.",
		
		ml(["King Rul of the Goblin Clan has mentioned some sort of Alag Banquet. It seems the goblins intend to feast on Skyheart. I should ",
		"inquire further."]),
		
		ml(["King Rul spoke of a banquet held every year in honor of King Alag. It seems this banquet is of huge importance to the goblins. ",
		"I should ask if there is any way Skyheart can be returned to Farmer Fred. "]),
		
		ml(["King Rul agreed to return Skyheart if I can provide some Catfish. I will need to provide enough for each villager."]),
		
		"You completed the quest!"
	],
	"progress_conditions": [
		{
			# requirements to move past progress 0
			"talk_to": "King Rul",
			"set_dialogue": 2,
			"level_requirement": 5,
			"skill_tested": constants.DIPLOMACY
		},
		{
			# requirements to move past progress 1
			"talk_to": "King Rul",
			"set_dialogue": 3,
			"level_requirement": 5,
			"skill_tested": constants.DIPLOMACY
		},
		{
			# requirements to move past progress 2
			"talk_to": "King Rul",
			"set_dialogue": 4,
			"level_requirement": 5,
			"skill_tested": constants.DIPLOMACY
		},
		{
			# requirements to move past progress 3
			"items_required": [
				# three catfish
				global_items_list.item_catfish,
				global_items_list.item_catfish,
				global_items_list.item_catfish
			],
			"items_for": "King Rul",
			"set_dialogue": 6,
			"level_requirement": 5,
			"skill_tested": constants.DIPLOMACY
		},
	],
	"current_progress": 0,
	"completion_text": "King Rul returned Skyheart to Farmer Fred. You can now tame and ride Skyheart.",
}

onready var quest_gravedigger = {
	"name": QUEST_GRAVEDIGGER_NAME,
	"start_prompt": "Speak with the ghost?",
	"statuses": [
		ml(["A ghost living in Sedgelin Swamplands is not a fan of his burial location. He has asked you to dig up ",
		"his remains and find a more suitable location. He desires some company."]),
		
		"You completed the quest!"
	],
	"progress_conditions": [
		{
			"empty_condition": true # this is an empty condition, and will be progressed by taking some action in the game
			# this condition is passed by using Rubin's Remains on the correct dirt spot
		}
	],
	"completion_text": "",
	"current_progress": 0,
}

onready var main_quests = []
onready var side_quests = [
	quest_friend_wanted,
	quest_horse_rescue,
	quest_gravedigger
]

func already_has_quest(quest_to_check):
	# make sure the player has not already initiated or completed this quest
	var all_quests = []
	all_quests += side_in_progress + side_completed + main_in_progress + main_completed
	
	var has_quest = false
	
	for quest in all_quests:
		if (quest_to_check.name == quest.name):
			has_quest = true
			
	return has_quest

func started_quest(quest_name_to_check):
	# check if the player has started the quest
	var all_quests = []
	all_quests += side_in_progress + main_in_progress
	
	var started_quest = false
	
	for quest in all_quests:
		if (quest_name_to_check == quest.name):
			started_quest = true
			
	return started_quest

func start_quest(active_unit, quest_to_start, npc = null):
	# first, make sure the player hasn't already started this quest
	if (!already_has_quest(quest_to_start)):
		# determine if this is a main quest or side quest
		var is_main_quest = false
		for quest in main_quests:
			if (quest.name == quest_to_start.name):
				is_main_quest = true
				
		# add the quest to our in-progress quests
		if (is_main_quest):
			main_in_progress.append(quest_to_start)
		else:
			side_in_progress.append(quest_to_start)
			
		# start the npcs quest dialogue
		get_tree().get_current_scene().npcs.talk_to_npc(active_unit, npc, 1, 1, null, true) # bypass quest condition checker, as we just started the quest

# check to make sure this npc doesn't behave a certain way, due to an initiated quest
func check_quest_conditions_npc(npc, active_unit):
	# first, see if the player has any quests in-progress that this npc is involved in
	var in_progress = main_in_progress + side_in_progress
	
	var related_quests = []
	if (npc.has("quests_involved_in")):
		for in_progress_quest in in_progress:
			for npc_involved_quest in npc.quests_involved_in:
				if (in_progress_quest.name == npc_involved_quest.name):
					related_quests.append(npc_involved_quest)
					
	if (related_quests.size() > 0):
		# for each quest, determine if we can make progress in any.
		# (btw, we can only make progress in one at a time. If for some reason the player has)
		# multiple quests they can progress right now, they'll have to speak to this npc again
		var related_quest_index = 0
		var matched_related_quest = -1
		for related_quest in related_quests:
			# check if the unit meets the conditions to progress this quest 
			var conditions = related_quest.progress_conditions[related_quest.current_progress]
			var meets_conditions = false
			
			# if the conditions requires the unit to have items
			if (conditions.has("items_required") && conditions.items_for == npc.name):
				# the unit needs to give items to this npc
				var item_requirements_met = []
				
				for item_required in conditions.items_required:
					# see if the unit has this item
					var unit_item_index = 0

					for unit_item in active_unit.current_items:
						if (unit_item.name == item_required.name && !item_requirements_met.has(unit_item_index)):
							item_requirements_met.append(unit_item_index)
							# break from the inner loop and look for the next item
							break
						else:
							unit_item_index += 1

				if (item_requirements_met.size() == conditions.items_required.size()):
					matched_related_quest = related_quest_index
					meets_conditions = true
					
					# remove the items from the unit
					item_requirements_met.invert() # invert, as we will be removing items as we iterate and want to prevent errors
					for index in item_requirements_met:
						global_items_list.remove_item_from_unit(active_unit, index)
					
			# if the conditions simply require talking to an npc
			if (conditions.has("talk_to") && conditions.talk_to == npc.name):
				meets_conditions = true # that was easy
					
			# if there are any associated skill tests, the condition will fail if the unit doesn't have that skill level
			if (conditions.has("level_requirement")):
				var the_skill = conditions.skill_tested
				
				if (active_unit.skill_levels[the_skill] < conditions.level_requirement):
					meets_conditions = false
				
				
					
			related_quest_index += 1
			
			if (meets_conditions):
				var quest_completed = false
				
				# we've met the conditions for this quest
				# bump up the quest progress
				var old_progress = related_quests[matched_related_quest].current_progress
				related_quests[matched_related_quest].current_progress += 1
				
				# if the current progress equals the amount of statuses, we've finished the quest! Move the quest to 'completed'
				if (related_quests[matched_related_quest].current_progress >= related_quests[matched_related_quest].statuses.size() - 1):
					move_quest_to_completed(related_quests[matched_related_quest])
					quest_completed = true
				
				# if the npc has updated dialogue, update it
				if (related_quests[matched_related_quest].progress_conditions[old_progress].has("set_dialogue")):
					get_tree().get_current_scene().npcs.talk_to_npc(active_unit, npc, 0, 1, 
						related_quests[matched_related_quest].progress_conditions[old_progress].set_dialogue, true)
					if (quest_completed):
						yield(signals, "finished_viewing_text_generic") # wait for the unit to finish speaking with the npc
						show_quest_completion_screen(related_quests[matched_related_quest], active_unit)
					return 
					
	get_tree().get_current_scene().npcs.talk_to_npc(active_unit, npc, 0, 0, null, true) # bypass quest condition checker
	return

func show_quest_completion_screen(quest, active_unit):
	# dampen the background music
	get_tree().get_current_scene().dampen_background_music()
	
	# set the player state
	player.player_state = player.PLAYER_STATE.COMPLETING_QUEST
	
	# create a new quest completion screen
	hud_quest_completion_screen_node = hud_quest_completion_screen_scn.instance()
	add_child(hud_quest_completion_screen_node)

	# set the quest name
	hud_quest_completion_screen_node.set_quest_name(quest, active_unit)

func move_quest_to_completed(quest):
	# check main and side
	var index = 0
	for main_quest in main_in_progress:
		if (quest.name == main_quest.name):
			# remove from in_progress and add to main_completed
			main_in_progress.remove(index)
			main_completed.append(quest)
		index += 1
		
	
	index = 0
	for side_quest in side_in_progress:
		if (quest.name == side_quest.name):
			# remove from in_progress and add to side_completed
			side_in_progress.remove(index)
			side_completed.append(quest)
		index += 1
# -------------------------------------------------------------------

# ------------------------------ ACTIVE ANIMALS ---------------------------------------
var guild_animals = [
	
]

func add_animal(animal_scn):
	# create an instance of this scene
	var animal_instance = animal_scn.instance()
	player.party.add_child(animal_instance)
	
	# add to the list of guild animals
	guild_animals.append(animal_instance)
	
	# return the animal
	return animal_instance
	
	
func remove_animal(animal_id):
	var animal_index = 0
	for animal in guild_animals:
		if (animal.unit_id == animal_id):
			player.party.remove_child(animal)
			guild_animals.remove(animal_index)
		animal_index += 1
	
# --------------------------------------------------------------------------------------

# ------------------------------ GUILD RELATIONS ---------------------------------------

onready var bellmare_relation = {
	"faction": constants.faction_list[0],
	"favor": 0,
	"favor_limit": 10,
	"established": false
}

onready var goblin_clan_relation = {
	"faction": constants.faction_list[1],
	"favor": 0,
	"favor_limit": 10,
	"established": false
}

# keep track of all relations and their current favor
onready var guild_relations = [
	bellmare_relation,
	goblin_clan_relation
]

func reduce_favor():
	for relation in guild_relations:
		relation.favor -= 1 # reduce all favor by 1
		if (relation.favor < 0):
			relation.favor = 0

# --------------------------------------------------------------------------------------

# ------------------------------ CAN_PLACE ITEMS ---------------------------------------

# keep track of items that units can place in the game world. I debated on putting this in Items, but
# I feel that it is closely tied to the guild in the same way that quests are
enum PLACEABLE_ITEM_TYPES {
	BIRDHOUSES,
}

# limits for the number of items that can be placed for a given item type
enum LIMIT_TYPES {
	NO_LIMIT,
	PARTY_MEMBERS
}

onready var limit_text = {
	LIMIT_TYPES.PARTY_MEMBERS: 'You can only place one of these per guild member.'
}

onready var placed_items = {
	PLACEABLE_ITEM_TYPES.BIRDHOUSES: {
		"item_list": [], # empty array (no birdhouses placed initially)
		"item_limit": LIMIT_TYPES.PARTY_MEMBERS # can never have more than the number of party members
	}
}

# --------------------------------------------------------------------------------------

func check_misc_new_day_effects():
	# at the beginning of the day, check for misc effects (such as birdhouse occupancy)
	
	# BIRDHOUSES
	for birdhouse in placed_items[PLACEABLE_ITEM_TYPES.BIRDHOUSES].item_list:
		# for each birdhouse, determine if a bird appears there (birdhouse must be unoccupied)!
		if (constants.chance_test(birdhouse.data.bird_chance)):
			# occupy the birdhouse!
			birdhouse.data.occupied = true
			
			
			# add the beast mastery world map icon
			var bm_id = get_tree().get_current_scene().world_map_icons.tile_set.find_tile_by_name("beast_mastery_spot_icon")
			get_tree().get_current_scene().world_map_icons.set_cellv(birdhouse.pos, bm_id)
		
func reset_tiles_quest_conditions():
	# iterate through the completed quests and reset any quest, specific tiles
	var all_completed_quests = []
	all_completed_quests += side_completed + main_completed
	for completed_quest in all_completed_quests:
		match(completed_quest.name):
			QUEST_HORSE_RESCUE_NAME:
				# make sure the BM icon + action is present on Skyheart
				var bm_id = get_tree().get_current_scene().world_map_icons.tile_set.find_tile_by_name("beast_mastery_spot_icon")
				get_tree().get_current_scene().world_map_icons.set_cellv(Vector2(38, 8), bm_id)
		
func add_guild_ability(ability):
	current_guild_abilities.append(ability)
	
func remove_guild_ability(ability):
	var abil_index = 0
	for abil in current_guild_abilities:
		if abil == ability:
			current_guild_abilities.remove(abil_index)
			break
		abil_index += 1

func add_item_to_depot(item):
	if (item.has("depot_ability")):
		add_guild_ability(item.depot_ability)
	current_items.append(item)
	
func remove_item_from_depot(item_index):
	var item = current_items[item_index]
	if (item.has("depot_ability")):
		remove_guild_ability(item.depot_ability)
	current_items.remove(item_index)

func populate_depot_screen(active_unit):
	camera = get_tree().get_nodes_in_group("Camera")[0]
	
	hud_depot_screen_node = hud_depot_screen_scn.instance()
	camera.add_child(hud_depot_screen_node)
	hud_depot_screen_node.set_unit(active_unit)
	
func populate_dining_screen(active_unit, from_inv = false):
	camera = get_tree().get_nodes_in_group("Camera")[0]
	
	# add the dine screen to the camera
	hud_dining_screen_node = hud_dining_screen_scn.instance()
	camera.add_child(hud_dining_screen_node)
	
	hud_dining_screen_node.set_unit(active_unit)
	
	hud_dining_screen_node.set_source(from_inv) # whether we pull from inv or depot
	
func populate_guild_info_screen():
	camera = get_tree().get_nodes_in_group("Camera")[0]
	
	# add the guild info screen to the camera
	hud_guild_info_screen_node = hud_guild_info_screen_scn.instance()
	camera.add_child(hud_guild_info_screen_node)
	
func transition_items_at_depot():
	if (hud_depot_screen_node):
		hud_depot_screen_node.transfer_item()
		
func show_item_info_at_depot():
	if (hud_depot_screen_node):
		hud_depot_screen_node.show_item_info()
		
func trash_item_at_depot():
	if (hud_depot_screen_node):
		hud_depot_screen_node.trash_item()
		
func eat_food_at_dining_hall():
	if (hud_dining_screen_node):
		hud_dining_screen_node.eat_food()
func show_item_info_at_dining_hall():
	if (hud_dining_screen_node):
		hud_dining_screen_node.show_item_info()
		
# usually ran every morning to determine if any guild abilities kick in
func check_guild_abilities():
	for abil in current_guild_abilities:
		match(abil):
			GUILD_ABILITIES.RANDOM_UNIT_SENSE_OF_DUTY:
				# choose a random unit to gain the ability, A Sense of Duty
				var units = player.party.get_all_units_sleeping_at_guild_hall()
				units.shuffle()
				if (units.size() > 0):
					global_ability_list.add_ability_to_unit(units[0], global_ability_list.ability_a_sense_of_duty)
					
func get_quest_by_name(quest_name):
	var all_quests = []
	all_quests += side_in_progress + side_completed + main_in_progress + main_completed
	
	for quest in all_quests:
		if (quest_name == quest.name):
			return quest
			
	return null

extends Node

# this file will keep track of all of the actions that are available to a unit
# some of these actions will be available only when specific conditions are met, 
# such as being on a tile with a map icon (woodcutting, fishing, etc)

# bring in our items
onready var global_items_list = get_node("/root/Items")

# bring in our abilities
onready var global_ability_list = get_node("/root/Abilities")

# bring in the global player variables
onready var player = get_node("/root/Player_Globals")

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in our skill information
onready var skill_info = get_node("/root/Skill_Info")

# bring in our guild variables/functions
onready var guild = get_node("/root/Guild")

# bring in our signals
onready var signals = get_node("/root/Signal_Manager")

# quick transitioner scene
onready var scene_transitioner_scn = preload("res://Scenes/Transition_Scene/Quick_Transition_Black_Scene.tscn")

# have our map_actions layer, for determining more details about the tile
onready var map_actions = get_tree().get_nodes_in_group(constants.MAP_ACTIONS_GROUP)[0]

# various hud scenes
onready var hud_selection_list_scn = preload("res://Entities/HUD/Selection_List.tscn")

# our action screen (we can instance this when a unit does an action)
onready var action_screen_scn = preload("res://Entities/HUD/Action_Window.tscn")
var action_screen_node

# our crafting screen (we can instance this when the unit crafts)
onready var crafting_screen_scn = preload("res://Entities/HUD/Unit Actions/Crafting_Screen.tscn")
var crafting_screen_node

# our gift screen (we can instance this when a unit gives a gift to an npc)
onready var gift_screen_scn = preload("res://Entities/HUD/Unit Actions/Give_Gift_Screen.tscn")
var gift_screen_node

# 3 seconds to receive the skill reward
const SKILL_WAIT_TIME = 3

# keep track of the unit that is currently acting
var active_unit

# keep track of the camera
var camera

# timer constants
const WAIT_FOR_REWARD_SCREEN = 2

# text related to the various actions
const END_TURN_CONFIRMATION_TEXT = 'End turn?'
const STAY_AT_CAVE_PROMPT = "Sleep in the cave tonight?"

const FISHING_TEXT = " started fishing..."
const WOODCUTTING_TEXT = " started chopping..."
const MINING_TEXT = " started mining..."
const CRAFTING_TEXT = " started crafting..."
const CHECK_BIRDHOUSE = " checked the birdhouse..."
const PET_ANIMAL = " reached out..."

const TAMED_MISC = " spoke softly..."
const HELD_A_MEETING = " held a meeting..."
const STARTED_WRITING = " started writing..."

const TAPPED_TREE_AND_RECEIVED = " tapped the tree and received some "
const FOUND_MUSHROOMS = " found some mushrooms!"

const FISH_RECEIVED_TEXT = "and caught a "
const WOOD_RECEIVED_TEXT = "and got some "
const ORE_RECEIVED_TEXT = "and got some "
const CRAFT_RECEIVED_TEXT = "and made a "

const PATH_BLOCKED = 'My path is blocked...'
const UNLOCKED_TEXT = ' unlocked!'
const BECAME_INSPIRED_TEXT = ' became Inspired!'
const BECAME_CALM_TEXT = ' became Calm!'
const BECAME_BRAVE_TEXT = ' became Brave!'
const BECAME_RELAXED_TEXT = ' became Relaxed!'
const DOT_DOT_DOT_TEXT = '...'

const NO_ROOM_FOR_ANIMAL = "There's no room for an animal to be deployed..."
const CANT_TAME_ANY_MORE = " can't tame any more animals today..."
const CANT_PET_ANYMORE = "This animal doesn't want to be pet anymore..."
const ALREADY_MET_TEXT = "This leader is not available for any more meetings..."
const DUG_GROUND_FOUND_NOTHING = " dug up the ground and found nothing..."
const DUG_GROUND_FOUND = " dug up the ground and found "
const DUG_GROUND_INV_FULL = "There's something here, but "
const CANT_HOLD_ANYTHING_ELSE = " can't hold anything else..."
const NEED_AT_LEAST = "You need at least "
const WITH_TEXT = " favor with "
const TO_DO_THIS_TEXT = " to do this..."
const SOMEONE_SLEEPING_HERE = "A unit has already planned to sleep here tonight..."

const RELATION_ESTABLISHED = "New Relation established!"

const YOU_MUST_ESTABLISH_RELATION = "You must establish a relationship with this person before gifting items..."

const SLEEPING_IN_CAVE_TEXT = " decided to sleep in the cave tonight. "
const CAN_RETURN_LATER_TEXT = " will now have the option to return here tonight."

enum COMPLETE_ACTION_LIST {
	MOVE,
	DEPOT,
	DINE,
	CRAFT,
	POSIT,
	FISH,
	MINE,
	CHOP,
	TAP_RUBBER_TREE, # for collecting latex (rubber)
	TAKE_MUSHROOM, # for collecting mushrooms
	CHECK_BIRDHOUSE, # used for Beast Mastery
	PET_CAT, # used for Beast Mastery
	PET_GATOR, # used for Beast Mastery
	TAME_BEAVER, # used for Beast Mastery
	MEET_WITH_LEADER, # used for Diplomacy
	GIVE_GIFT_TO_LEADER, # used for Diplomacy
	GIVE_GIFT_ON_GIFT_SCREEN, # used for Gift screen
	TRADE_ITEMS, # trade items between units
	TALK, # used for NPCS
	ACCESS_DEPOT_VIA_MAGE_ASHEN, # access depot
	ACCESS_DINING_VIA_CHEF_FREDERIK, # access dining
	FOLLOW_NPC, # follow an npc between matching connectors
	READ_SIGN, # used for signs
	READ_GRAVE, # used for graves (basically signs)
	CLIMB_TOWER, # used for towers + revealing regions
	TUNNEL, # for caves (Male Miner Only)
	SLEEP_IN_CAVE, # must have some courage
	CROSS, # for rivers (Female Angler Only / Or wooden stilts)
	BUILD_BEAVER_BRIDGE_HORIZONTAL, # for beavers!
	BUILD_BEAVER_BRIDGE_VERTICAL, # for beavers
	INFO,
	ANIMAL_INFO, # for viewing animal info screens
	FOCUS,
	MAP, # view the world map
	GUILD, # view the guild info
	NEXT_TURN,
	YES, # for confirmation
	NO, # for confirmation
	WRITE_LETTER, # write a diplomatic letter
	DIG_GROUND, # when using a shovel
	TRANSFER_ITEM_AT_DEPOT, # for depot screen
	VIEW_ITEM_INFO_AT_DEPOT, # for depot screen
	TRASH_ITEM_AT_DEPOT, # for depot screen
	TRANSFER_ITEM_ON_TRADE_SCREEN, # for trade screen
	VIEW_ITEM_INFO_ON_TRADE_SCREEN, # for trade screen
	USE_ITEM_IN_UNIT_INFO_SCREEN, # for unit info screen
	TRASH_ITEM_IN_UNIT_SCREEN, # for unit info screen
	VIEW_ITEM_INFO_IN_UNIT_SCREEN, # for unit info screen
	EAT_FOOD_AT_DINING_HALL, # for dining screen
	VIEW_ITEM_INFO_AT_DINING_HALL, # for dining screen
	CRAFT_RECIPE_IN_CRAFTING_SCREEN, # for crafting screen
	VIEW_ITEM_INFO_IN_CRAFTING_SCREEN, # for crafting screen
	QUEST_STATUS, # for the quest detail string
	RETURN_TO_GUILD, # for bedtime
	RETURN_TO_CAMP, # for bedtime
	RETURN_TO_INN, # for bedtime
	RETURN_TO_CAVE, # for bedtime
}

const ACTION_LIST_NAMES = [ # in the same order as actions above
	'MOVE',
	'DEPOT',
	'DINE',
	'CRAFT',
	'POSIT',
	'FISH',
	'MINE',
	'CHOP',
	'TAP',
	'TAKE',
	'CHECK',
	'PET',
	'PET',
	'TAME',
	'MEET',
	'GIVE',
	'GIVE',
	'TRADE',
	'TALK',
	'DEPOT',
	'DINE',
	'FOLLW',
	'READ',
	'READ',
	'CLIMB',
	'TUNNL',
	'SLEEP',
	'CROSS',
	'BUILD',
	'BUILD',
	'INFO',
	'INFO',
	'FOCUS',
	'MAP',
	'GUILD',
	'NEXT',
	'YES',
	'NO',
	'WRITE',
	'DIG',
	'MOVE',
	'INFO',
	'TRASH',
	'MOVE',
	'INFO',
	'USE',
	'TRASH',
	'INFO',
	'EAT',
	'INFO',
	'CRAFT',
	'INFO',
	'INFO',
	'GUILD',
	'CAMP',
	'INN',
	'CAVE',
]

# list of exclusive actions
onready var exclusive_actions = {
	COMPLETE_ACTION_LIST.TUNNEL: 'true',
	COMPLETE_ACTION_LIST.CROSS: 'true'
}

func do_action(action, parent, additional_params = null):
	# see if the parent is a unit, and if so, set the active unit
	if not parent.get('unit_id') == null :
		active_unit = parent
	elif parent.get('is_animal') == true:
		active_unit = parent # if animal
	else:
		active_unit = null
	
	match (action):
		COMPLETE_ACTION_LIST.MOVE:
			# let the unit handle this action
			active_unit.do_action(action)
		COMPLETE_ACTION_LIST.DEPOT:
			# initialize the depot screen
			guild.populate_depot_screen(active_unit)
		COMPLETE_ACTION_LIST.DINE:
			# initialize the dine screen
			guild.populate_dining_screen(active_unit)
		COMPLETE_ACTION_LIST.CRAFT:
			# initialize the crafting screen
			initiate_crafting_action()
		COMPLETE_ACTION_LIST.POSIT:
			# allow the unit to position themself anywhere around the guild hall
			active_unit.postion_around_guild()
		COMPLETE_ACTION_LIST.TRANSFER_ITEM_AT_DEPOT:
			# move the item from depot to unit, or visa-versa
			guild.transition_items_at_depot()
		COMPLETE_ACTION_LIST.VIEW_ITEM_INFO_AT_DEPOT:
			# show the item info, at the depot
			guild.show_item_info_at_depot()
		COMPLETE_ACTION_LIST.TRANSFER_ITEM_ON_TRADE_SCREEN:
			parent.transfer_current_item()
		COMPLETE_ACTION_LIST.VIEW_ITEM_INFO_ON_TRADE_SCREEN:
			parent.view_item_info()
		COMPLETE_ACTION_LIST.TRASH_ITEM_AT_DEPOT:
			# trash the item (in the depot screen)
			guild.trash_item_at_depot()
		COMPLETE_ACTION_LIST.WRITE_LETTER:
			# write a letter with a piece of paper
			initiate_write_letter_action(additional_params)
		COMPLETE_ACTION_LIST.DIG_GROUND:
			# dig the ground using the unit's shovel
			initiate_dig_ground_action(additional_params)
		COMPLETE_ACTION_LIST.USE_ITEM_IN_UNIT_INFO_SCREEN:
			parent.use_item()
		COMPLETE_ACTION_LIST.TRASH_ITEM_IN_UNIT_SCREEN:
			parent.trash_item()
		COMPLETE_ACTION_LIST.VIEW_ITEM_INFO_IN_UNIT_SCREEN:
			parent.show_item_info()
		COMPLETE_ACTION_LIST.EAT_FOOD_AT_DINING_HALL:
			# eat the selected item at the dining hall
			guild.eat_food_at_dining_hall()
		COMPLETE_ACTION_LIST.VIEW_ITEM_INFO_AT_DINING_HALL:
			# view the effect of the food at the dining hall
			guild.show_item_info_at_dining_hall()
		COMPLETE_ACTION_LIST.CRAFT_RECIPE_IN_CRAFTING_SCREEN:
			# view recipe info in the crafting screen
			crafting_screen_node.change_screens(crafting_screen_node.SCREENS.CONFIRMATION)
		COMPLETE_ACTION_LIST.VIEW_ITEM_INFO_IN_CRAFTING_SCREEN:
			# view info about the recipe in the crafting screen
			crafting_screen_node.view_item_info()
		COMPLETE_ACTION_LIST.FISH:
			initiate_fish_action()
		COMPLETE_ACTION_LIST.MINE:
			initiate_mine_action()
		COMPLETE_ACTION_LIST.CHOP:
			initiate_woodcutting_action()
		COMPLETE_ACTION_LIST.TAP_RUBBER_TREE:
			initiate_tap_tree_action()
		COMPLETE_ACTION_LIST.TAKE_MUSHROOM:
			initiate_take_mushroom_action()
		COMPLETE_ACTION_LIST.CHECK_BIRDHOUSE:
			initiate_check_birdhouse_action()
		COMPLETE_ACTION_LIST.PET_CAT:
			# pet a cat!
			initiate_pet_cat_action()
		COMPLETE_ACTION_LIST.PET_GATOR:
			# pet a gator!
			initiate_pet_gator_action()
		COMPLETE_ACTION_LIST.TAME_BEAVER:
			# tame a beaver
			initiate_tame_beaver_action()
		COMPLETE_ACTION_LIST.MEET_WITH_LEADER:
			# meet with a diplomatic leader
			initiate_meet_with_leader_action()
		COMPLETE_ACTION_LIST.GIVE_GIFT_TO_LEADER:
			# open the gift-giving screen
			initiate_give_gift_action()
		COMPLETE_ACTION_LIST.GIVE_GIFT_ON_GIFT_SCREEN:
			gift_screen_node.give_current_item()
		COMPLETE_ACTION_LIST.INFO:
			# let the unit handle this action
			active_unit.do_action(action)
		COMPLETE_ACTION_LIST.ANIMAL_INFO:
			# let the unit handle this action
			active_unit.do_action(action)
		# actions for returning home at night
		COMPLETE_ACTION_LIST.RETURN_TO_GUILD:
			# return the unit to the guild, and continue to send more units to bed (if necessary)
			player.hud.full_text_destruction()
			active_unit.return_to(COMPLETE_ACTION_LIST.RETURN_TO_GUILD)
			get_tree().get_current_scene().send_units_to_bed(true, true)
		COMPLETE_ACTION_LIST.RETURN_TO_CAMP:
			# return the unit to his/her camp, and continue to send more units to bed (if necessary)
			player.hud.full_text_destruction()
			active_unit.return_to(COMPLETE_ACTION_LIST.RETURN_TO_CAMP)
			get_tree().get_current_scene().send_units_to_bed(true, true)
		COMPLETE_ACTION_LIST.RETURN_TO_INN:
			# return the unit to the inn, and continue to send more units to bed (if necessary)
			player.hud.full_text_destruction()
			active_unit.return_to(COMPLETE_ACTION_LIST.RETURN_TO_INN)
			get_tree().get_current_scene().send_units_to_bed(true, true)
		COMPLETE_ACTION_LIST.RETURN_TO_CAVE:
			# return the unit to the cave, and continue to send more units to bed (if necessary)
			player.hud.full_text_destruction()
			active_unit.return_to(COMPLETE_ACTION_LIST.RETURN_TO_CAVE)
			get_tree().get_current_scene().send_units_to_bed(true, true)
		COMPLETE_ACTION_LIST.TALK:
			# talk to an NPC
			get_tree().get_current_scene().npcs.talk_to_npc(active_unit)
		COMPLETE_ACTION_LIST.ACCESS_DEPOT_VIA_MAGE_ASHEN:
			# access the depot, via npc
			access_depot_via_npc(guild.bellmare_relation, 6) # requires 6 favor with bellmare
		COMPLETE_ACTION_LIST.ACCESS_DINING_VIA_CHEF_FREDERIK:
			# access the dining window, via npc
			access_dining_via_npc(guild.bellmare_relation, 6, true) # requires 6 favor with bellmare, pulls from inv
		COMPLETE_ACTION_LIST.FOLLOW_NPC:
			# follow an npc from point A to point B
			follow_npc()
		COMPLETE_ACTION_LIST.TRADE_ITEMS:
			# trade items between units
			active_unit.show_trade_selector()
		COMPLETE_ACTION_LIST.READ_SIGN:
			# read an adjacent sign
			initiate_read_sign_action(player.active_world_object)
		COMPLETE_ACTION_LIST.READ_GRAVE:
			# graves are basically signs
			initiate_read_sign_action(player.active_world_object)
		COMPLETE_ACTION_LIST.CLIMB_TOWER:
			# climb an adjacent tower
			initiate_climb_tower_action(player.active_world_object)
		COMPLETE_ACTION_LIST.TUNNEL:
			# this action can only be taken by the male miner. Allows the unit to travel between 
			# cave's (in the same region)
			initiate_tunnel_action()
		COMPLETE_ACTION_LIST.SLEEP_IN_CAVE:
			# need courage to do this
			initiate_sleep_in_cave_action()
		COMPLETE_ACTION_LIST.CROSS:
			# this action can only be taken by the female angler, or a unit holding wooden stilts
			active_unit.cross_water()
		COMPLETE_ACTION_LIST.BUILD_BEAVER_BRIDGE_HORIZONTAL:
			initiate_build_beaver_bridge_action(true)
		COMPLETE_ACTION_LIST.BUILD_BEAVER_BRIDGE_VERTICAL:
			initiate_build_beaver_bridge_action(false)
		COMPLETE_ACTION_LIST.FOCUS:
			# focus the cursor on the next available unit
			parent.do_action(action)
		COMPLETE_ACTION_LIST.MAP:
			# display the world map
			get_tree().get_current_scene().display_world_map()
		COMPLETE_ACTION_LIST.QUEST_STATUS:
			# show the current status of the quest 
			parent.show_quest_status()
		COMPLETE_ACTION_LIST.GUILD:
			# display the guild info screen
			guild.populate_guild_info_screen()
		COMPLETE_ACTION_LIST.NEXT_TURN:
			# we're finished with this turn (hour), so empty the yet to act array and determine the next state
			# but first, let the user confirm
			# add a selection list istance to our camera
			var hud_selection_list_node = hud_selection_list_scn.instance()
			camera = get_tree().get_nodes_in_group("Camera")[0]
			camera.add_hud_item(hud_selection_list_node)
	
			# populate the selection list with a yes/no confirmation
			hud_selection_list_node.populate_selection_list([], self, true, false, false, false, true, END_TURN_CONFIRMATION_TEXT, 
															'confirm_end_turn_yes', 'confirm_end_turn_no')
			
func action_window_finished(skill, reward, levelled_up):
	# clear existing text
	player.hud.clearText()
	
	# show different wording based on the action
	match(skill):
		constants.FISHING:
			player.hud.typeText(FISH_RECEIVED_TEXT + reward.name + constants.EXCLAMATION, false, 'finished_viewing_text_generic') # we do have a signal
		
		constants.WOODCUTTING:
			player.hud.typeText(WOOD_RECEIVED_TEXT + reward.name + constants.EXCLAMATION, false, 'finished_viewing_text_generic') # we do have a signal
		
		constants.MINING:
			player.hud.typeText(ORE_RECEIVED_TEXT + reward.name + constants.EXCLAMATION, false, 'finished_viewing_text_generic') # we do have a signal
			# for gem hunter ability
			if (reward.type == global_items_list.ITEM_TYPES.GEM && 
				global_ability_list.unit_has_ability(active_unit, global_ability_list.ABILITY_GEM_HUNTER_NAME)):
				yield(signals, "finished_viewing_text_generic")
				player.hud.typeText(active_unit.GEM_RECEIVED_TEXT, false, 'finished_viewing_text_generic')
		
		constants.WOODWORKING:
			player.hud.typeText(CRAFT_RECEIVED_TEXT + reward.name + constants.EXCLAMATION, false, 'finished_viewing_text_generic') # we do have a signal
		
		constants.SMITHING:
			player.hud.typeText(CRAFT_RECEIVED_TEXT + reward.name + constants.EXCLAMATION, false, 'finished_viewing_text_generic') # we do have a signal

		constants.FASHIONING:
			player.hud.typeText(CRAFT_RECEIVED_TEXT + reward.name + constants.EXCLAMATION, false, 'finished_viewing_text_generic') # we do have a signal
			
		constants.BEAST_MASTERY:
			player.hud.typeText(reward.special_conclusion + reward.name + constants.EXCLAMATION, false, 'finished_viewing_text_generic') # we do have a signal
			
			# for cat petting (give them 'calm', if they don't have it')
			if (reward.name == 'Cat' && !global_ability_list.unit_has_ability(active_unit, global_ability_list.ABILITY_CALM_NAME)):
				yield(signals, "finished_viewing_text_generic")
				player.hud.typeText(active_unit.unit_name + BECAME_CALM_TEXT, false, 'finished_viewing_text_generic')
				# give the unit CALM
				global_ability_list.add_ability_to_unit(active_unit, global_ability_list.ability_calm)
				
				# if the unit has the catfish food effect, they get 'Relaxed' as well
				if (global_ability_list.unit_has_ability(active_unit, global_ability_list.ABILITY_FOOD_CATFISH_NAME) &&
					!global_ability_list.unit_has_ability(active_unit, global_ability_list.ABILITY_RELAXED_NAME)):
					yield(signals, "finished_viewing_text_generic")
					player.hud.typeText(active_unit.unit_name + BECAME_RELAXED_TEXT, false, 'finished_viewing_text_generic')
					# give the unit RELAXED
					global_ability_list.add_ability_to_unit(active_unit, global_ability_list.ability_relaxed)
			
			# for petting gators (gives the unit 'brave', if they don't have it)
			elif (reward.name == 'Gator' && !global_ability_list.unit_has_ability(active_unit, global_ability_list.ABILITY_BRAVE_NAME)):
				yield(signals, "finished_viewing_text_generic")
				player.hud.typeText(active_unit.unit_name + BECAME_BRAVE_TEXT, false, 'finished_viewing_text_generic')
				# give the unit BRAVE
				global_ability_list.add_ability_to_unit(active_unit, global_ability_list.ability_brave)

		constants.DIPLOMACY:
			# assume the special conclusion is an array
			var message_index = 0
			for message in reward.special_conclusion:
				player.hud.typeText(message, false, 'finished_viewing_text_generic')
				if (message_index < reward.special_conclusion.size() - 1):
					yield(signals, "finished_viewing_text_generic")
				message_index += 1
		_:
			# do nothing
			pass
			
	yield(signals, "finished_viewing_text_generic")
	
	if (levelled_up):
		# show what the unit can now do
		var skill_unlocks = skill_info.SKILL_UNLOCKS[skill]
		
		for unlock in skill_unlocks:
			if (unlock.level_required == active_unit.skill_levels[skill]):
				player.hud.typeText(active_unit.unit_name + unlock.unlock_text, false, 'finished_viewing_text_generic')
				
				yield(signals, "finished_viewing_text_generic")
		
		# we finished the action!
		signals.emit_signal("finished_action_success")
	else:
		# we finished the action!
		signals.emit_signal("finished_action_success")
		
		
func _on_finished_action(success = false): # signal callback
	if (success):
		# we are finished with the action
		if (action_screen_node != null):
			camera.remove_child(action_screen_node)
			action_screen_node = null
		
		# turn the music back up
		get_tree().get_current_scene().heighten_background_music()
	
	# and let the unit know he/she has finished acting :)
	active_unit.end_action(success)
	
# signal callback for when the player has confirmed they want to end the turn
func _on_end_turn(confirm = false):
	if (confirm):
		player.party.empty_yet_to_act()

	player.determine_next_state()

# a function used for showing the action window, reward, and experience gained
func show_action_window(skill, reward, special_received_text = null, special_reward_name = null, special_xp = 0, special_conclusion_text = null):
	# dampen the background music
	get_tree().get_current_scene().dampen_background_music()
	
	# create a new action window
	action_screen_node = action_screen_scn.instance()
	
	# add as a child of the camera
	camera = get_tree().get_nodes_in_group("Camera")[0]
	camera.add_child(action_screen_node)
	
	# set the action screen skill
	action_screen_node.set_skill(skill)
	
	# show the item being received, after 3 seconds
	var timer = Timer.new()
	timer.wait_time = SKILL_WAIT_TIME
	if (special_received_text != null):
		timer.connect("timeout", self, "set_special_reward", [special_received_text, special_reward_name, timer])
	else:
		timer.connect("timeout", self, "set_item_reward", [reward, timer])
	add_child(timer)
	timer.start()
	
	# give the item to the unit
	if (reward != null):
		active_unit.receive_item(reward)
	
	# give the xp to the unit
	var level_before = active_unit.skill_levels[skill]
	var xp_before = active_unit.skill_xp[skill]
	var xp_to_gain
	if (reward != null):
		xp_to_gain = reward.xp
		
		# for versatility, you can still receive an item and have special conclusion text
		if (special_reward_name != null):
			reward.name = special_reward_name
			
		if (special_conclusion_text != null):
			reward.special_conclusion = special_conclusion_text
	else:
		xp_to_gain = special_xp
		reward = {
			"name": special_reward_name,
			"special_conclusion": special_conclusion_text
		}
	
	# determine if the unit receives any bonus xp (round up). This is usually 0%, but can be increased with items / abilities
	var bonus_xp = ceil(active_unit.general_bonus_xp * xp_to_gain)
	xp_to_gain += bonus_xp
	
	active_unit.gain_xp(xp_to_gain, skill)
	var xp_after = active_unit.skill_xp[skill]
	var level_after = active_unit.skill_levels[skill]
	
	# and then, show the experience gained
	var timer_xp = Timer.new()
	timer_xp.wait_time = SKILL_WAIT_TIME + 1.5
	timer_xp.connect("timeout", self, "show_xp_reward", [reward, skill, level_before, level_after, xp_after, xp_before, timer_xp])
	add_child(timer_xp)
	timer_xp.start()
	
func show_xp_reward(reward, skill, level_before, level_after, xp_after, xp_before, timer = null):
	if (timer):
		timer.stop()
		remove_child(timer)
		
	action_screen_node.show_xp_reward(active_unit, reward, skill, level_before, level_after, xp_after, xp_before, self)

func set_item_reward(reward, timer = null):
	if (timer):
		timer.stop()
		remove_child(timer)

	action_screen_node.receive_item(reward)
	
func set_special_reward(special_text, special_name, timer = null):
	if (timer):
		timer.stop()
		remove_child(timer)

	action_screen_node.receive_special(special_text, special_name)

# if the unit is reading a sign
func initiate_read_sign_action(the_sign):
	if (the_sign.type == 'sign'):
		var sign_text = constants.get_sign_text(the_sign.pos)
		player.hud.typeTextWithBuffer(sign_text, false, 'finished_viewing_text_generic')
		yield(signals, "finished_viewing_text_generic")
	
	# change the state back
	player.player_state = player.PLAYER_STATE.SELECTING_TILE

# access the guild depot through an npc
func access_depot_via_npc(relation, favor):
	if (relation.favor >= favor):
		# initialize the depot screen
		guild.populate_depot_screen(active_unit)
	else:
		player.hud.typeTextWithBuffer(NEED_AT_LEAST + String(favor) + WITH_TEXT + relation.faction.name + TO_DO_THIS_TEXT, 
			false, 'finished_viewing_text_generic')
		yield(signals, "finished_viewing_text_generic")
		# change the state back
		player.player_state = player.PLAYER_STATE.SELECTING_TILE

func access_dining_via_npc(relation, favor, pulls_from_inv = true):
	if (relation.favor >= favor):
		# initialize the dining screen
		guild.populate_dining_screen(active_unit, pulls_from_inv)
	else:
		player.hud.typeTextWithBuffer(NEED_AT_LEAST + String(favor) + WITH_TEXT + relation.faction.name + TO_DO_THIS_TEXT, 
			false, 'finished_viewing_text_generic')
		yield(signals, "finished_viewing_text_generic")
		# change the state back
		player.player_state = player.PLAYER_STATE.SELECTING_TILE

func follow_npc():
	# find the corresponding npc (since this action can be taken from an adjacent tile)
	var the_npc_pos = null
	var the_npc_spot = null

	for tile in get_tree().get_current_scene().get_cardinal_tiles(active_unit):
		# check if the tile contains a follow_npc action
		if (map_actions.get_actions_at_coordinates(tile.tile)).has(COMPLETE_ACTION_LIST.FOLLOW_NPC):
			the_npc_pos = tile.tile
			the_npc_spot = map_actions.get_action_spot_at_coordinates(tile.tile)
			
	if (the_npc_pos != null):
		# get the npc 
		var npc = get_tree().get_current_scene().npcs.get_npc_by_pos(the_npc_pos)
		
		# get the relation for this npc
		var relation = npc.action_relation
		
		if (relation.favor >= npc.action_favor_requirement):
			# follow the npc to the corresponding spot
			var matching_connection = map_actions.get_cave_connection(the_npc_spot) # reuse cave function
			var target_tile_id = map_actions.tile_set.find_tile_by_name(matching_connection)
			var cells = map_actions.get_used_cells_by_id(target_tile_id)
			var target_pos = cells[0]
		
			# make sure the target position isn't occupied
			if player.party.is_unit_here(target_pos.x, target_pos.y):
				player.hud.typeTextWithBuffer(PATH_BLOCKED, false, 'finished_viewing_text_generic')
				yield(signals, "finished_viewing_text_generic")
				player.player_state = player.PLAYER_STATE.SELECTING_TILE
				return
		
			# first, fade out quickly
			# scene transition fade out
			var fade = scene_transitioner_scn.instance()
			add_child(fade)
			
			fade.black_in.visible = false
			fade.black_out.visible = true
			
			fade.fade_out_scene(0)
			
			yield(fade, "scene_faded_out")
			
			# with the screen faded out, move the unit to the connecting cave
			active_unit.set_unit_pos(target_pos.x, target_pos.y)
			get_tree().get_current_scene().cursor.focus_on(target_pos.x, target_pos.y)
			
			# fade back in the scene
			fade.black_in.visible = true
			fade.black_out.visible = false
			fade.fade_in_scene(0)
			
			yield(fade, "scene_faded_in")
			
			remove_child(fade)
			
			# and let the unit know he/she has finished acting :)
			active_unit.end_action(true) # success!
		else:
			player.hud.typeTextWithBuffer(NEED_AT_LEAST + String(npc.action_favor_requirement) + WITH_TEXT + relation.faction.name + TO_DO_THIS_TEXT, 
				false, 'finished_viewing_text_generic')
			yield(signals, "finished_viewing_text_generic")
			# change the state back
			player.player_state = player.PLAYER_STATE.SELECTING_TILE
			
	pass

func initiate_climb_tower_action(the_tower):
	if (the_tower.type == 'tower'):
		# determine which region is unlocked
		var region_name = null
		for const_tower in constants.tower_list:
			if (const_tower.positions.has(the_tower.pos)):
				region_name = const_tower.associated_region_unlock
		
		# if we have a corresponding region, fade to black, read some text, and unlock the region
		if (region_name != null):
			# first, fade out quickly
			# scene transition fade out
			var fade = scene_transitioner_scn.instance()
			add_child(fade)
			
			fade.black_in.visible = false
			fade.black_out.visible = true
			
			fade.fade_out_scene(0)
			
			yield(fade, "scene_faded_out")
			
			fade.black_in.visible = true
			
			# with the screen faded out, unlock the region
			var region = null
			for const_region in constants.regions:
				if (const_region.name == region_name):
					region = const_region
					break
			
			
			var newly_unlocked = (region.hidden == true)
			region.hidden = false
			
			# show the region in the overworld
			get_tree().get_current_scene().show_region(Vector2(region.x, region.y))
			
			# read the unit's tower climb text
			player.hud.typeTextWithBuffer(active_unit.TOWER_CLIMB_TEXT, false, 'finished_viewing_text_generic')
			yield(signals, "finished_viewing_text_generic")
			
			# inspire the unit, if they aren't already
			if (!global_ability_list.unit_has_ability(active_unit, global_ability_list.ABILITY_INSPIRED_NAME)):
				global_ability_list.add_ability_to_unit(active_unit, global_ability_list.ability_inspired)
				player.hud.typeTextWithBuffer(DOT_DOT_DOT_TEXT + active_unit.unit_name + BECAME_INSPIRED_TEXT, false, 'finished_viewing_text_generic')
				yield(signals, "finished_viewing_text_generic")
			
			if (newly_unlocked):
				player.hud.typeTextWithBuffer(DOT_DOT_DOT_TEXT + region.name + UNLOCKED_TEXT, false, 'finished_viewing_text_generic')
				yield(signals, "finished_viewing_text_generic")
			
			# fade back in the scene
			fade.black_in.visible = true
			fade.black_out.visible = false
			fade.fade_in_scene(0)
			
			yield(fade, "scene_faded_in")
			
			remove_child(fade)
			
			# and let the unit know he/she has finished acting :)
			active_unit.end_action(true) # success!

# if the unit is tunneling
func initiate_tunnel_action():
	
	var tunnel_connection = map_actions.get_action_spot_at_coordinates(Vector2(active_unit.unit_pos_x, active_unit.unit_pos_y))
	var matching_connection = map_actions.get_cave_connection(tunnel_connection)
	var target_tile_id = map_actions.tile_set.find_tile_by_name(matching_connection)
	var cells = map_actions.get_used_cells_by_id(target_tile_id)
	var target_pos = cells[0]

	# make sure the target position isn't occupied
	if player.party.is_unit_here(target_pos.x, target_pos.y):
		player.hud.typeTextWithBuffer(PATH_BLOCKED, false, 'finished_viewing_text_generic')
		yield(signals, "finished_viewing_text_generic")
		player.player_state = player.PLAYER_STATE.SELECTING_TILE
		return

	# first, fade out quickly
	# scene transition fade out
	var fade = scene_transitioner_scn.instance()
	add_child(fade)
	
	fade.black_in.visible = false
	fade.black_out.visible = true
	
	fade.fade_out_scene(0)
	
	yield(fade, "scene_faded_out")
	
	# with the screen faded out, move the unit to the connecting cave
	active_unit.set_unit_pos(target_pos.x, target_pos.y)
	get_tree().get_current_scene().cursor.focus_on(target_pos.x, target_pos.y)
	
	# fade back in the scene
	fade.black_in.visible = true
	fade.black_out.visible = false
	fade.fade_in_scene(0)
	
	yield(fade, "scene_faded_in")
	
	remove_child(fade)
	
	# and let the unit know he/she has finished acting :)
	active_unit.end_action(true) # success!

# if the unit is sleeping in a cave
func initiate_sleep_in_cave_action():
	# using this action requires some courage
	if (active_unit.courage == 0):
		# the unit is too spooked to sleep in a cave
		player.hud.typeTextWithBuffer(active_unit.unit_name + constants.TOO_SPOOKED, false, "finished_viewing_text_generic")
		yield(signals, "finished_viewing_text_generic")
		player.player_state = player.PLAYER_STATE.SELECTING_TILE
	else:
		# the unit can sleep here!
		var cave = constants.get_cave_at_pos(Vector2(active_unit.unit_pos_x, active_unit.unit_pos_y))
		
		if (cave):
			# determine if the cave is occupied
			if (cave.occupants.size() < cave.max_occupancy):
				# vacant cave!
				# prompt the user to stay in the cave
				var hud_selection_list_node = hud_selection_list_scn.instance()
				camera = get_tree().get_nodes_in_group("Camera")[0]
				camera.add_hud_item(hud_selection_list_node)
				# connect signals for confirming whether or not the player stays at the inn
				signals.connect("confirm_generic_yes", self, "_on_cave_confirmation", [true, cave], CONNECT_ONESHOT)
				signals.connect("confirm_generic_no", self, "_on_cave_confirmation", [false], CONNECT_ONESHOT)
				
				# populate the selection list with a yes/no confirmation
				hud_selection_list_node.populate_selection_list([], self, true, false, true, false, true, STAY_AT_CAVE_PROMPT,
																'confirm_generic_yes', 'confirm_generic_no')
			else:
				
				player.hud.typeTextWithBuffer(SOMEONE_SLEEPING_HERE, false, "finished_viewing_text_generic")
				yield(signals, "finished_viewing_text_generic")
				player.player_state = player.PLAYER_STATE.SELECTING_TILE
		
# if the player decides to sleep in the cave
func _on_cave_confirmation(staying, cave = null):
	if (staying):
		signals.disconnect("confirm_generic_no", self, "_on_cave_confirmation")
		
		# add the active unit as to the list of occupants
		cave.occupants.append(active_unit)
		
		# add CAVE to the list of places to return to (at night)
		active_unit.shelter_locations.append(COMPLETE_ACTION_LIST.RETURN_TO_CAVE)
		
		# and make this inn the active inn for the unit
		active_unit.active_cave = cave
		
		# read the follow up text
		player.hud.typeTextWithBuffer(active_unit.unit_name + SLEEPING_IN_CAVE_TEXT + active_unit.unit_name + CAN_RETURN_LATER_TEXT, false, "finished_viewing_text_generic")
	
		yield(signals, "finished_viewing_text_generic")
	else:
		signals.disconnect("confirm_generic_yes", self, "_on_cave_confirmation")
		
	# once it's all over, set the player state back
	player.player_state = player.PLAYER_STATE.SELECTING_TILE


# if the unit is crafting
func initiate_crafting_action():
	# initialize the crafting window
	camera = get_tree().get_nodes_in_group("Camera")[0]
	
	# add the dine screen to the camera
	crafting_screen_node = crafting_screen_scn.instance()
	camera.add_child(crafting_screen_node)
	
	crafting_screen_node.set_active_unit(active_unit)

# conclude crafting action
func finished_crafting_selection(skill, reward, unit):
	active_unit = unit
	
	# we've already removed the ingredients from the unit, so let the player know they are crafting, and show the action window!
	
	# kill the crafting screen
	camera.remove_child(crafting_screen_node)
	
	# start crafting
	player.hud.typeTextWithBuffer(active_unit.unit_name + CRAFTING_TEXT, true)
	
	show_action_window(skill, reward)

# if the unit is fishing
func initiate_fish_action():
	# first, determine if the unit has a fishing rod
	var rod = null
	for item in active_unit.current_items:
		if (item.type == global_items_list.ITEM_TYPES.ROD):
			rod = item
	
	if (rod):
		# determine which fishing spot the unit is targeting
		var spot = map_actions.get_action_spot_at_coordinates(Vector2(player.curs_pos_x, player.curs_pos_y))
		# make sure this is actually a fishing spot
		if (spot != null && !map_actions.get_actions_at_spot(spot).has(COMPLETE_ACTION_LIST.FISH)):
			spot = null

		var coord_x = player.curs_pos_x
		var coord_y = player.curs_pos_y

		
		# check north
		if (spot == null):
			spot = map_actions.get_action_spot_at_coordinates(Vector2(player.curs_pos_x, player.curs_pos_y - 1))
			coord_x = player.curs_pos_x
			coord_y = player.curs_pos_y - 1
			
			# make sure this is actually a fishing spot
			if (spot != null && !map_actions.get_actions_at_spot(spot).has(COMPLETE_ACTION_LIST.FISH)):
				spot = null
			
		# check east
		if (spot == null):
			spot = map_actions.get_action_spot_at_coordinates(Vector2(player.curs_pos_x + 1, player.curs_pos_y))
			coord_x = player.curs_pos_x + 1
			coord_y = player.curs_pos_y
			
			# make sure this is actually a fishing spot
			if (spot != null && !map_actions.get_actions_at_spot(spot).has(COMPLETE_ACTION_LIST.FISH)):
				spot = null
			
		# check south
		if (spot == null):
			spot = map_actions.get_action_spot_at_coordinates(Vector2(player.curs_pos_x, player.curs_pos_y + 1))
			coord_x = player.curs_pos_x
			coord_y = player.curs_pos_y + 1
			
			# make sure this is actually a fishing spot
			if (spot != null && !map_actions.get_actions_at_spot(spot).has(COMPLETE_ACTION_LIST.FISH)):
				spot = null
				

		# check west
		if (spot == null):
			spot = map_actions.get_action_spot_at_coordinates(Vector2(player.curs_pos_x - 1, player.curs_pos_y))
			coord_x = player.curs_pos_x - 1
			coord_y = player.curs_pos_y
			
		# get a list of fish that can be found at this spot
		var available_fish = map_actions.get_items_at_coordinates(coord_x, coord_y)
		
		if (available_fish.size() == 0):
			player.hud.typeTextWithBuffer(active_unit.NO_MORE_FISH_TEXT, false, 'finished_action_failed') # they did not succeed 
		elif (active_unit.is_inventory_full()):
			player.hud.typeTextWithBuffer(active_unit.INVENTORY_FULL_TEXT, false, 'finished_action_failed') # they did not succeed
		else:
			# get a random fish from the list
			available_fish.shuffle()
			var received_fish = available_fish[0]
			
			# remove that fish from the array
			available_fish.remove(0)
			
			# and update the used_tile items (for if the unit continues to fish here)
			map_actions.set_items_at_coordinates(coord_x, coord_y, available_fish)
			
			# start fishing
			player.hud.typeTextWithBuffer(active_unit.unit_name + FISHING_TEXT, true)
			
			show_action_window(constants.FISHING, received_fish)
			
	else:
		player.hud.typeTextWithBuffer(active_unit.CANT_FISH_WITHOUT_ROD_TEXT, false, 'finished_action_failed') # they did not succeed

# if the unit is checking a birdhouse
func initiate_check_birdhouse_action():
	# first, find the birdhouse in our placed_items list
	var selected_birdhouse = null
	for birdhouse in guild.placed_items[guild.PLACEABLE_ITEM_TYPES.BIRDHOUSES].item_list:
		if birdhouse.pos == Vector2(player.curs_pos_x, player.curs_pos_y):
			selected_birdhouse = birdhouse
			
	# determine if the birdhouse is occupied
	if (selected_birdhouse.data.occupied):
		# determine whether or not the unit can do this
		var daily_tamed = active_unit.beasts_tamed_today
		
		# determine if the unit can tame any more beasts today
		var level_for_more_beasts = skill_info.beast_mastery_tame_restrictions.get(daily_tamed + 1)
		if (level_for_more_beasts != null && level_for_more_beasts <= active_unit.skill_levels[constants.BEAST_MASTERY]):
			# get the action spot
			var spot = map_actions.get_action_spot_at_coordinates(Vector2(player.curs_pos_x, player.curs_pos_y))
			
			# get the level requirement for this spot
			var level_requirement = map_actions.get_level_requirement_at_spot(spot)
		
			# get the animals that can be found at this spot
			var animal_scns = map_actions.get_animals_at_spot(spot)
			animal_scns.shuffle()
			var animal_scn = animal_scns[0]
			
			if (level_requirement > active_unit.skill_levels[constants.BEAST_MASTERY]):
				player.hud.typeTextWithBuffer(active_unit.NOT_SKILLED_ENOUGH_TEXT, false, 'finished_action_failed') # they did not succeed 
			else:
				# determine a location for the animal to be deployed to
				var deploy_spot = null
				
				# check the four cardinal tiles around the unit
				for tile in get_tree().get_current_scene().get_cardinal_tiles(active_unit):
					if (!(get_tree().get_current_scene().unit_exists_at_coordinates(tile.tile.x, tile.tile.y)) && 
						!player.animal_restricted_coordinates.has(Vector2(tile.tile.x, tile.tile.y))):
						deploy_spot = tile.tile
						break
						
				if (deploy_spot != null):	
					# create the animal instance!
					var animal = guild.add_animal(animal_scn)
					animal.set_animal_position(deploy_spot)
					
					# the birdhouse is no longer occupied
					selected_birdhouse.data.occupied = false
					
					# the unit tamed a beast
					active_unit.beasts_tamed_today += 1
					
					# and remove the BM icon from this tile
					map_actions.remove_map_icon_at_coordinates(player.curs_pos_x, player.curs_pos_y)
					
					# start taming
					player.hud.typeTextWithBuffer(active_unit.unit_name + CHECK_BIRDHOUSE, true)
					
					show_action_window(constants.BEAST_MASTERY, null, 'Tamed', 'Dove', animal.tame_xp, '...and tamed a ') 
					
					yield(signals, "finished_action_success")
	
					# make the animal sprite visible
					animal.animal_sprite.visible = true
				else:
					# no space for the animal to be deployed
					player.hud.typeTextWithBuffer(active_unit.NOTHING_HERE_GENERIC_TEXT, false, 'finished_action_failed')
		else:
			# the unit cannot tame any more beasts today
			player.hud.typeTextWithBuffer(active_unit.unit_name + CANT_TAME_ANY_MORE, false, 'finished_action_failed')
	else:
		player.hud.typeTextWithBuffer(active_unit.NOTHING_HERE_GENERIC_TEXT, false, 'finished_action_failed')

# pet a cat! (beast mastery action)
func initiate_pet_cat_action():
	# since this action can be taken on an adjacent tile, determine where the cat is
	var the_cat_pos = null
	var the_cat_spot = null
	var cat_action_id = map_actions.tile_set.find_tile_by_name("Beast_Mastery_Spot_2") # pet cat
	
	for tile in get_tree().get_current_scene().get_cardinal_tiles(active_unit):
		if (map_actions.get_cellv(tile.tile) == cat_action_id):
			the_cat_pos = tile.tile
			the_cat_spot = map_actions.get_action_spot_at_coordinates(tile.tile)
	
	# determine if the cat has already been pet today (check for a BM icon)
	var map_icons = get_tree().get_nodes_in_group(constants.MAP_ICONS_GROUP)[0]
	var tileset = map_icons.get_tileset()
	var empty_id = tileset.find_tile_by_name("empty_spot")
	
	var already_pet = (map_icons.get_cellv(the_cat_pos) == empty_id)
	
	if (!already_pet):
		# get the level requirement for this spot
		var level_requirement = map_actions.get_level_requirement_at_spot(the_cat_spot)
		
		# make sure we meet the requirement
		if (level_requirement > active_unit.skill_levels[constants.BEAST_MASTERY]):
			player.hud.typeTextWithBuffer(active_unit.NOT_SKILLED_ENOUGH_TEXT, false, 'finished_action_failed') # they did not succeed 
		else:
			# the unit can pet the cat!
			
			# start petting
			player.hud.typeTextWithBuffer(active_unit.unit_name + PET_ANIMAL, true)
			
			show_action_window(constants.BEAST_MASTERY, null, 'Pet', 'Cat', skill_info.PET_CAT_XP, '...and managed to pet the ') 
			
			yield(signals, "finished_action_success")

			# and remove the BM icon from this tile
			map_actions.remove_map_icon_at_coordinates(the_cat_pos.x, the_cat_pos.y)		
	else:
		player.hud.typeTextWithBuffer(CANT_PET_ANYMORE, false, 'finished_action_failed')	

func initiate_pet_gator_action():
	# since this action can be taken on an adjacent tile, determine where the gator is
	var the_animal_pos = null
	var the_animal_spot = null
	var animal_action_id = map_actions.tile_set.find_tile_by_name("Beast_Mastery_Spot_4") # pet gator
	
	for tile in get_tree().get_current_scene().get_cardinal_tiles(active_unit):
		if (map_actions.get_cellv(tile.tile) == animal_action_id):
			the_animal_pos = tile.tile
			the_animal_spot = map_actions.get_action_spot_at_coordinates(tile.tile)
	
	# determine if the gator has already been pet today (check for a BM icon)
	var map_icons = get_tree().get_nodes_in_group(constants.MAP_ICONS_GROUP)[0]
	var tileset = map_icons.get_tileset()
	var empty_id = tileset.find_tile_by_name("empty_spot")
	
	var already_pet = (map_icons.get_cellv(the_animal_pos) == empty_id)
	
	if (!already_pet):
		# get the level requirement for this spot
		var level_requirement = map_actions.get_level_requirement_at_spot(the_animal_spot)
		
		# make sure we meet the requirement
		if (level_requirement > active_unit.skill_levels[constants.BEAST_MASTERY]):
			player.hud.typeTextWithBuffer(active_unit.NOT_SKILLED_ENOUGH_TEXT, false, 'finished_action_failed') # they did not succeed 
		else:
			# the unit can pet the gator!
			
			# start petting
			player.hud.typeTextWithBuffer(active_unit.unit_name + PET_ANIMAL, true)
			
			show_action_window(constants.BEAST_MASTERY, null, 'Pet', 'Gator', skill_info.PET_GATOR_XP, '...and managed to pet the ') 
			
			yield(signals, "finished_action_success")

			# and remove the BM icon from this tile
			map_actions.remove_map_icon_at_coordinates(the_animal_pos.x, the_animal_pos.y)		
	else:
		player.hud.typeTextWithBuffer(CANT_PET_ANYMORE, false, 'finished_action_failed')	

# tame a beaver!
func initiate_tame_beaver_action():
	# since this action can be taken on an adjacent tile, determine where the beaver is
	var the_beaver_pos = null
	var the_beaver_spot = null
	var beaver_action_id = map_actions.tile_set.find_tile_by_name("Beast_Mastery_Spot_3") # tame beaver
	
	for tile in get_tree().get_current_scene().get_cardinal_tiles(active_unit):
		if (map_actions.get_cellv(tile.tile) == beaver_action_id):
			the_beaver_pos = tile.tile
			the_beaver_spot = map_actions.get_action_spot_at_coordinates(tile.tile)
		
	var daily_tamed = active_unit.beasts_tamed_today
	
	# determine if the unit can tame any more beasts today
	var level_for_more_beasts = skill_info.beast_mastery_tame_restrictions.get(daily_tamed + 1)
	if (level_for_more_beasts != null && level_for_more_beasts <= active_unit.skill_levels[constants.BEAST_MASTERY]):
		# get the level requirement for this spot
		var level_requirement = map_actions.get_level_requirement_at_spot(the_beaver_spot)
		
		if (level_requirement > active_unit.skill_levels[constants.BEAST_MASTERY]):
			player.hud.typeTextWithBuffer(active_unit.NOT_SKILLED_ENOUGH_TEXT, false, 'finished_action_failed') # they did not succeed 
		else:
			# they can tame the beaver!
			var animal_scns = map_actions.get_animals_at_spot(the_beaver_spot)
			animal_scns.shuffle()
			var animal_scn = animal_scns[0]
			
#			 create the animal instance!
			var animal = guild.add_animal(animal_scn)
			animal.set_animal_position(the_beaver_pos)
			
			# the unit tamed a beast
			active_unit.beasts_tamed_today += 1
			
			# and remove the BM icon from this tile
			map_actions.remove_map_icon_at_coordinates(the_beaver_pos.x, the_beaver_pos.y)
			
			# remove the L2, 'BEAVER' tile
			var beaver_id = get_tree().get_current_scene().l2_tiles.get_cellv(the_beaver_pos)
			get_tree().get_current_scene().l2_tiles.set_cellv(the_beaver_pos, -1) # clear the tile
			
			# remove the action tracker from this tile
			var action_id = map_actions.get_cellv(the_beaver_pos)
			map_actions.set_cellv(the_beaver_pos, -1) # clear the tile
			
			# we also need to make sure this gets reset in new_day
			get_tree().get_current_scene().reset_terrain_tracker += [{
				"layer": get_tree().get_current_scene().l2_tiles,
				"pos": the_beaver_pos,
				"id": beaver_id
			}, {
				"layer": map_actions,
				"pos": the_beaver_pos,
				"id": action_id
			}]
			
			# set the npc animal's sprite as invisible since it will be converted to an actual animal unit
			get_tree().get_current_scene().npcs.find_npc_at_tile(the_beaver_pos).overworld_sprite.visible = false
			
			# start taming
			player.hud.typeTextWithBuffer(active_unit.unit_name + TAMED_MISC, true)
			
			show_action_window(constants.BEAST_MASTERY, null, 'Tamed', 'Beaver', animal.tame_xp, '...and tamed the ') 
			
			yield(signals, "finished_action_success")

			# make the animal sprite visible
			animal.animal_sprite.visible = true

# allow beavers to build bridges
func initiate_build_beaver_bridge_action(horizontal = false):
	# get the ids for the corresponding bridge
	var bridge_id = -1
	
	if (horizontal):
		bridge_id = get_tree().get_current_scene().l2_tiles.tile_set.find_tile_by_name('beaver_bridge_horizontal')
	else:
		bridge_id = get_tree().get_current_scene().l2_tiles.tile_set.find_tile_by_name('beaver_bridge_vertical')
		
	# place the bridge!
	get_tree().get_current_scene().l2_tiles.set_cellv(Vector2(active_unit.unit_pos_x, active_unit.unit_pos_y), bridge_id)
	
	# make sure the bridge gets removed in new_day
	get_tree().get_current_scene().reset_terrain_tracker += [{
		"layer": get_tree().get_current_scene().l2_tiles,
		"pos": Vector2(active_unit.unit_pos_x, active_unit.unit_pos_y),
		"id": -1
	}]
	
	# action was successful!
	player.hud.typeTextWithBuffer(active_unit.unit_name + active_unit.BEAVER_BUILT_BRIDGE_TEXT, false, 'finished_action_success')
	
# write a diplomatic letter
func initiate_write_letter_action(param_object):	
	# because this action is triggered from the info screen - that screen is currently open
	# first - determine if the unit can do this action
	var level_requirement = param_object.item.level_requirement_for_action
	
	if (active_unit.skill_levels[param_object.item.associated_skill] > level_requirement):
		# can do the action!
		
		# go ahead and remove the item from the unit
		param_object.unit_info_screen.remove_item() # remove the selected item
		
		# close the info screen
		param_object.unit_info_screen.close_unit_screen()
		
		# make sure we close the dialogue box as well, if it's present
		player.hud.clearText()
		player.hud.completeText()
		player.hud.kill_timers()
		
		# make sure the player state is not set to selecting tile
		player.player_state = player.PLAYER_STATE.SELECTING_ACTION
		
		# now show the action screen
		# start writting
		player.hud.typeTextWithBuffer(active_unit.unit_name + STARTED_WRITING, true)
		
		show_action_window(constants.DIPLOMACY, global_items_list.item_letter, 'Wrote', 
			global_items_list.item_letter.name, global_items_list.item_letter.xp, ['...and wrote a letter!']) 
		
		yield(signals, "finished_action_success")
	else:
		player.hud.typeTextWithBuffer(active_unit.NOT_SKILLED_ENOUGH_TEXT, false, 'finished_viewing_text_generic') # they did not succeed 
		
		yield(signals, "finished_viewing_text_generic")
		
		# unpause the unit info screen
		param_object.unit_info_screen.set_process_input(true)	
	pass

# dig the ground beneath the unit!
func initiate_dig_ground_action(param_object):
	# first, close the info screen
	param_object.unit_info_screen.close_unit_screen()
	
	# make sure we close the dialogue box as well, if it's present
	player.hud.clearText()
	player.hud.completeText()
	player.hud.kill_timers()
	
	# make sure the player state is not set to selecting tile
	player.player_state = player.PLAYER_STATE.SELECTING_ACTION

	var item_here = null
	
	# first, determine if there are any items in this location (from the predefined_list)
	for ground_item in global_items_list.predefined_ground_items:
		if (ground_item.pos == Vector2(active_unit.unit_pos_x, active_unit.unit_pos_y)):
			item_here = ground_item.item
	
	if (item_here != null):
		
		# make sure the unit can hold this item
		if (active_unit.is_inventory_full()):
			player.hud.typeTextWithBuffer(DUG_GROUND_INV_FULL + active_unit.unit_name + CANT_HOLD_ANYTHING_ELSE, false, 'finished_action_failed') # they did not complete the action 
		else:
			# give the unit the item!
			active_unit.receive_item(item_here)
			
			# spends an action
			player.hud.typeTextWithBuffer(active_unit.unit_name + DUG_GROUND_FOUND + item_here.name + "!", false, 'finished_action_success') # they completed the action 
	else:
		# spends an action
		player.hud.typeTextWithBuffer(active_unit.unit_name + DUG_GROUND_FOUND_NOTHING, false, 'finished_action_success') # they completed the action


# meet with a diplomatic leader
func initiate_meet_with_leader_action():
	# since this action can be taken on an adjacent tile, determine where the leader is
	var the_leader_pos = null
	var the_leader_spot = null

	for tile in get_tree().get_current_scene().get_cardinal_tiles(active_unit):
		# check if the tile contains a meet_with_leader action
		if (map_actions.get_actions_at_coordinates(tile.tile)).has(COMPLETE_ACTION_LIST.MEET_WITH_LEADER):
			the_leader_pos = tile.tile
			the_leader_spot = map_actions.get_action_spot_at_coordinates(tile.tile)
			
	
	if (the_leader_pos != null):
		# get the leader 
		var leader_npc = get_tree().get_current_scene().npcs.get_npc_by_name(map_actions.get_leader_name_at_spot(the_leader_spot))
		
		# get the level requirement for this spot
		var level_requirement = map_actions.get_level_requirement_at_spot(the_leader_spot)
		
		# make sure the leader hasn't already been visited today
		if (!leader_npc.met_with_unit_today):
			# make sure we meet the requirement
			if (level_requirement > active_unit.skill_levels[constants.DIPLOMACY]):
				player.hud.typeTextWithBuffer(active_unit.NOT_SKILLED_ENOUGH_TEXT, false, 'finished_action_failed') # they did not succeed 
			else:
				# the unit can meet with the leader!
				player.hud.typeTextWithBuffer(active_unit.unit_name + HELD_A_MEETING, true)
				
				# check if a relationship is established
				var already_established = leader_npc.faction_relation.established
				if (!leader_npc.faction_relation.established):
					leader_npc.faction_relation.established = true # establish it!

				# increase favor!
				leader_npc.faction_relation.favor += active_unit.diplomacy_points
				if (leader_npc.faction_relation.favor > leader_npc.faction_relation.favor_limit):
					leader_npc.faction_relation.favor = leader_npc.faction_relation.favor_limit
					
				var post_text = []
				
				if (!already_established):
					post_text.push_back(RELATION_ESTABLISHED)
					post_text.push_back('Increased favor with ' + leader_npc.diplomatic_leader.name + '!')
				else:
					post_text.push_back('...and increased favor with ' + leader_npc.diplomatic_leader.name + '!')
				
				show_action_window(constants.DIPLOMACY, null, 'Met With', leader_npc.name, 2, post_text) 
				
				yield(signals, "finished_action_success")
				
				# the leader met with someone today
				leader_npc.met_with_unit_today = true
		else:
			player.hud.typeTextWithBuffer(ALREADY_MET_TEXT, false, 'finished_action_failed') # they did not succeed 
	else:
		# not sure how we got here... just set the state back as a failsafe
		player.player_state = player.PLAYER_STATE.SELECTING_TILE

# give gift to a diplomatic leader
func initiate_give_gift_action():
	# since this action can be taken on an adjacent tile, determine where the leader is
	var the_leader_pos = null
	var the_leader_spot = null

	for tile in get_tree().get_current_scene().get_cardinal_tiles(active_unit):
		# check if the tile contains a meet_with_leader action
		if (map_actions.get_actions_at_coordinates(tile.tile)).has(COMPLETE_ACTION_LIST.GIVE_GIFT_TO_LEADER):
			the_leader_pos = tile.tile
			the_leader_spot = map_actions.get_action_spot_at_coordinates(tile.tile)
			
	
	if (the_leader_pos != null):
		# get the leader 
		var leader_npc = get_tree().get_current_scene().npcs.get_npc_by_name(map_actions.get_leader_name_at_spot(the_leader_spot))
		
		# make sure we've established a relationship
		if (leader_npc.faction_relation.established):
			# now open the give gift screen
			gift_screen_node = gift_screen_scn.instance()
			
			camera = get_tree().get_nodes_in_group("Camera")[0]
			
			camera.add_child(gift_screen_node)
			
			gift_screen_node.set_unit(active_unit)
			gift_screen_node.set_npc(leader_npc)
		else:
			player.hud.typeTextWithBuffer(YOU_MUST_ESTABLISH_RELATION, false, 'finished_action_failed') # they did not succeed 
		
# if the unit is woodcutting
func initiate_woodcutting_action():
	# first, determine if the unit has an axe
	var axe = null
	for item in active_unit.current_items:
		if (item.type == global_items_list.ITEM_TYPES.AXE):
			axe = item
	
	if (axe):
		# determine which woodcutting spot the unit is targeting
		var spot = map_actions.get_action_spot_at_coordinates(Vector2(player.curs_pos_x, player.curs_pos_y))
		
		# get the level requirement for this spot
		var level_requirement = map_actions.get_level_requirement_at_spot(spot)
		
		# get a list of wood that can be found at this spot
		var available_wood = map_actions.get_items_at_coordinates(player.curs_pos_x, player.curs_pos_y)
		
		if (level_requirement > active_unit.skill_levels[constants.WOODCUTTING]):
			player.hud.typeTextWithBuffer(active_unit.NOT_SKILLED_ENOUGH_TEXT, false, 'finished_action_failed') # they did not succeed 
		elif (available_wood.size() == 0):
			player.hud.typeTextWithBuffer(active_unit.NO_MORE_WOOD_TEXT, false, 'finished_action_failed') # they did not succeed 
		elif (active_unit.is_inventory_full()):
			player.hud.typeTextWithBuffer(active_unit.INVENTORY_FULL_TEXT, false, 'finished_action_failed') # they did not succeed
		else:
			# get random wood from the list
			available_wood.shuffle()
			var received_wood = available_wood[0]
			
			# remove the wood from the list of available wood
			available_wood.remove(0)
			
			# and update the used_tile items (for if the unit continues to woodcut here)
			map_actions.set_items_at_coordinates(player.curs_pos_x, player.curs_pos_y, available_wood)
			
			# start woodcutting
			player.hud.typeTextWithBuffer(active_unit.unit_name + WOODCUTTING_TEXT, true)
			
			show_action_window(constants.WOODCUTTING, received_wood)
			
	else:
		player.hud.typeTextWithBuffer(active_unit.CANT_WOODCUT_WITHOUT_AXE_TEXT, false, 'finished_action_failed') # they did not succeed

# if the unit is mining
func initiate_mine_action():	
	# first, determine if the unit has a pickaxe
	var pickaxe = null
	for item in active_unit.current_items:
		# make sure the unit cant wield this item as well
		if (item.type == global_items_list.ITEM_TYPES.PICKAXE && item.level_required <= active_unit.skill_levels[constants.MINING]):
			pickaxe = item
	
	if (pickaxe):
		# determine the mining spot the unit is targeting
		var spot = map_actions.get_action_spot_at_coordinates(Vector2(player.curs_pos_x, player.curs_pos_y))
		
		
		# get the level requirement for this spot
		var level_requirement = map_actions.get_level_requirement_at_spot(spot)
		
		# get a list of ore that can be found at this spot
		var available_ore = map_actions.get_items_at_coordinates(player.curs_pos_x, player.curs_pos_y)
		
		if (level_requirement > active_unit.skill_levels[constants.MINING]):
			player.hud.typeTextWithBuffer(active_unit.NOT_SKILLED_ENOUGH_TEXT, false, 'finished_action_failed') # they did not succeed 
		elif (available_ore.size() == 0):
			player.hud.typeTextWithBuffer(active_unit.NO_MORE_ORE_TEXT, false, 'finished_action_failed') # they did not succeed 
		elif (active_unit.is_inventory_full()):
			player.hud.typeTextWithBuffer(active_unit.INVENTORY_FULL_TEXT, false, 'finished_action_failed') # they did not succeed
		else:
			# they can mine!
			available_ore.shuffle()
			
			# check whether or not the unit gets a gemstone!
			var gemstone_collected = constants.chance_test(pickaxe.gemstone_chance)
			
			var received_ore = available_ore[0]
			
			# if gemstone is found, find the gemstone <= to the level of the ore at this location
			if (gemstone_collected):
				var max_level = received_ore.level_to_mine
				for gem in global_items_list.gemstone_list: # these should be sorted by level requirement
					if gem.level_to_mine <= max_level:
						received_ore = gem
	
				# if the unit has the Gemstone Hunter ability, make them ecstatic (frankly, this is too specific to abstract -_-)
				if (global_ability_list.unit_has_ability(active_unit, global_ability_list.ABILITY_GEM_HUNTER_NAME) && 
						!global_ability_list.unit_has_ability(active_unit, global_ability_list.ABILITY_ECSTATIC_NAME)):
					global_ability_list.add_ability_to_unit(active_unit, global_ability_list.ability_ecstatic)
			else:
				# remove the ore from the list of available ore
				available_ore.remove(0)
				
				# and update the used_tile items (for if the unit continues to mine here)
				map_actions.set_items_at_coordinates(player.curs_pos_x, player.curs_pos_y, available_ore)
			
			# start mining
			player.hud.typeTextWithBuffer(active_unit.unit_name + MINING_TEXT, true)
			
			show_action_window(constants.MINING, received_ore)
	else:
		player.hud.typeTextWithBuffer(active_unit.CANT_MINE_WITHOUT_PICKAXE_TEXT, false, 'finished_action_failed') # they did not succeed

# if the unit is tapping a tree
func initiate_tap_tree_action():
	# first, determine if the unit has a tapper
	var tapper = null
	for item in active_unit.current_items:
		# make sure the unit cant wield this item as well
		if (item.type == global_items_list.ITEM_TYPES.TAPPER):
			tapper = item
	
	if (tapper):
		# determine the spot the unit is targeting
		var spot = map_actions.get_action_spot_at_coordinates(Vector2(player.curs_pos_x, player.curs_pos_y))
		
		
		# get a list of resources that can be tapped at this tree
		var available_resources = map_actions.get_items_at_coordinates(player.curs_pos_x, player.curs_pos_y)
		

		if (available_resources.size() == 0):
			player.hud.typeTextWithBuffer(active_unit.NOTHING_HERE_GENERIC_TEXT, false, 'finished_action_failed') # they did not succeed 
		elif (active_unit.is_inventory_full()):
			player.hud.typeTextWithBuffer(active_unit.INVENTORY_FULL_TEXT, false, 'finished_action_failed') # they did not succeed
		else:
			# they can tap the tree!
			available_resources.shuffle()
			
			var received_resource = available_resources[0]

			# remove the resource from the list of available resources
			available_resources.remove(0)
			
			# and update the used_tile items (for if the unit continues to tap here)
			map_actions.set_items_at_coordinates(player.curs_pos_x, player.curs_pos_y, available_resources)
			
			# give the unit the item
			active_unit.receive_item(received_resource)
			
			# read the tap tree text!
			player.hud.typeTextWithBuffer(active_unit.unit_name + TAPPED_TREE_AND_RECEIVED + received_resource.name + "!", false, 'finished_action_success') # they did not succeed
			
	else:
		player.hud.typeTextWithBuffer(active_unit.CANT_TAP_WITHOUT_TAPPER_TEXT, false, 'finished_action_failed') # they did not succeed

func initiate_take_mushroom_action():
		# determine the spot the unit is targeting
		var spot = map_actions.get_action_spot_at_coordinates(Vector2(player.curs_pos_x, player.curs_pos_y))
		
		
		# get a list of resources that can be tapped at this tree
		var available_resources = map_actions.get_items_at_coordinates(player.curs_pos_x, player.curs_pos_y)
		

		if (available_resources.size() == 0):
			player.hud.typeTextWithBuffer(active_unit.NOTHING_HERE_GENERIC_TEXT, false, 'finished_action_failed') # they did not succeed 
		elif (active_unit.is_inventory_full()):
			player.hud.typeTextWithBuffer(active_unit.INVENTORY_FULL_TEXT, false, 'finished_action_failed') # they did not succeed
		else:
			# they can collect the mushrooms!
			available_resources.shuffle()
			
			var received_resource = available_resources[0]

			# remove the resource from the list of available resources
			available_resources.remove(0)
			
			# and update the used_tile items (for if the unit continues to 'take' here)
			map_actions.set_items_at_coordinates(player.curs_pos_x, player.curs_pos_y, available_resources)
			
			# give the unit the item
			active_unit.receive_item(received_resource)
			
			# read the found mushroom text!
			player.hud.typeTextWithBuffer(active_unit.unit_name + FOUND_MUSHROOMS, false, 'finished_action_success') # they did not succeed


func _ready():
	signals.connect("finished_action_success", self, "_on_finished_action", [true])
	signals.connect("finished_action_failed", self, "_on_finished_action", [false])
	
	signals.connect("confirm_end_turn_yes", self, "_on_end_turn", [true])
	signals.connect("confirm_end_turn_no", self, "_on_end_turn", [false])

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

const FISHING_TEXT = " started fishing..."
const WOODCUTTING_TEXT = " started chopping..."
const MINING_TEXT = " started mining..."
const CRAFTING_TEXT = " started crafting..."

const FISH_RECEIVED_TEXT = "and caught a "
const WOOD_RECEIVED_TEXT = "and got some "
const ORE_RECEIVED_TEXT = "and got some "
const CRAFT_RECEIVED_TEXT = "and made a "

const PATH_BLOCKED = 'My path is blocked...'
const UNLOCKED_TEXT = ' unlocked!'
const BECAME_INSPIRED_TEXT = ' became Inspired!'
const DOT_DOT_DOT_TEXT = '...'

enum COMPLETE_ACTION_LIST {
	MOVE,
	DEPOT,
	DINE,
	CRAFT,
	POSIT,
	FISH,
	MINE,
	CHOP,
	CHECK_BIRDHOUSE, # used for Beast Mastery
	TALK, # used for NPCS
	READ_SIGN, # used for signs
	CLIMB_TOWER, # used for towers + revealing regions
	TUNNEL # for caves (Male Miner Only)
	CROSS, # for rivers (Female Angler Only / Or wooden stilts)
	INFO,
	FOCUS,
	MAP, # view the world map
	GUILD, # view the guild info
	NEXT_TURN,
	YES, # for confirmation
	NO, # for confirmation
	TRANSFER_ITEM_AT_DEPOT, # for depot screen
	VIEW_ITEM_INFO_AT_DEPOT, # for depot screen
	TRASH_ITEM_AT_DEPOT, # for depot screen
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
}

const ACTION_LIST_NAMES = [
	'MOVE',
	'DEPOT',
	'DINE',
	'CRAFT',
	'POSIT',
	'FISH',
	'MINE',
	'CHOP',
	'CHECK',
	'TALK',
	'READ',
	'CLIMB',
	'TUNNL',
	'CROSS',
	'INFO',
	'FOCUS',
	'MAP',
	'GUILD',
	'NEXT',
	'YES',
	'NO',
	'MOVE',
	'INFO',
	'TRASH',
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
	'INN'
]

# list of exclusive actions
onready var exclusive_actions = {
	COMPLETE_ACTION_LIST.TUNNEL: 'true',
	COMPLETE_ACTION_LIST.CROSS: 'true'
}

func do_action(action, parent):
	# see if the parent is a unit, and if so, set the active unit
	if not parent.get('unit_id') == null:
		active_unit = parent
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
		COMPLETE_ACTION_LIST.TRASH_ITEM_AT_DEPOT:
			# trash the item (in the depot screen)
			guild.trash_item_at_depot()
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
		COMPLETE_ACTION_LIST.CHECK_BIRDHOUSE:
			initiate_check_birdhouse_action()
		COMPLETE_ACTION_LIST.INFO:
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
		COMPLETE_ACTION_LIST.TALK:
			# talk to an NPC
			get_tree().get_current_scene().npcs.talk_to_npc(active_unit)
		COMPLETE_ACTION_LIST.READ_SIGN:
			# read an adjacent sign
			initiate_read_sign_action(player.active_world_object)
		COMPLETE_ACTION_LIST.CLIMB_TOWER:
			# climb an adjacent tower
			initiate_climb_tower_action(player.active_world_object)
		COMPLETE_ACTION_LIST.TUNNEL:
			# this action can only be taken by the male miner. Allows the unit to travel between 
			# cave's (in the same region)
			initiate_tunnel_action()
		COMPLETE_ACTION_LIST.CROSS:
			# this action can only be taken by the female angler, or a unit holding wooden stilts
			active_unit.cross_water()
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
		camera.remove_child(action_screen_node)
		
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
func show_action_window(skill, reward):
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
	timer.connect("timeout", self, "set_item_reward", [reward, timer])
	add_child(timer)
	timer.start()
	
	# give the item to the unit
	active_unit.receive_item(reward)
	
	# give the xp to the unit
	var level_before = active_unit.skill_levels[skill]
	var xp_before = active_unit.skill_xp[skill]
	var xp_to_gain = reward.xp
	
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

# if the unit is reading a sign
func initiate_read_sign_action(the_sign):
	if (the_sign.type == 'sign'):
		var sign_text = constants.get_sign_text(the_sign.pos)
		player.hud.typeTextWithBuffer(sign_text, false, 'finished_viewing_text_generic')
		yield(signals, "finished_viewing_text_generic")
	
	# change the state back
	player.player_state = player.PLAYER_STATE.SELECTING_TILE

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
	print(selected_birdhouse)
	
	if (selected_birdhouse.data.occupied):
		# determine whether or not the unit can do this
		
		# get the action spot
		var spot = map_actions.get_action_spot_at_coordinates(Vector2(player.curs_pos_x, player.curs_pos_y))
		
		# get the animals that can be found at this spot
		var animal_scns = map_actions.get_animals_at_spot(spot)
		animal_scns.shuffle()
		var animal_scn = animal_scns[0]
		
		
		# create the animal instance!
		var animal = guild.add_animal(animal_scn)
		animal.set_animal_position(Vector2(player.curs_pos_x - 1, player.curs_pos_y))
		
	else:
		player.hud.typeTextWithBuffer(active_unit.NOTHING_HERE_GENERIC_TEXT, false, 'finished_action_failed')
		
		#yield(signals, "finished_viewing_text_generic")

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

func _ready():
	signals.connect("finished_action_success", self, "_on_finished_action", [true])
	signals.connect("finished_action_failed", self, "_on_finished_action", [false])
	
	signals.connect("confirm_end_turn_yes", self, "_on_end_turn", [true])
	signals.connect("confirm_end_turn_no", self, "_on_end_turn", [false])

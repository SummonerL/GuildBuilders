extends Node

# this file will keep track of all of the actions that are available to a unit
# some of these actions will be available only when specific conditions are met, 
# such as being on a tile with a map icon (woodcutting, fishing, etc)

# bring in our items
onready var global_items_list = get_node("/root/Items")

# bring in the global player variables
onready var player = get_node("/root/Player_Globals")

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in our guild variables/functions
onready var guild = get_node("/root/Guild")

# bring in our signals
onready var signals = get_node("/root/Signal_Manager")

# have our map_actions layer, for determining more details about the tile
onready var map_actions = get_tree().get_nodes_in_group(constants.MAP_ACTIONS_GROUP)[0]

# various hud scenes
onready var hud_selection_list_scn = preload("res://Entities/HUD/Selection_List.tscn")

# our action screen (we can instance this when a unit does an action)
onready var action_screen_scn = preload("res://Entities/HUD/Action_Window.tscn")
var action_screen_node

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

const FISH_RECEIVED_TEXT = "and caught a "
const WOOD_RECEIVED_TEXT = "and got some "

enum COMPLETE_ACTION_LIST {
	MOVE,
	DEPOT
	FISH,
	MINE,
	CHOP,
	INFO,
	FOCUS,
	NEXT_TURN,
	YES, # for confirmation
	NO, # for confirmation
	TRANSFER_ITEM_AT_DEPOT, # for depot screen
	VIEW_ITEM_INFO_AT_DEPOT, # for depot screen
	RETURN_TO_GUILD, # for bedtime
	RETURN_TO_CAMP # for bedtime
}

const ACTION_LIST_NAMES = [
	'MOVE',
	'DEPOT',
	'FISH',
	'MINE',
	'CHOP',
	'INFO',
	'FOCUS',
	'NEXT',
	'YES',
	'NO',
	'MOVE',
	'INFO',
	'GUILD',
	'CAMP'
]

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
		COMPLETE_ACTION_LIST.TRANSFER_ITEM_AT_DEPOT:
			# move the item from depot to unit, or visa-versa
			guild.transition_items_at_depot()
		COMPLETE_ACTION_LIST.VIEW_ITEM_INFO_AT_DEPOT:
			# show the item info, at the depot
			guild.show_item_info_at_depot()
		COMPLETE_ACTION_LIST.FISH:
			initiate_fish_action()
		COMPLETE_ACTION_LIST.MINE:
			pass
		COMPLETE_ACTION_LIST.CHOP:
			initiate_woodcutting_action()
		COMPLETE_ACTION_LIST.INFO:
			# let the unit handle this action
			active_unit.do_action(action)
			
		# actions for returning home at night
		COMPLETE_ACTION_LIST.RETURN_TO_GUILD:
			# return the unit to the guild, and continue to send more units to bed (if necessary)
			player.hud.full_text_destruction()
			active_unit.return_to(COMPLETE_ACTION_LIST.RETURN_TO_GUILD)
			get_tree().get_current_scene().send_units_to_bed(true)
		COMPLETE_ACTION_LIST.RETURN_TO_CAMP:
			# return the unit to his/her camp, and continue to send more units to bed (if necessary)
			player.hud.full_text_destruction()
			active_unit.return_to(COMPLETE_ACTION_LIST.RETURN_TO_CAMP)
			get_tree().get_current_scene().send_units_to_bed(true)
		COMPLETE_ACTION_LIST.FOCUS:
			# focus the cursor on the next available unit
			parent.do_action(action)
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
			
func action_window_finished(skill, reward):
	# clear existing text
	player.hud.clearText()
	
	# show different wording based on the action
	match(skill):
		constants.FISHING:
			player.hud.typeText(FISH_RECEIVED_TEXT + reward.name + constants.EXCLAMATION, false, 'finished_action_success') # we do have a signal
		constants.WOODCUTTING:
			player.hud.typeText(WOOD_RECEIVED_TEXT + reward.name + constants.EXCLAMATION, false, 'finished_action_success') # we do have a signal
		_:
			# do nothing
			pass
		
		
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
		
		# check north
		if (spot == null):
			spot = map_actions.get_action_spot_at_coordinates(Vector2(player.curs_pos_x, player.curs_pos_y - 1))
			
		# check east
		if (spot == null):
			spot = map_actions.get_action_spot_at_coordinates(Vector2(player.curs_pos_x + 1, player.curs_pos_y))
			
		# check south
		if (spot == null):
			spot = map_actions.get_action_spot_at_coordinates(Vector2(player.curs_pos_x, player.curs_pos_y + 1))
			
		# check west
		if (spot == null):
			spot = map_actions.get_action_spot_at_coordinates(Vector2(player.curs_pos_x - 1, player.curs_pos_y))
			
		# get a list of fish that can be found at this spot
		var available_fish = map_actions.get_items_at_spot(spot)
		
		if (available_fish.size() == 0):
			player.hud.typeTextWithBuffer(active_unit.NO_MORE_FISH_TEXT, false, 'finished_action_failed') # they did not succeed 
		elif (active_unit.is_inventory_full()):
			player.hud.typeTextWithBuffer(active_unit.INVENTORY_FULL_TEXT, false, 'finished_action_failed') # they did not succeed
		else:
			# get a random fish from the list
			available_fish.shuffle()
			var received_fish = available_fish[0]
			
			# start fishing
			player.hud.typeTextWithBuffer(active_unit.unit_name + FISHING_TEXT, true)
			
			show_action_window(constants.FISHING, received_fish)
			
	else:
		player.hud.typeTextWithBuffer(active_unit.CANT_FISH_WITHOUT_ROD_TEXT, false, 'finished_action_failed') # they did not succeed

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

		# get a list of wood that can be found at this spot
		var available_wood = map_actions.get_items_at_spot(spot)
		
		if (available_wood.size() == 0):
			player.hud.typeTextWithBuffer(active_unit.NO_MORE_WOOD_TEXT, false, 'finished_action_failed') # they did not succeed 
		elif (active_unit.is_inventory_full()):
			player.hud.typeTextWithBuffer(active_unit.INVENTORY_FULL_TEXT, false, 'finished_action_failed') # they did not succeed
		else:
			# get random wood from the list
			available_wood.shuffle()
			var received_wood = available_wood[0]
			
			# start woodcutting
			player.hud.typeTextWithBuffer(active_unit.unit_name + WOODCUTTING_TEXT, true)
			
			show_action_window(constants.WOODCUTTING, received_wood)
			
	else:
		player.hud.typeTextWithBuffer(active_unit.CANT_WOODCUT_WITHOUT_AXE_TEXT, false, 'finished_action_failed') # they did not succeed

func _ready():
	signals.connect("finished_action_success", self, "_on_finished_action", [true])
	signals.connect("finished_action_failed", self, "_on_finished_action", [false])
	
	signals.connect("confirm_end_turn_yes", self, "_on_end_turn", [true])
	signals.connect("confirm_end_turn_no", self, "_on_end_turn", [false])

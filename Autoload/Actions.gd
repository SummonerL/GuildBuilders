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

# bring in our signals
onready var signals = get_node("/root/Signal_Manager")

# have our map_actions layer, for determining more details about the tile
onready var map_actions = get_tree().get_nodes_in_group(constants.MAP_ACTIONS_GROUP)[0]

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
const FISHING_TEXT = " started fishing..."
const FISH_RECEIVED_TEXT = "and caught a "

enum COMPLETE_ACTION_LIST {
	MOVE,
	FISH,
	MINE,
	CHOP,
	INFO
}

const ACTION_LIST_NAMES = [
	'MOVE',
	'FISH',
	'MINE',
	'CHOP',
	'INFO'
]

func do_action(action, unit):
	active_unit = unit
	
	match (action):
		COMPLETE_ACTION_LIST.MOVE:
			# let the unit handle this action
			unit.do_action(action)
		COMPLETE_ACTION_LIST.FISH:
			initiate_fish_action()
		COMPLETE_ACTION_LIST.MINE:
			pass
		COMPLETE_ACTION_LIST.CHOP:
			pass
		COMPLETE_ACTION_LIST.INFO:
			# let the unit handle this action
			unit.do_action(action)

func action_window_finished(skill, reward):
	# clear existing text
	player.hud.clearText()
	
	# show different wording based on the action
	match(skill):
		constants.FISHING:
			player.hud.typeText(FISH_RECEIVED_TEXT + reward.name + constants.EXCLAMATION, false, 'finished_action') # we do have a signal
		_:
			# do nothing
			pass
		
		
func finished_action(): # callback from dialogue
	# we are finished with the action
	camera.remove_child(action_screen_node)
	
	# turn the music back up
	get_tree().get_current_scene().heighten_background_music()
	
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
	action_screen_node.set_skill(constants.FISHING)
	
	# show the item being received, after 3 seconds
	var timer = Timer.new()
	timer.wait_time = SKILL_WAIT_TIME
	timer.connect("timeout", self, "set_item_reward", [reward, timer])
	add_child(timer)
	timer.start()
	
	# give the item to the unit
	
	# give the xp to the unit
	var level_before = active_unit.skill_levels[skill]
	var xp_before = active_unit.skill_xp[skill]
	var xp_to_gain = reward.xp
	active_unit.gain_xp(xp_to_gain, skill)
	var xp_after = active_unit.skill_xp[skill]
	
	# and then, show the experience gained
	var timer_xp = Timer.new()
	timer_xp.wait_time = SKILL_WAIT_TIME + 1.5
	timer_xp.connect("timeout", self, "show_xp_reward", [reward, skill, level_before, xp_after, xp_before, timer_xp])
	add_child(timer_xp)
	timer_xp.start()
	
func show_xp_reward(reward, skill, level_before, xp_after, xp_before, timer = null):
	if (timer):
		timer.stop()
		remove_child(timer)
		
	action_screen_node.show_xp_reward(active_unit, reward, skill, level_before, xp_after, xp_before, self)

func set_item_reward(reward, timer = null):
	if (timer):
		timer.stop()
		remove_child(timer)

	action_screen_node.receive_item(reward)

func initiate_fish_action():
	# first, determine if the unit has a fishing rod
	var rod = null
	for item in active_unit.current_items:
		if (item.type == global_items_list.ITEM_TYPES.ROD):
			rod = item
	
	if (rod):
		# determine which fishing spot the unit is targeting
		var spot = map_actions.get_action_at_coordinates(Vector2(player.curs_pos_x, player.curs_pos_y))
		
		# check north
		if (spot == null):
			spot = map_actions.get_action_at_coordinates(Vector2(player.curs_pos_x, player.curs_pos_y - 1))
			
		# check east
		if (spot == null):
			spot = map_actions.get_action_at_coordinates(Vector2(player.curs_pos_x + 1, player.curs_pos_y))
			
		# check south
		if (spot == null):
			spot = map_actions.get_action_at_coordinates(Vector2(player.curs_pos_x, player.curs_pos_y + 1))
			
		# check west
		if (spot == null):
			spot = map_actions.get_action_at_coordinates(Vector2(player.curs_pos_x - 1, player.curs_pos_y))
			
		# get a list of fish that can be found at this spot
		var available_fish = map_actions.get_items_at_spot(spot)
		
		if (available_fish.size() == 0):
			player.hud.typeTextWithBuffer(active_unit.NO_MORE_FISH_TEXT)
		else:
			# get a random fish from the list
			available_fish.shuffle()
			var received_fish = available_fish[0]
			
			# start fishing
			player.hud.typeTextWithBuffer(active_unit.unit_name + FISHING_TEXT, true)
			
			show_action_window(constants.FISHING, received_fish)
			
	else:
		player.hud.typeTextWithBuffer(active_unit.CANT_FISH_WITHOUT_ROD_TEXT)

func _ready():
	signals.connect("finished_action", self, "finished_action")

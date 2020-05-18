extends Node2D

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in our game config vars
onready var game_cfg_vars = get_node("/root/Game_Config")

# bring in our global player variables
onready var player = get_node("/root/Player_Globals")

# bring in our guild variables/functions
onready var guild = get_node("/root/Guild")

# have our map_actions layer, for determining more details about the tile
onready var map_actions = get_tree().get_nodes_in_group(constants.MAP_ACTIONS_GROUP)[0]

# bring in our signals
onready var signals = get_node("/root/Signal_Manager")

# A Test of Artistry...
# ... a game by
# Arid Bard (Elliot Simpson)

# Overworld Scene (Main)

# bring in our global action list
onready var global_action_list = get_node("/root/Actions")

# bring in our abilities
onready var global_ability_list = get_node("/root/Abilities")

# preload our game objects
onready var cursor_scn = preload("res://Entities/Player/Cursor.tscn")
onready var camera_scn = preload("res://Entities/Camera/Camera.tscn")
onready var hud_scn = preload("res://Entities/HUD/Dialogue.tscn")
onready var hud_tile_info_scn = preload("res://Entities/HUD/Tile_Info.tscn")
onready var hud_time_of_day_info_scn = preload("res://Entities/HUD/Time_Of_Day_Info.tscn")
onready var clock_scn = preload("res://Entities/HUD/Clock/Clock.tscn")
onready var scene_transitioner_scn = preload("res://Scenes/Transition_Scene/Transition_Scene.tscn")
onready var world_map_scn = preload("res://Entities/HUD/World_Map_Scene.tscn")
onready var npcs_scn = preload("res://Entities/NPCs/NPC.tscn")

onready var l1_tiles = get_node("World_Map_L1")
onready var l2_tiles = get_node("World_Map_L2")
onready var world_map_icons = get_node("World_Map_Icons")
onready var hidden_tile_icons = get_node("Hidden_Tiles")
onready var hidden_tiles = get_node("Hidden_Tile_Tracker")
onready var building_tiles = get_node("Buildings")

# keep track of the initial state of the map icons (so we can reset each day)
onready var initial_world_map_icons = world_map_icons.duplicate()

onready var time_shaders = [
	preload("res://Sprites/Shaders/12_AM_Shader.tres"),
	preload("res://Sprites/Shaders/1_AM_Shader.tres"),
	preload("res://Sprites/Shaders/2_AM_Shader.tres"),
	preload("res://Sprites/Shaders/3_AM_Shader.tres"),
	preload("res://Sprites/Shaders/4_AM_Shader.tres"),
	preload("res://Sprites/Shaders/5_AM_Shader.tres"),
	preload("res://Sprites/Shaders/6_AM_Shader.tres"),
	preload("res://Sprites/Shaders/7_AM_Shader.tres"),
	preload("res://Sprites/Shaders/8_AM_Shader.tres"),
	preload("res://Sprites/Shaders/9_AM_Shader.tres"),
	preload("res://Sprites/Shaders/10_AM_Shader.tres"),
	preload("res://Sprites/Shaders/11_AM_Shader.tres"),
	preload("res://Sprites/Shaders/12_PM_Shader.tres"),
	preload("res://Sprites/Shaders/1_PM_Shader.tres"),
	preload("res://Sprites/Shaders/2_PM_Shader.tres"),
	preload("res://Sprites/Shaders/3_PM_Shader.tres"),
	preload("res://Sprites/Shaders/4_PM_Shader.tres"),
	preload("res://Sprites/Shaders/5_PM_Shader.tres"),
	preload("res://Sprites/Shaders/6_PM_Shader.tres"),
	preload("res://Sprites/Shaders/7_PM_Shader.tres"),
	preload("res://Sprites/Shaders/8_PM_Shader.tres"),
	preload("res://Sprites/Shaders/9_PM_Shader.tres"),
	preload("res://Sprites/Shaders/10_PM_Shader.tres"),
	preload("res://Sprites/Shaders/11_PM_Shader.tres"),
]

# various hud scenes
onready var hud_selection_list_scn = preload("res://Entities/HUD/Selection_List.tscn")

# game music
const MIN_VOL = -80 # used for fading in / out
const MED_VOL = -25
const DAMPENED_VOL = -15
var active_bg_music
var max_vol

onready var twelve_pm_loop = get_node("12PM_Loop")
onready var three_pm_loop = get_node("3PM_Loop")
onready var five_pm_loop = get_node("5PM_Loop")

# tween for fading in / out audio
onready var tween_out = get_node("Fade_Out_Tween")
onready var tween_in = get_node("Fade_In_Tween")
export var transition_duration_out = 3.0
export var transition_duration_in = 1.5
export var transition_type = 1 # TRANS_SINE

# list of actions that are available when not selecting a unit
onready var action_list = [
	global_action_list.COMPLETE_ACTION_LIST.FOCUS,
	global_action_list.COMPLETE_ACTION_LIST.MAP,
	global_action_list.COMPLETE_ACTION_LIST.GUILD,
	global_action_list.COMPLETE_ACTION_LIST.NEXT_TURN
]

# a variable used just to track the unit we are currently focused on
var focused_unit

# game instances
var cursor
var camera
var hud_tile_info
var hud_tod_info
var world_map_node
var npcs

func gameInit():
	cursor = cursor_scn.instance()
	camera = camera_scn.instance()
	player.hud = hud_scn.instance()
	hud_tile_info = hud_tile_info_scn.instance()
	hud_tod_info = hud_time_of_day_info_scn.instance()
	npcs = npcs_scn.instance()
	
	add_child(camera)
	camera.add_child(hud_tile_info) # make the hud a child of the camera
	camera.add_child(hud_tod_info)
	add_child(cursor)
	camera.add_child(player.hud)
	
	# connect signals
	signals.connect("finished_viewing_wake_up_text", self, '_on_finished_viewing_wake_up_text', [])
	signals.connect("finished_viewing_bedtime_text", self, '_on_finished_viewing_bedtime_text', [])
	
	# add units to the player's party
	player.party.add_unit(constants.UNIT_TYPES.ANGLER_MALE)
	player.party.add_unit(constants.UNIT_TYPES.ANGLER_FEMALE)
	player.party.add_unit(constants.UNIT_TYPES.WOODCUTTER_MALE)
	player.party.add_unit(constants.UNIT_TYPES.WOODCUTTER_FEMALE)
	player.party.add_unit(constants.UNIT_TYPES.WOODWORKER_MALE)
	player.party.add_unit(constants.UNIT_TYPES.WOODWORKER_FEMALE)
	player.party.add_unit(constants.UNIT_TYPES.MINER_MALE)
	player.party.add_unit(constants.UNIT_TYPES.MINER_FEMALE)
	
	# add npcs to the world!
	add_child(npcs)
	
	# lights, camera, action!
	camera.turnOn()
	
	# start looping our background music
	five_pm_loop.play()
	active_bg_music = five_pm_loop
	max_vol = active_bg_music.volume_db
	
	# initialize some player variables (that haven't already been initialized')
	# get the time of day info node ()
	player.time_of_day_info_node = get_tree().get_nodes_in_group(constants.TIME_OF_DAY_INFO_GROUP)[0]

	# hide all of the hidden tiles
	hide_show_tiles()

	# we begin a new day :) 
	new_day(true)
	
# display the world map
func display_world_map():
	# pause this node
	set_process_input(false)

	world_map_node = world_map_scn.instance()
	add_child(world_map_node)
	
func kill_world_map_screen():
	# unpause the node
	set_process_input(true)

	remove_child(world_map_node)
	
	# change the player state
	player.player_state = player.PLAYER_STATE.SELECTING_TILE
	
# hide / show tiles based on their status
func hide_show_tiles():
	for region in constants.regions:
		if (region.hidden):
			# hide the region
			hide_region(region)
		else:
			# show the region
			show_region(region)
	
func hide_region(region):
	var x = region.x
	var y = region.y
	
	for n1 in range(10):
		for n2 in range(10):
			hidden_tile_icons.set_cellv(Vector2(x, y), 
				hidden_tile_icons.tile_set.find_tile_by_name('hidden_tile'))
			x += 3
		x = region.x
		y += 3
		
	x = region.x
	y = region.y
	
	for n1 in range(30):
		for n2 in range(30):
			hidden_tiles.set_cellv(Vector2(x + n1, y + n2), 
				hidden_tiles.tile_set.find_tile_by_name('hidden_tile'))

func show_region(region):
	var x = region.x
	var y = region.y
	
	for n1 in range(10):
		for n2 in range(10):
			hidden_tile_icons.set_cellv(Vector2(x, y), -1)
			x += 3
		x = region.x
		y += 3
		
	x = region.x
	y = region.y
	
	for n1 in range(30):
		for n2 in range(30):
			hidden_tiles.set_cellv(Vector2(x + n1, y + n2), -1)

# end the day
func end_day():
	# update the player state
	player.player_state = player.PLAYER_STATE.BETWEEN_DAYS
	
	# scene transition fade out
	var fade_out = scene_transitioner_scn.instance()
	add_child(fade_out)
	
	fade_out.white_in.visible = false
	fade_out.white_out.visible = true
	
	fade_out.fade_out_scene(0)
	
	# kill any text on the screen
	player.time_of_day_info_node.clear_time_of_day_info_text()
	hud_tile_info.clear_tile_info_text()
	player.time_of_day_info_node.hide()
	hud_tile_info.hide()
	
	yield(fade_out, "scene_faded_out")
	
	# reposition the cursor
	cursor.focus_on(player.guild_hall_x + 1, player.guild_hall_y + 2, false) # don't reprint tile / time info

	# increment the day counter
	player.current_day += 1
	
	# start a new day
	new_day(true, fade_out)

# start a new day!
func new_day(fade = false, fade_node = null):

	# remove daily abilities from the previous day
	player.party.remove_abilities_of_type(global_ability_list.ABILITY_TYPES.DAILY)
	
	# determine which units did/didn't eat, and make them hungry, if necessary (make sure we are not on the first day)
	if (player.current_day > 1):
		for unit in player.party.party_members:
			if (!player.party.did_unit_eat(unit)):
				global_ability_list.add_ability_to_unit(unit, global_ability_list.ability_hungry)
	
	# remove any food abilities from the previous day
	player.party.remove_abilities_of_type(global_ability_list.ABILITY_TYPES.FOOD)
	
	# remove 'INN' from the list of shelter locations
	player.party.remove_inn_locations()
	
	# reset innkeeper dialogue
	npcs.reset_innkeeper_dialogue()
	
	# check for any guild abilities
	guild.check_guild_abilities()
	
	player.party.party_members.sort_custom(self, "sort_units_by_wake_up")
	
	var earliest_unit = player.party.party_members[0]
	# set the current time to this unit's wake up time
	player.current_time_of_day = earliest_unit.wake_up_time

	# apply shader for the current time of day
	apply_time_shader()
	
	# show the applicable building tiles
	show_applicable_building_tiles()
	
	# reset the world map icons (everthing regrew overnight!)
	remove_child(world_map_icons)
	add_child(initial_world_map_icons.duplicate())
	world_map_icons = get_node("World_Map_Icons")
	
	# reset tiles that are 'used' 
	map_actions.reset_used_tiles()
	
	# mark all units as 'yet to act'
	player.party.reset_yet_to_act()
	
	if (fade):
		# scene transition fade in
		
		var fade_in
		# reuse the fade node if we already have one
		if (fade_node):
			fade_in = fade_node
		else:
			fade_in = scene_transitioner_scn.instance()
			add_child(fade_in)
			
		fade_in.white_in.visible = true
		fade_in.white_out.visible = false
		
		fade_in.white_in.visible = true
		fade_in.white_out.visible = false
		fade_in.fade_in_scene(1)
		
		yield(fade_in, "scene_faded_in")
		
		remove_child(fade_in)
	
	# show the overworld huds
	
	# and wake up units (no delay)
	wake_up_units(true)

# called to show the clock animation when the time moves forward
func show_clock_anim():
	add_child(clock_scn.instance())

# determine the current background music state. Whether or not it needs to be changed, based on the current time
func determine_music_state():
	match(player.current_time_of_day):
		12:
			# time to change songs
			fade_out_background_music()
		14:
			fade_out_background_music()
		17:
			fade_out_background_music()
		_:
			# bau - keep playing music :
			pass
	
# dampen background music
func dampen_background_music():
	active_bg_music.volume_db += DAMPENED_VOL
	
# pause the bg music
func pause_background_music():
	active_bg_music.stream_paused = true

# resume the bg music
func resume_background_music():
	active_bg_music.stream_paused = false
	
# raise background music
func heighten_background_music():
	active_bg_music.volume_db = max_vol
	
# fade out the active background music
func fade_out_background_music():
	fade_out(active_bg_music)

# helper function to fade out audio streams
func fade_out(audio_stream):
	# tween music volume down to 0
	tween_out.interpolate_property(audio_stream, "volume_db", audio_stream.volume_db, MIN_VOL, transition_duration_out, transition_type, Tween.EASE_IN, 0)
	
	# when the tween ends, the music will be stopped
	tween_out.connect("tween_completed", self, "stop_audio", [], tween_out.CONNECT_ONESHOT)
	tween_out.start()

# helper function to fade in an audio stream	
func fade_in(audio_stream, vol_buffer = 0):
	var fade_to_vol = game_cfg_vars.background_music_vol + vol_buffer # volume buffer is used for tracks that are slightly quieter / louder
	audio_stream.volume_db = MED_VOL
	audio_stream.play()
	tween_in.interpolate_property(audio_stream, "volume_db", MED_VOL, fade_to_vol, transition_duration_in, transition_type, Tween.EASE_IN, 0)
	tween_in.start()

func stop_audio(audio_stream, _key = null):
	# stop the music -- otherwise it continues to run at silent volume
	audio_stream.stop()

	# determine the next track to play
	determine_background_music()

func determine_background_vol_buffer():
	pass
	
func determine_background_music():
	match(player.current_time_of_day):
		12:
			active_bg_music = twelve_pm_loop
			max_vol = active_bg_music.volume_db
			fade_in(active_bg_music, 4) # add a volume buffer (this song is quieter :( )
		14:
			active_bg_music = three_pm_loop
			max_vol = active_bg_music.volume_db
			fade_in(active_bg_music, 4)
		17:
			active_bg_music = five_pm_loop
			max_vol = active_bg_music.volume_db
			fade_in(active_bg_music)
		_:
			# play nothing (this should never happen)
			pass

# useful functioning for determining the 4 cardinal tiles adjacent to a unit
func get_cardinal_tiles(unit):
	var tiles = []
	
	# north
	tiles.append	({
		"tile": Vector2(unit.unit_pos_x, unit.unit_pos_y - 1),
		"cord": 'y',
		"direction": -1
	})
	# east
	tiles.append	({
		"tile": Vector2(unit.unit_pos_x + 1, unit.unit_pos_y),
		"cord": 'x',
		"direction": 1
	})
	# south
	tiles.append	({
		"tile": Vector2(unit.unit_pos_x, unit.unit_pos_y + 1),
		"cord": 'y',
		"direction": 1
	})
	# west
	tiles.append	({
		"tile": Vector2(unit.unit_pos_x - 1, unit.unit_pos_y),
		"cord": 'x',
		"direction": -1
	})
	
	return tiles

func sort_units_by_wake_up(a, b):
	return a.wake_up_time < b.wake_up_time

func unit_exists_at_coordinates(x, y):
	var exists = false
	for unit in player.party.party_members:
		if (unit.unit_pos_x == x && unit.unit_pos_y == y):
			exists = true
	return exists

# function for finding an empty spot
func find_available_guild_spot():
	# there are twelve spots adjacent to the guild hall. Any of these are eligible for placing units
	# remember that the x, y pos is the top left of the guild
	var spot = null
	
	if (!unit_exists_at_coordinates(player.guild_hall_x + 1, player.guild_hall_y + 2)):
		spot = Vector2(player.guild_hall_x + 1, player.guild_hall_y + 2)
		
	elif (!unit_exists_at_coordinates(player.guild_hall_x, player.guild_hall_y + 2)):
		spot =  Vector2(player.guild_hall_x, player.guild_hall_y + 2)
		
	elif (!unit_exists_at_coordinates(player.guild_hall_x - 1, player.guild_hall_y + 1)):
		spot = Vector2(player.guild_hall_x - 1, player.guild_hall_y + 1)
		
	elif (!unit_exists_at_coordinates(player.guild_hall_x - 1, player.guild_hall_y)):
		spot = Vector2(player.guild_hall_x - 1, player.guild_hall_y)

	elif (!unit_exists_at_coordinates(player.guild_hall_x + 2, player.guild_hall_y + 1)):
		spot = Vector2(player.guild_hall_x + 2, player.guild_hall_y + 1)
		
	elif (!unit_exists_at_coordinates(player.guild_hall_x + 2, player.guild_hall_y)):
		spot = Vector2(player.guild_hall_x + 2, player.guild_hall_y)
		
	elif (!unit_exists_at_coordinates(player.guild_hall_x, player.guild_hall_y - 1)):
		spot = Vector2(player.guild_hall_x, player.guild_hall_y - 1)
		
	elif (!unit_exists_at_coordinates(player.guild_hall_x + 1, player.guild_hall_y - 1)):
		spot = Vector2(player.guild_hall_x + 1, player.guild_hall_y - 1)
		
	elif (!unit_exists_at_coordinates(player.guild_hall_x - 1, player.guild_hall_y + 2)):
		spot = Vector2(player.guild_hall_x - 1, player.guild_hall_y + 2)
		
	elif (!unit_exists_at_coordinates(player.guild_hall_x + 2, player.guild_hall_y + 2)):
		spot = Vector2(player.guild_hall_x + 2, player.guild_hall_y + 2)
		
	elif (!unit_exists_at_coordinates(player.guild_hall_x - 1, player.guild_hall_y - 1)):
		spot = Vector2(player.guild_hall_x - 1, player.guild_hall_y - 1)
		
	elif (!unit_exists_at_coordinates(player.guild_hall_x + 2, player.guild_hall_y - 1)):
		spot = Vector2(player.guild_hall_x + 2, player.guild_hall_y - 1)
		
	return spot
	
func _on_finished_viewing_wake_up_text():
	player.hud.clearText()
	player.hud.completeText()
	player.hud.kill_timers()
	
	player.player_state = player.PLAYER_STATE.SELECTING_TILE
	
	wake_up_units()
	
func _on_finished_viewing_bedtime_text():
	player.hud.clearText()
	player.hud.completeText()
	player.hud.kill_timers()
	
	# create a select list for determining where the unit should return for sleep
	var hud_selection_list_node = hud_selection_list_scn.instance()
	add_child(hud_selection_list_node)
	
	player.hud.typeText(constants.WHERE_SHOULD_I_RETURN_TEXT, true)

	player.player_state = player.PLAYER_STATE.SELECTING_ACTION
	hud_selection_list_node.populate_selection_list(focused_unit.shelter_locations, focused_unit, true, false, false, false) # can not cancel, position to the right
	
	# temporarily stop processing input on the cursor (pause the node)
	cursor.set_process_input(false)

func send_units_to_bed(delay = true, went_to_sleep = false):
	# if there are no units left to act, all units have gone to sleep. Time to end the day!
	if (player.party.yet_to_act.size() == 0):
		end_day()
		
	# determine if any unit's are going to bed at this hour
	var unit_to_bed = null
	for unit in player.party.party_members:
		if (unit.bed_time == player.current_time_of_day && unit.unit_awake):
			unit_to_bed = unit
			break
	
	# send the unit to bed
	if (unit_to_bed):
		focused_unit = unit_to_bed
		unit_to_bed.unit_awake = false
		
		# remove them as an active unit
		player.party.reset_yet_to_act()
		
		# show the unit's bedtime scene (after a short delay)
		player.player_state = player.PLAYER_STATE.VIEWING_DIALOGUE
		if (delay):
			var timer = Timer.new()
			timer.wait_time = constants.SHORT_DELAY
			timer.connect("timeout", self, "show_unit_bedtime", [unit_to_bed, timer])
			add_child(timer)
			timer.start()
		else:
			show_unit_bedtime(unit_to_bed)
	else:
		# unpause the cursor, if it was paused
		cursor.set_process_input(true)
		if (player.party.yet_to_act.size() > 0 && went_to_sleep):
			# if we still have units left to act, (and others have already gone to bed) focus on them
			player.player_state = player.PLAYER_STATE.SELECTING_TILE
			var foc_unit = player.party.yet_to_act[0]
			cursor.focus_on(foc_unit.unit_pos_x, foc_unit.unit_pos_y)
		
		

func show_unit_bedtime(unit_to_bed, timer = null):
	if (timer):
		timer.stop()
		remove_child	(timer)
	
	# focus the cursor/camera on the unit
	cursor.focus_on(unit_to_bed.unit_pos_x, unit_to_bed.unit_pos_y)
	
	# read the unit's bedttime text
	player.hud.typeTextWithBuffer(unit_to_bed.BED_TIME_TEXT, false, 'finished_viewing_bedtime_text')

func wake_up_units(delay = true):
	# determine if any unit's are waking up at this hour
	var unit_to_wake = null
	for unit in player.party.party_members:
		if (unit.wake_up_time == player.current_time_of_day && !unit.unit_awake):
			unit_to_wake = unit
			break
			
	# wake up the unit
	if (unit_to_wake):
		unit_to_wake.unit_awake = true
		# add them as an active unit
		player.party.reset_yet_to_act()
		
		# show the unit's wakeup scene (after a short delay)
		player.player_state = player.PLAYER_STATE.VIEWING_DIALOGUE
		if (delay):
			var timer = Timer.new()
			timer.wait_time = constants.SHORT_DELAY
			timer.connect("timeout", self, "show_unit_wakeup", [unit_to_wake, timer])
			add_child(timer)
			timer.start()
		else:
			show_unit_wakeup(unit_to_wake)
	else:
		# no units left to wake up, start sending units to bed, if necessary
		send_units_to_bed(false)
		

func show_unit_wakeup(unit_to_wake, timer = null):
	if (timer):
		timer.stop()
		remove_child	(timer)
		
	# make sure our huds are displayed
	player.time_of_day_info_node.update_time_of_day_info_text()
	player.time_of_day_info_node.show()
	hud_tile_info.update_tile_info_text()
	hud_tile_info.show()
		
	# position the unit
	var pos
	if (unit_to_wake.unit_pos_x == player.guild_hall_x && unit_to_wake.unit_pos_y == player.guild_hall_y):
		pos = find_available_guild_spot()
	else:
		pos = Vector2(unit_to_wake.unit_pos_x, unit_to_wake.unit_pos_y)
	
	# focus the cursor/camera on the unit
	cursor.focus_on(pos.x, pos.y)
	
	unit_to_wake.set_unit_pos(pos.x, pos.y)
	
	# make sure the default animation is playing
	unit_to_wake.unit_sprite_node.animation = "default"
	
	# make the unit's sprite visible
	unit_to_wake.unit_sprite_node.visible = true
	
	# short delay
	yield(get_tree().create_timer(.6), "timeout")
	
	# read the unit's wake-up text, or the hungry text, if they forgot to eat!
	if (player.party.is_unit_hungry(unit_to_wake)):
		player.hud.typeTextWithBuffer(unit_to_wake.HUNGRY_TEXT, false, 'finished_viewing_wake_up_text')
	else:
		player.hud.typeTextWithBuffer(unit_to_wake.WAKE_UP_TEXT, false, 'finished_viewing_wake_up_text')
	

func apply_time_shader():
	# change the shader based on the current time of day
	l1_tiles.material = time_shaders[player.current_time_of_day]
	l2_tiles.material = time_shaders[player.current_time_of_day]
	building_tiles.material = time_shaders[player.current_time_of_day]

# show the day or night buildings, based on the time of day
func show_applicable_building_tiles():
	if player.current_time_of_day > 8 && player.current_time_of_day < 19:
		# show day sprites
		var tileset = building_tiles.get_tileset()
		building_tiles.set_cellv(Vector2(player.guild_hall_x, player.guild_hall_y), tileset.find_tile_by_name("guild_hall"))
	else:
		# show night sprites
		var tileset = building_tiles.get_tileset()
		building_tiles.set_cellv(Vector2(player.guild_hall_x, player.guild_hall_y), tileset.find_tile_by_name("guild_hall_night"))

# function for opening the action list when not selecting a unit
func show_turn_action_list():
	# add a selection list instance to our camera
	var hud_selection_list_node = hud_selection_list_scn.instance()
	camera.add_hud_item(hud_selection_list_node)
	
	# populate the action list with the current list of actions this unit can take
	hud_selection_list_node.populate_selection_list(action_list, self)

# helper function for determining if a unit is on / adjacent to unique tiles with specific actions
func populate_unique_actions(unit):
	var unique_actions = []
	
	# determine if the unit is adjacent to a river
	var river_adjacent = false
	var water_id = l1_tiles.tile_set.find_tile_by_name('water')
	
	for tile in get_cardinal_tiles(unit):
		if (l1_tiles.get_cellv(tile.tile) == water_id):
			# next to water. Determine if the tile adjacent to that is moveable
			var adj = tile.tile
			adj[tile.cord] += tile.direction
			var mvmt_cost = l1_tiles.get_movement_cost(l1_tiles.get_tile_at_coordinates(adj))
			if (l2_tiles.get_tile_at_coordinates(adj) != null):
				mvmt_cost += l2_tiles.get_movement_cost(l2_tiles.get_tile_at_coordinates(adj))
			
			if (mvmt_cost < constants.CANT_MOVE):
				river_adjacent = true
	
	if (river_adjacent):
		unique_actions += map_actions.river_actions 
		
	
	# determine if we are near any npcs
	var adjacent_npc = null
	for tile in get_cardinal_tiles(unit):
		if (adjacent_npc == null):
			adjacent_npc = npcs.find_npc_at_tile(tile.tile)
			
	if (adjacent_npc != null):
		npcs.set_active_npc(adjacent_npc)
		unique_actions += map_actions.npc_actions
	
	# determine if we are near any signs
	var adjacent_sign = null
	var sign_id = l2_tiles.tile_set.find_tile_by_name('sign')
	for tile in get_cardinal_tiles(unit):
		if (l2_tiles.get_cellv(tile.tile) == sign_id && adjacent_sign == null):
			adjacent_sign = {'type': 'sign', 'pos': tile.tile}
			
	if (adjacent_sign != null):
		player.active_world_object = adjacent_sign
		unique_actions += map_actions.sign_actions
		
	# determine if we are near any towers
	var adjacent_tower = null
	var tower_id = l2_tiles.tile_set.find_tile_by_name('tower')
	for tile in get_cardinal_tiles(unit):
		if (l2_tiles.get_cellv(tile.tile) == tower_id && adjacent_tower == null):
			adjacent_tower = {'type': 'tower', 'pos': tile.tile}
			
	if (adjacent_tower != null):
		player.active_world_object = adjacent_tower
		unique_actions += map_actions.tower_actions
	
	return unique_actions
	
# when the action list is cancelled, go back to selecting a tile
func cancel_select_list():
	player.player_state = player.PLAYER_STATE.SELECTING_TILE

# called from the action script when an action specific to this scene is selected
func do_action(action):
	match (action):
		global_action_list.COMPLETE_ACTION_LIST.FOCUS:
			# focus the cursor on the next available party member
			if (player.party.yet_to_act.size() > 0):
				var party_member = player.party.yet_to_act[0]
				
				cursor.focus_on(party_member.unit_pos_x, party_member.unit_pos_y)
				
				# move this unit to the back of the 'yet to act list'
				player.party.yet_to_act.pop_front()
				player.party.yet_to_act.append(party_member)
			
			# update the player state
			player.player_state = player.PLAYER_STATE.SELECTING_TILE

# Called when the node enters the scene tree for the first time.
func _ready():
	gameInit()


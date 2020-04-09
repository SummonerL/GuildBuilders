extends Node2D

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in our game config vars
onready var game_cfg_vars = get_node("/root/Game_Config")

# bring in our global player variables
onready var player = get_node("/root/Player_Globals")

# A Test of Artistry...
# ... a game by
# Arid Bard (Elliot Simpson)

# Overworld Scene (Main)

# preload our game objects
onready var cursor_scn = preload("res://Entities/Player/Cursor.tscn")
onready var camera_scn = preload("res://Entities/Camera/Camera.tscn")
onready var hud_scn = preload("res://Entities/HUD/Dialogue.tscn")
onready var hud_tile_info_scn = preload("res://Entities/HUD/Tile_Info.tscn")
onready var hud_time_of_day_info_scn = preload("res://Entities/HUD/Time_Of_Day_Info.tscn")
onready var clock_scn = preload("res://Entities/HUD/Clock/Clock.tscn")

# game music
const MIN_VOL = -80 # used for fading in / out
const MED_VOL = -25
const DAMPENED_VOL = -15
var active_bg_music
var bg_music_vol

onready var twelve_pm_loop = get_node("12PM_Loop")

onready var five_pm_loop = get_node("5PM_Loop")

# tween for fading in / out audio
onready var tween_out = get_node("Fade_Out_Tween")
onready var tween_in = get_node("Fade_In_Tween")
export var transition_duration_out = 3.0
export var transition_duration_in = 1.5
export var transition_type = 1 # TRANS_SINE

# game instances
var cursor
var camera
var hud_tile_info
var hud_tod_info

func gameInit():
	cursor = cursor_scn.instance()
	camera = camera_scn.instance()
	player.hud = hud_scn.instance()
	hud_tile_info = hud_tile_info_scn.instance()
	hud_tod_info = hud_time_of_day_info_scn.instance()
	
	add_child(camera)
	camera.add_child(hud_tile_info) # make the hud a child of the camera
	camera.add_child(hud_tod_info)
	add_child(cursor)
	camera.add_child(player.hud)
	
	# add units to the player's party
	player.party.add_unit(constants.UNIT_TYPES.ANGLER_MALE)
	player.party.add_unit(constants.UNIT_TYPES.ANGLER_FEMALE)
	player.party.add_unit(constants.UNIT_TYPES.WOODCUTTER_MALE)
	player.party.add_unit(constants.UNIT_TYPES.WOODCUTTER_FEMALE)
	player.party.add_unit(constants.UNIT_TYPES.WOODWORKER_MALE)
	
	# mark all units as 'yet to act'
	player.party.reset_yet_to_act()
	
	# lights, camera, action!
	camera.turnOn()
	
	# start looping our background music
	five_pm_loop.play()
	active_bg_music = five_pm_loop
	
	# initialize some player variables (that haven't already been initialized')
	# get the time of day info node ()
	player.time_of_day_info_node = get_tree().get_nodes_in_group(constants.TIME_OF_DAY_INFO_GROUP)[0]

# called to show the clock animation when the time moves forward
func show_clock_anim():
	add_child(clock_scn.instance())

# determine the current background music state. Whether or not it needs to be changed, based on the current time
func determine_music_state():
	match(player.current_time_of_day):
		12:
			# time to change songs
			fade_out_background_music()
		17:
			fade_out_background_music()
		_:
			# bau - keep playing music :
			pass
	
# dampen background music
func dampen_background_music():
	active_bg_music.volume_db += DAMPENED_VOL
	
# raise background music
func heighten_background_music():
	active_bg_music.volume_db -= DAMPENED_VOL
	
# fade out the active background music
func fade_out_background_music():
	fade_out(active_bg_music)

# helper function to fade out audio streams
func fade_out(audio_stream):
	# tween music volume down to 0
	tween_out.interpolate_property(audio_stream, "volume_db", audio_stream.volume_db, MIN_VOL, transition_duration_out, transition_type, Tween.EASE_IN, 0)
	
	# when the tween ends, the music will be stopped
	tween_out.connect("tween_completed", self, "stop_audio")
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
			fade_in(active_bg_music, 4) # add a volume buffer (this song is quieter :( )
		17:
			active_bg_music = five_pm_loop
			fade_in(active_bg_music)
		_:
			# play nothing (this should never happen)
			pass

# Called when the node enters the scene tree for the first time.
func _ready():
	gameInit()

# temporarily use to text dialogue system
func _input(event):
	if (event.is_action_pressed("ui_focus_next")):
		match player.hud.dialogueState:
			player.hud.STATES.INACTIVE:
				player.hud.typeText("Well... I think we officially got the " +
							"dialogue system working to perfection. " +
							"Hopefully this will be the first step " + 
							"in creating the game of my dreams. " + 
							"As a matter of fact, I think I'll write " + 
							"a novel in here... JK!")


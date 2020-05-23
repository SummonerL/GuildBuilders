extends Node2D

# autoloaded script for commonly referenced variables

# our players party of units
onready var party = get_node("/root/Player_Party")

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

enum PLAYER_STATE {
	SELECTING_TILE,
	SELECTING_ACTION,
	SELECTING_MOVEMENT,
	POSITIONING_UNIT,
	CROSSING_WATER,
	ANIMATING_MOVEMENT,
	BETWEEN_TURNS,
	VIEWING_DIALOGUE,
	BETWEEN_DAYS,
	COMPLETING_QUEST,
	SELECTING_TRADE_UNIT,
}

var player_state = PLAYER_STATE.BETWEEN_DAYS

# camera position on world map
var cam_pos_x = 10
var cam_pos_y = 12

# cursor position on the map
var curs_pos_x = 14
var curs_pos_y = 16

# keep track of the dialogue box
var hud

# holds the day / time information (HUD)
var time_of_day_info_node

# keep track of the current time of day
var current_time_of_day = 10

# keep track of which day the unit is on
var current_day = 1

# location of the guild hall
var guild_hall_x = 13
var guild_hall_y = 14

# a useful tracker for what object the player is currently interacting with
var active_world_object

# function for moving the game clock forward (one turn)
func move_to_next_hour():
	current_time_of_day += 1
	if (current_time_of_day > (constants.TIMES_OF_DAY.size() - 1)):
		current_time_of_day = 0
		
	# show the clock sprite
	get_tree().get_current_scene().show_clock_anim()
	
	# make necessary changes to the background music
	get_tree().get_current_scene().determine_music_state()

# function used to determine the next player state, based on several conditions
func determine_next_state():
	match (player_state):
		PLAYER_STATE.BETWEEN_TURNS:
			if (time_of_day_info_node != null):
				time_of_day_info_node.update_time_of_day_info_text()
			
			# set the state back to 'selecting tile'
			enable_state(PLAYER_STATE.SELECTING_TILE)
			
			get_tree().get_current_scene().wake_up_units()
		_:		
			# if all the unit's have acted
			if (party.yet_to_act.size() == 0):
				enable_state(PLAYER_STATE.BETWEEN_TURNS)
				
				# let's move the game clock forward an hour
				move_to_next_hour()
				party.reset_yet_to_act()
				party.reset_unit_actions()
			else:
				enable_state(PLAYER_STATE.SELECTING_TILE)

func enable_state(state):
	player_state = state

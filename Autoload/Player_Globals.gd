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
	ANIMATING_MOVEMENT
}

var player_state = PLAYER_STATE.SELECTING_TILE

# camera position on world map
var cam_pos_x = 0
var cam_pos_y = 0

# cursor position on the map
var curs_pos_x = 4
var curs_pos_y = 4

# keep track of the dialogue box
var hud

# keep track of the current time of day
var current_time_of_day = 23

# function for moving the game clock forward (one turn)
func move_to_next_hour():
	current_time_of_day += 1
	if (current_time_of_day > (constants.TIMES_OF_DAY.size() - 1)):
		current_time_of_day = 0
		
	# show the clock sprite
	get_tree().get_current_scene().show_clock_anim()

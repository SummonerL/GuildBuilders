extends Node2D

# autoloaded script for commonly referenced variables

# our players party of units
onready var party = get_node("/root/Player_Party")

enum PLAYER_STATE {
	SELECTING_TILE
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

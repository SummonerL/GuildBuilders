extends Node2D

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in our player globals
onready var player_globals = get_node("/root/Player_Globals")

func turnOn():
	get_node("Camera_Node").current = true
	pass
	
func camera_init():
	# position camera
	self.global_position = Vector2(player_globals.cam_pos_x*16, player_globals.cam_pos_y*16)
	pass
	
func set_camera_pos(new_pos_x, new_pos_y):
	player_globals.cam_pos_x = new_pos_x
	player_globals.cam_pos_y = new_pos_y
	
	self.global_position = Vector2(player_globals.cam_pos_x*constants.TILE_WIDTH, player_globals.cam_pos_y*constants.TILE_HEIGHT)

func check_pos(curs_x, curs_y):
	# if cursor is offscreen, move the cam!
	if curs_x < player_globals.cam_pos_x:
		set_camera_pos(curs_x, player_globals.cam_pos_y)
	if curs_x > (player_globals.cam_pos_x + (constants.TILES_PER_ROW-1)):
		set_camera_pos(player_globals.cam_pos_x+1, player_globals.cam_pos_y)
	if curs_y < player_globals.cam_pos_y:
		set_camera_pos(player_globals.cam_pos_x, curs_y)
	if curs_y > (player_globals.cam_pos_y + (constants.TILES_PER_COL-1)):
		set_camera_pos(player_globals.cam_pos_x, player_globals.cam_pos_y+1)
		
# Called when the node enters the scene tree for the first time.
func _ready():
	camera_init()
	pass # Replace with function body.


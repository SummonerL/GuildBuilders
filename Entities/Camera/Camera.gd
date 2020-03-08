extends Node2D

const TILE_HEIGHT = 16
const TILE_WIDTH = 16
const TILES_PER_ROW = 10
const TILES_PER_COL = 9

# camera pos on world map
var pos_x = 0
var pos_y = 0

func turnOn():
	get_node("Camera_Node").current = true
	pass
	
func camera_init():
	# position camera
	self.global_position = Vector2(pos_x*16, pos_y*16)
	pass
	
func set_camera_pos(new_pos_x, new_pos_y):
	pos_x = new_pos_x
	pos_y = new_pos_y
	
	self.global_position = Vector2(pos_x*TILE_WIDTH, pos_y*TILE_HEIGHT)

func check_pos(curs_x, curs_y):
	# if cursor is offscreen, move the cam!
	print(curs_x)
	print(pos_x)
	if curs_x < pos_x:
		set_camera_pos(curs_x, pos_y)
	if curs_x > (pos_x + (TILES_PER_ROW-1)):
		set_camera_pos(pos_x+1, pos_y)
	if curs_y < pos_y:
		set_camera_pos(pos_x, curs_y)
	if curs_y > (pos_y + (TILES_PER_COL-1)):
		set_camera_pos(pos_x, pos_y+1)
		
# Called when the node enters the scene tree for the first time.
func _ready():
	camera_init()
	pass # Replace with function body.


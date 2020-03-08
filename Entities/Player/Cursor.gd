extends Node2D

const TILE_HEIGHT = 16
const TILE_WIDTH = 16

# position on world map
var pos_x = 4
var pos_y = 4

# child nodes
onready var move_sound = get_node("Cursor_Move_Sound")

# instanced nodes
onready var camera = get_tree().get_nodes_in_group("Camera")[0]

func cursor_init():
	# position cursor
	self.global_position = Vector2(pos_x*16, pos_y*16)
	
func set_cursor_pos(new_pos_x, new_pos_y):
	pos_x = new_pos_x
	pos_y = new_pos_y
	
	self.global_position = Vector2(pos_x*TILE_WIDTH, pos_y*TILE_HEIGHT)

	# update the camera, if necessary
	camera.check_pos(pos_x, pos_y)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	cursor_init()
	pass # Replace with function body.

func _input(event):
	var cursor_move = false
	
	if event.is_action_pressed("ui_left"):
		set_cursor_pos(pos_x-1, pos_y)
		cursor_move = true
	if event.is_action_pressed("ui_right"):
		set_cursor_pos(pos_x+1, pos_y)
		cursor_move = true
	if event.is_action_pressed("ui_up"):
		set_cursor_pos(pos_x, pos_y-1)
		cursor_move = true
	if event.is_action_pressed("ui_down"):
		set_cursor_pos(pos_x, pos_y+1)
		cursor_move = true
		
	if cursor_move:
		# play cursor move sound
		move_sound.play()
		
		# update camera pos
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass

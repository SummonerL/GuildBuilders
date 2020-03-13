extends Node2D

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# local variables 
# -----------------------
# position on world map
var pos_x = 4
var pos_y = 4

# whether or not the cursor is moving
var cursor_moving = false

# current wait time (for moving)
# should speed up while the key is held
const MAX_WAIT_TIME = .3
const MIN_WAIT_TIME = .1
const WAIT_TIME_INTERVAL = .1

var cursor_wait_time = MAX_WAIT_TIME
var cursor_timer 

# current cursor direction
onready var cursor_direction = constants.DIRECTIONS.UP

# child nodes
onready var move_sound = get_node("Cursor_Move_Sound")

# instanced nodes
onready var camera = get_tree().get_nodes_in_group("Camera")[0]

func cursor_init():
	# position cursor
	self.global_position = Vector2(pos_x*16, pos_y*16)
	
	# create a timer for tracking cursor movement
	cursor_timer = Timer.new()
	cursor_timer.connect("timeout", self, "cursor_move")
	cursor_timer.connect("timeout", self, "stop_timer")
	add_child(cursor_timer)
	
func stop_timer():
	cursor_timer.stop()
	
func cursor_move():
	if (cursor_direction == constants.DIRECTIONS.UP):
		set_cursor_pos(pos_x, pos_y-1)
	elif (cursor_direction == constants.DIRECTIONS.RIGHT):
		set_cursor_pos(pos_x+1, pos_y)
	elif (cursor_direction == constants.DIRECTIONS.DOWN):
		set_cursor_pos(pos_x, pos_y+1)
	elif (cursor_direction == constants.DIRECTIONS.LEFT):
		set_cursor_pos(pos_x-1, pos_y)
		
	# play the cursor moving sound
	move_sound.play()
		
func cursor_reset():
	stop_timer()
	cursor_moving = false
	
	# reset wait time
	cursor_wait_time = MAX_WAIT_TIME

func set_cursor_pos(new_pos_x, new_pos_y):
	pos_x = new_pos_x
	pos_y = new_pos_y
	
	self.global_position = Vector2(pos_x*constants.TILE_WIDTH, pos_y*constants.TILE_HEIGHT)

	# update the camera, if necessary
	camera.check_pos(pos_x, pos_y)
	
# called when the node enters the scene tree for the first time.
func _ready():
	cursor_init()

func _input(event):
	
	# if any of the directional keys are released, reset the cursor speed/timer
	if ( (event.is_action_released("ui_up") && cursor_direction ==  constants.DIRECTIONS.UP) ||
		(event.is_action_released("ui_right") && cursor_direction ==  constants.DIRECTIONS.RIGHT) ||
		(event.is_action_released("ui_down") && cursor_direction ==  constants.DIRECTIONS.DOWN) ||
		(event.is_action_released("ui_left") && cursor_direction ==  constants.DIRECTIONS.LEFT) ):
		cursor_reset()

	# immediately move, then continue moving
	if event.is_action_pressed("ui_up"):
		# if we're changing directions, act as if we're resetting
		if (cursor_direction != constants.DIRECTIONS.UP):
			cursor_reset()
		cursor_direction = constants.DIRECTIONS.UP
		cursor_move()
		cursor_moving = true
		
	if event.is_action_pressed("ui_right"):
		# if we're changing directions, act as if we're resetting
		if (cursor_direction != constants.DIRECTIONS.RIGHT):
			cursor_reset()
		cursor_direction = constants.DIRECTIONS.RIGHT
		cursor_move()
		cursor_moving = true
		
	if event.is_action_pressed("ui_down"):
		# if we're changing directions, act as if we're resetting
		if (cursor_direction != constants.DIRECTIONS.DOWN):
			cursor_reset()
		cursor_direction = constants.DIRECTIONS.DOWN
		cursor_move()
		cursor_moving = true
		
	if event.is_action_pressed("ui_left"):
		# if we're changing directions, act as if we're resetting
		if (cursor_direction != constants.DIRECTIONS.LEFT):
			cursor_reset()
		cursor_direction = constants.DIRECTIONS.LEFT
		cursor_move()
		cursor_moving = true
		
# runs every frame
func _process(_delta):
	# check to see if we're still moving 
	if (cursor_moving):
		if (cursor_timer.time_left == 0):
			cursor_timer.start(cursor_wait_time)
			# bump down the wait time, unless we're at minimum (speed up)
			# dev note - still trying to determine if the interval is necessary
			# or just going with 2 speeds (slow, then fast)
			if (cursor_wait_time > MIN_WAIT_TIME):
				# cursor_wait_time -= WAIT_TIME_INTERVAL
				cursor_wait_time = MIN_WAIT_TIME
			

extends Node2D

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in the player's units
onready var party = get_node("/root/Player_Party")

# bring in the global player variables
onready var player = get_node("/root/Player_Globals")

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
	
	
func get_selected_tile_units():
	# find if there are any active units on the current tile
	for unit in party.get_all_units():
		if (unit.unit_pos_x == pos_x && unit.unit_pos_y == pos_y):
			return unit

func select_tile():
	# get any units on this tile
	var unit = get_selected_tile_units()
	if (unit != null):
		# activate the unit
		party.set_active_unit(unit)
		
		# enable the unit's movement state
		unit.enable_movement_state()

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
		
	# if the action button is pressed, we can select the tile/unit
	if event.is_action_pressed("ui_focus_next"):
		# regardless of the current state, if there are any units here, we need
		# to activate them. This allows the user to select a unit to move,
		# even while they are still selecting movement for another unit
		if (get_selected_tile_units() != null):
			# as long as another unit is not actively moving
			if (player.player_state != player.PLAYER_STATE.ANIMATING_MOVEMENT):
				select_tile()
		else:	
			match player.player_state:
				player.PLAYER_STATE.SELECTING_TILE:
					select_tile()
				player.PLAYER_STATE.SELECTING_MOVEMENT:
					if (party.get_active_unit() != null):
						party.get_active_unit().move_unit_if_eligible(pos_x, pos_y)

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
			

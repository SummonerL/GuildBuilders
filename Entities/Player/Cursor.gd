extends Node2D

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in the player's units
onready var party = get_node("/root/Player_Party")

# bring in the global player variables
onready var player = get_node("/root/Player_Globals")

# bring in our guild variables/functions
onready var guild = get_node("/root/Guild")

# bring in our global action list
onready var global_action_list = get_node("/root/Actions")

# bring in our abilities
onready var global_ability_list = get_node("/root/Abilities")

# bring in our items
onready var global_items_list = get_node("/root/Items")

# get our main overworld scene
onready var overworld_scene = get_parent()

# holds the tile information node (HUD)
var tile_info_node

# holds the day / time information (HUD)
var time_of_day_info_node

# the cursor position is stored in the player globals

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

# have 2 layers of potential tiles
onready var tileset_props_l1 = get_tree().get_nodes_in_group(constants.MAP_TILES_GROUP)[0]
onready var tileset_props_l2 = get_tree().get_nodes_in_group(constants.MAP_TILES_GROUP)[1]
onready var hidden_tiles = get_tree().get_nodes_in_group(constants.HIDDEN_TILES_GROUP)[0]

func cursor_init():
	# position cursor
	self.global_position = Vector2(player.curs_pos_x*16, player.curs_pos_y*16)
	
	# create a timer for tracking cursor movement
	cursor_timer = Timer.new()
	cursor_timer.connect("timeout", self, "cursor_move")
	cursor_timer.connect("timeout", self, "stop_timer")
	add_child(cursor_timer)

	tile_info_node = get_tree().get_nodes_in_group(constants.TILE_INFO_GROUP)[0]
	time_of_day_info_node = get_tree().get_nodes_in_group(constants.TIME_OF_DAY_INFO_GROUP)[0]
	
# useful function for focusing on specific coordinates
func focus_on(x, y, reprint_info = true):
	set_cursor_pos(x, y)
	
	# update the camera accordingly (top left, centering the cursor in the middle)
	camera.set_camera_pos(x - 4, y - 4)
	
	# check if we need to move the info tiles (hud)
	tile_info_node.check_if_move_needed(player.curs_pos_x - player.cam_pos_x)
	time_of_day_info_node.check_if_move_needed(player.curs_pos_x - player.cam_pos_x, player.curs_pos_y - player.cam_pos_y)
	
	# print the info tiles
	if (reprint_info):
		tile_info_node.update_tile_info_text()
		time_of_day_info_node.update_time_of_day_info_text()
	
func get_selected_tile_units():
	# find if there are any active units on the current tile
	for unit in party.get_all_units(): # (includes animals as well)
		if (unit.unit_pos_x == player.curs_pos_x && unit.unit_pos_y == player.curs_pos_y && unit.unit_awake):
			return unit
			
func get_selected_tile_units_asleep():
	# find if there are any units asleep on the current tile
	for unit in party.get_all_units():
		if (unit.unit_pos_x == player.curs_pos_x && unit.unit_pos_y == player.curs_pos_y && !unit.unit_awake):
			return unit

func select_tile():
	# get any units on this tile
	var unit = get_selected_tile_units()
	if (unit != null && player.player_state != player.PLAYER_STATE.SELECTING_ACTION):
		# update the player state
		player.player_state = player.PLAYER_STATE.SELECTING_ACTION
		cursor_reset()
			
		# activate the unit
		party.set_active_unit(unit)
		
		# determine and set the action list based on the unit's current position
		unit.determine_action_list()
		
		# show the unit's action list
		unit.show_action_list()
		
	# otherwise, as long as we're in the correct state, show the turn select screen
	if (player.player_state == player.PLAYER_STATE.SELECTING_TILE):
		# update the player state
		player.player_state = player.PLAYER_STATE.SELECTING_ACTION
		cursor_reset()
		overworld_scene.show_turn_action_list()

func stop_timer():
	cursor_timer.stop()
	
func cursor_move():
	if (cursor_direction == constants.DIRECTIONS.UP):
		if (player.curs_pos_y > constants.NORTH_BOUNDARY):
			set_cursor_pos(player.curs_pos_x, player.curs_pos_y-1)
	elif (cursor_direction == constants.DIRECTIONS.RIGHT):
		if (player.curs_pos_x < constants.EAST_BOUNDARY):
			set_cursor_pos(player.curs_pos_x+1, player.curs_pos_y)
	elif (cursor_direction == constants.DIRECTIONS.DOWN):
		if (player.curs_pos_y < constants.SOUTH_BOUNDARY):
			set_cursor_pos(player.curs_pos_x, player.curs_pos_y+1)
	elif (cursor_direction == constants.DIRECTIONS.LEFT):
		if (player.curs_pos_x > constants.WEST_BOUNDARY):
			set_cursor_pos(player.curs_pos_x-1, player.curs_pos_y)
		
	# play the cursor moving sound
	move_sound.play()
	
	# check if we need to move the info tiles (hud)
	tile_info_node.check_if_move_needed(player.curs_pos_x - player.cam_pos_x)
	time_of_day_info_node.check_if_move_needed(player.curs_pos_x - player.cam_pos_x, player.curs_pos_y - player.cam_pos_y)
	
	# print the info tiles
	tile_info_node.update_tile_info_text()
	time_of_day_info_node.update_time_of_day_info_text()
		
func cursor_reset():
	stop_timer()
	cursor_moving = false
	
	# reset wait time
	cursor_wait_time = MAX_WAIT_TIME

func set_cursor_pos(new_pos_x, new_pos_y):
	player.curs_pos_x = new_pos_x
	player.curs_pos_y = new_pos_y
	
	self.global_position = Vector2(player.curs_pos_x*constants.TILE_WIDTH, player.curs_pos_y*constants.TILE_HEIGHT)

	# update the camera, if necessary
	camera.check_pos(player.curs_pos_x, player.curs_pos_y)
	
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
		
	if (player.player_state == player.PLAYER_STATE.SELECTING_MOVEMENT ||
	player.player_state == player.PLAYER_STATE.SELECTING_TILE ||
	player.player_state == player.PLAYER_STATE.POSITIONING_UNIT ||
	player.player_state == player.PLAYER_STATE.CROSSING_WATER ||
	player.player_state == player.PLAYER_STATE.SELECTING_TRADE_UNIT ||
	player.player_state == player.PLAYER_STATE.SELECTING_MOUNT_UNIT ||
	player.player_state == player.PLAYER_STATE.SELECTING_DISMOUNT_SQUARE):
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
	if event.is_action_pressed("ui_accept"):
		# if another unit is selecting movement, let's allow another unit to be selected still, allowing them to 'interrupt' and take their action
		if (player.player_state == player.PLAYER_STATE.SELECTING_TILE || 
		player.player_state == player.PLAYER_STATE.SELECTING_MOVEMENT ||
		player.player_state == player.PLAYER_STATE.POSITIONING_UNIT ||
		player.player_state == player.PLAYER_STATE.CROSSING_WATER):
			if (get_selected_tile_units() != null):
				# as long as another unit is not actively moving
				if (player.player_state != player.PLAYER_STATE.ANIMATING_MOVEMENT):
					
					# clear the movement grid of the active unit
					var active_unit = party.get_active_unit()
					if (active_unit):
						active_unit.clear_movement_grid_squares()
					
					select_tile()
			else:	
				match player.player_state:
					player.PLAYER_STATE.SELECTING_TILE:
						select_tile()
					player.PLAYER_STATE.SELECTING_MOVEMENT:
						# don't move on top of camping units
						if (party.get_active_unit() != null && get_selected_tile_units_asleep() == null):
							party.get_active_unit().move_unit_if_eligible(player.curs_pos_x, player.curs_pos_y)
					player.PLAYER_STATE.POSITIONING_UNIT:
						# teleport the unit to this position
						party.get_active_unit().position_unit_if_eligible(player.curs_pos_x, player.curs_pos_y)
					player.PLAYER_STATE.CROSSING_WATER:
						# teleport the unit to this position (and spend an action)
						if (!global_ability_list.unit_has_ability(party.get_active_unit(), global_ability_list.ABILITY_RIVER_QUEEN_NAME)):
							party.get_active_unit().item_in_use = global_items_list.item_wooden_stilts
						party.get_active_unit().position_unit_if_eligible(player.curs_pos_x, player.curs_pos_y, true)
		else:
				match player.player_state:
					player.PLAYER_STATE.SELECTING_TRADE_UNIT:
						# trade with the target unit
						if (player.party.is_unit_here(player.curs_pos_x, player.curs_pos_y)):
							party.get_active_unit().trade_with_unit_at_pos(player.curs_pos_x, player.curs_pos_y)
					player.PLAYER_STATE.SELECTING_MOUNT_UNIT:
						# mount the target unit
						if (player.party.is_unit_here(player.curs_pos_x, player.curs_pos_y)):
							var target_unit = player.party.get_unit_at_coordinates(player.curs_pos_x, player.curs_pos_y)
							if (target_unit.get('can_mount') == true):
								party.get_active_unit().mount_target_unit(target_unit)
					player.PLAYER_STATE.SELECTING_DISMOUNT_SQUARE:
						# dismount!
						
						var cardinal_tiles = get_tree().get_current_scene().get_cardinal_tiles(party.get_active_unit())
						
						# make sure the tile is in the cardinal tile
						var cardinal = false
						for tile in cardinal_tiles:
							if (tile.tile == Vector2(player.curs_pos_x, player.curs_pos_y)):
								cardinal = true
						
						if (cardinal):
							var tile_name_l1 = tileset_props_l1.get_tile_at_coordinates(Vector2(player.curs_pos_x, player.curs_pos_y))
							var tile_name_l2 = tileset_props_l2.get_tile_at_coordinates(Vector2(player.curs_pos_x, player.curs_pos_y))
							var l1_cost = tileset_props_l1.get_movement_cost(tile_name_l1)
							
							var l2_cost = 0
							if (tile_name_l2 != null):
								l2_cost += tileset_props_l2.get_movement_cost(tile_name_l2)
							
							# if the tile is hidden, it's not accessible
							var hidden_tile = (hidden_tiles.get_tile_at_coordinates(Vector2(player.curs_pos_x, player.curs_pos_y)) != null)
							if (hidden_tile):
								l1_cost += constants.CANT_MOVE
								
							if (l1_cost + l2_cost < constants.CANT_MOVE):
								# dismount here!						
								party.get_active_unit().commence_dismount(Vector2(player.curs_pos_x, player.curs_pos_y), 0)
								
								# and finish the animal's action
								party.get_active_unit().end_action(true)
					
						
							
	if event.is_action_pressed("ui_select"):
		# quick shortcut for the 'focus' option
		if (player.player_state == player.PLAYER_STATE.SELECTING_TILE):
			global_action_list.do_action(global_action_list.COMPLETE_ACTION_LIST.FOCUS, overworld_scene)
			
	if event.is_action_pressed("ui_cancel"):
		# allow the unit to cancel out of selecting movement
		if (player.player_state == player.PLAYER_STATE.SELECTING_MOVEMENT || 
		player.player_state == player.PLAYER_STATE.POSITIONING_UNIT ||
		player.player_state == player.PLAYER_STATE.CROSSING_WATER ||
		player.player_state == player.PLAYER_STATE.SELECTING_TRADE_UNIT ||
		player.player_state == player.PLAYER_STATE.SELECTING_MOUNT_UNIT ||
		player.player_state == player.PLAYER_STATE.SELECTING_DISMOUNT_SQUARE):		
			party.get_active_unit().clear_movement_grid_squares()
			# change our state back to selecting tile
			player.player_state = player.PLAYER_STATE.SELECTING_TILE

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
			

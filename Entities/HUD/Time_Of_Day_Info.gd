extends CanvasLayer

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in the global player variables
onready var player = get_node("/root/Player_Globals")

const TIME_OF_DAY_INFO_WIDTH = 4
const TIME_OF_DAY_INFO_HEIGHT = 2

# our actual time of day info sprite
onready var time_of_day_info_sprite = get_node("Time_Of_Day_Sprite")

# the letters and symbol scene
onready var letters_symbols_obj = preload("res://Entities/HUD/Letters_Symbols/Letters_Symbols.tscn")

var side
var left_x
var right_x
var top_y
var bottom_y
var current_top_bottom
var current_left_right

var letters_symbols

var print_start_x
var print_start_y

func hide():
	time_of_day_info_sprite.visible = false

func show():
	time_of_day_info_sprite.visible = true

func time_of_day_info_init():
	top_y = 0
	bottom_y = (constants.TILES_PER_COL - TIME_OF_DAY_INFO_HEIGHT) * constants.TILE_HEIGHT
	
	left_x = (constants.TILES_PER_ROW - TIME_OF_DAY_INFO_WIDTH) * constants.TILE_WIDTH
	right_x = 0
	
	# set the starting position of the TOD info hud
	change_sides(constants.SIDES.LEFT, false)
	change_top_bottom(constants.TOP_BOTTOM.TOP, false)
	
	reposition_sprite()
	
	# create a letters_symbols instance
	letters_symbols = letters_symbols_obj.instance()
	
	add_child(letters_symbols)

func check_if_move_needed(curs_x, curs_y):
	if (curs_x <= ((constants.TILES_PER_ROW / 2) - 1) && side == constants.SIDES.LEFT):
		change_sides(constants.SIDES.RIGHT)
		
	if (curs_x > ((constants.TILES_PER_ROW / 2) - 1) && side == constants.SIDES.RIGHT):
		change_sides(constants.SIDES.LEFT)
		
	if (curs_y <= ((constants.TILES_PER_COL / 2)) && current_top_bottom == top_y):
		change_top_bottom(constants.TOP_BOTTOM.BOTTOM)
		
	if (curs_y > ((constants.TILES_PER_COL / 2)) && current_top_bottom == bottom_y):
		change_top_bottom(constants.TOP_BOTTOM.TOP)

func clear_time_of_day_info_text():
	letters_symbols.clear_text_non_dialogue()

func update_time_of_day_info_text():
	clear_time_of_day_info_text()
	
	# update the start pos based on the position of the TOD info tile
	
	print_start_x = 6
	print_start_y = 1
	
	if (side == constants.SIDES.LEFT):
		print_start_x += constants.DIA_TILES_PER_ROW - (TIME_OF_DAY_INFO_WIDTH * 2)
	
	
	if (current_top_bottom == bottom_y):
		print_start_y += constants.DIA_TILES_PER_COL - (TIME_OF_DAY_INFO_HEIGHT * 2)
		
	letters_symbols.print_immediately(constants.TIMES_OF_DAY[player.current_time_of_day], 
		Vector2(print_start_x - len(constants.TIMES_OF_DAY[player.current_time_of_day]), print_start_y))
	

func change_sides(target_side, reposition = true):
	match target_side:
		constants.SIDES.LEFT:
			# position the tod info hud to the left
			side = constants.SIDES.LEFT
			current_left_right = left_x
			
		constants.SIDES.RIGHT:
			# position the tod info hud to the right
			side = constants.SIDES.RIGHT
			current_left_right = right_x
	
	if (reposition):
		reposition_sprite()

func change_top_bottom(target_top_bottom, reposition = true):
	match target_top_bottom:
		constants.TOP_BOTTOM.TOP:
			# position the tod info hud to the top
			current_top_bottom = top_y
		constants.TOP_BOTTOM.BOTTOM:
			# position the tod info hud to the bottom
			current_top_bottom = bottom_y
			
	if (reposition):
		reposition_sprite()
	
func reposition_sprite():
	time_of_day_info_sprite.position = Vector2(current_left_right, current_top_bottom)

func _ready():
	time_of_day_info_init()

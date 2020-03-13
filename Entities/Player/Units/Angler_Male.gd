extends "res://Entities/Player/Units/Unit_Class.gd"

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in our global player variables
onready var player = get_node("/root/Player_Globals")

func unit_init():
	unit_pos_x = 5
	unit_pos_y = 5
	
	base_move = 2
	
	self.global_position = Vector2(unit_pos_x*constants.TILE_WIDTH, 
									unit_pos_y*constants.TILE_HEIGHT)
									
	show_movement_grid_square(unit_pos_x+1, unit_pos_y)
	show_movement_grid_square(unit_pos_x+1, unit_pos_y+1)
	show_movement_grid_square(unit_pos_x, unit_pos_y+1)
	show_movement_grid_square(unit_pos_x-1, unit_pos_y+1)
	show_movement_grid_square(unit_pos_x-1, unit_pos_y)
	show_movement_grid_square(unit_pos_x-1, unit_pos_y-1)
	show_movement_grid_square(unit_pos_x, unit_pos_y-1)
	show_movement_grid_square(unit_pos_x+1, unit_pos_y-1)

func _ready():
	unit_init()

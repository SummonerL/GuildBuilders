extends "res://Entities/Player/Units/Unit_Class.gd"

func unit_init():
	unit_pos_x = 19
	unit_pos_y = 4
	
	unit_name = "Female Angler"
	
	base_move = 7
	
	self.global_position = Vector2(unit_pos_x*constants.TILE_WIDTH, 
									unit_pos_y*constants.TILE_HEIGHT)

func _ready():
	unit_init()

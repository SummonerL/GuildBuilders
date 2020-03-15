extends "res://Entities/Player/Units/Unit_Class.gd"

func unit_init():
	unit_pos_x = 10
	unit_pos_y = 7
	
	base_move = 3
	
	self.global_position = Vector2(unit_pos_x*constants.TILE_WIDTH, 
									unit_pos_y*constants.TILE_HEIGHT)

func _ready():
	unit_init()

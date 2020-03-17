extends "res://Entities/Player/Units/Unit_Class.gd"

func get_unit_move_sound():
	return unit_move_sound
	
func unit_init():
	unit_pos_x = 19
	unit_pos_y = 4
	unit_name = "Female Angler"
	
	base_move = 6
	
	self.global_position = Vector2(unit_pos_x*constants.TILE_WIDTH, 
									unit_pos_y*constants.TILE_HEIGHT)

func _ready():
	unit_base_init()
	unit_init()
	

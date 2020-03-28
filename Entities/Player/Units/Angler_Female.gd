extends "res://Entities/Player/Units/Unit_Class.gd"

onready var ps = preload("res://Sprites/characters/angler_female_portrait1.png")

func get_unit_move_sound():
	return unit_move_sound
	
func unit_init():
	unit_pos_x = 19
	unit_pos_y = 4
	unit_name = "Coral"
	age = 17
	unit_class = "Angler"
	
	unit_portrait_sprite = ps
	
	base_move = 6
	
	skill_levels[constants.FISHING] = 5
	
	self.global_position = Vector2(unit_pos_x*constants.TILE_WIDTH, 
									unit_pos_y*constants.TILE_HEIGHT)

func _ready():
	unit_base_init()
	unit_init()
	

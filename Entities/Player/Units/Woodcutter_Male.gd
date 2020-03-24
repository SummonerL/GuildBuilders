extends "res://Entities/Player/Units/Unit_Class.gd"

onready var ps = preload("res://Sprites/characters/woodcutter_male_portrait1.png")

func unit_init():
	unit_pos_x = 9
	unit_pos_y = 7
	
	unit_portrait_sprite = ps
	
	unit_name = "Axel"
	unit_class = "Woodcutter"
	
	base_move = 3
	
	self.global_position = Vector2(unit_pos_x*constants.TILE_WIDTH, 
									unit_pos_y*constants.TILE_HEIGHT)
	
func _ready():
	unit_base_init()
	unit_init()

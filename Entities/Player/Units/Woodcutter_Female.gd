extends "res://Entities/Player/Units/Unit_Class.gd"

onready var ps = preload("res://Sprites/characters/woodcutter_female_portrait.png")

func unit_init():
	unit_pos_x = 7
	unit_pos_y = 7
	
	unit_portrait_sprite = ps
	
	unit_name = "Willow"
	
	base_move = 4
	
	self.global_position = Vector2(unit_pos_x*constants.TILE_WIDTH, 
									unit_pos_y*constants.TILE_HEIGHT)
	
func _ready():
	unit_base_init()
	unit_init()

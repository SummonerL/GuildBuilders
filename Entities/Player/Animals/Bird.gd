extends "res://Entities/Player/Animals/Animal_Class.gd"

func animal_init():
	type = constants.ANIMAL_TYPES.BIRD
	
	animal_sprite = get_node("Bird_Sprite")

func _ready():
	animal_base_init()
	animal_init()

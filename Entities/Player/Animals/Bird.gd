extends "res://Entities/Player/Animals/Animal_Class.gd"

func animal_init():
	type = constants.ANIMAL_TYPES.BIRD
	
	animal_sprite = get_node("Bird_Sprite")
	
	# dove's have a base move of 7
	base_move = 7
	
	unit_name = "Dove"
	
	# dove's can carry 3 items
	item_limit = 3
	
	# dove's fly!
	flying = true

func _ready():
	animal_base_init()
	animal_init()

extends "res://Entities/Player/Animals/Animal_Class.gd"

const BED_TIME_TEXT = 'Dove flew away...'

func animal_init():
	type = constants.ANIMAL_TYPES.BIRD
	
	animal_sprite = get_node("Bird_Sprite")
	
	# xp gained when the unit tames this animal
	tame_xp = 4
	
	# dove's have a base move of 7
	base_move = 7
	
	unit_name = "Dove"
	
	# dove's can carry 3 items
	item_limit = 3
	
	# dove's fly!
	flying = true
	
	# the dove will fly away at the end of day
	escapes = true

func _ready():
	animal_base_init()
	animal_init()

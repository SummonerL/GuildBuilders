extends "res://Entities/Player/Animals/Animal_Class.gd"

const BED_TIME_TEXT = 'Horse returned home...'

func animal_init():
	type = constants.ANIMAL_TYPES.HORSE
	
	animal_sprite = get_node("Horse")
	
	mounted_indicator_sprite = get_node("Mounted_Indicator")
	
	# xp gained when the unit tames this animal
	tame_xp = 6
	
	# horses have a base move of 8
	base_move = 8
	
	unit_name = "Horse"
	
	# units can mount horses :)
	can_mount = true
	
	# horses can carry 3 items
	item_limit = 3
	
	# the horse will go home
	escapes = true
	

func _ready():
	animal_base_init()
	animal_init()

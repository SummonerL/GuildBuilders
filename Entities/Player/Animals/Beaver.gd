extends "res://Entities/Player/Animals/Animal_Class.gd"

const BED_TIME_TEXT = 'Beaver swam home...'

func animal_init():
	type = constants.ANIMAL_TYPES.BEAVER
	
	animal_sprite = get_node("Beaver")
	
	# xp gained when the unit tames this animal
	tame_xp = 6
	
	# beaver's have a base move of 12
	base_move = 12
	
	unit_name = "Beaver"
	
	# beaver's can carry 3 items
	item_limit = 3
	
	# the beaver will go home
	escapes = true
	
	# beavers swim!
	swims_only = true
	
	

func _ready():
	animal_base_init()
	animal_init()

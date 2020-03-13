extends Node

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# all of the unit types
onready var angler_male_scn = preload("res://Entities/Player/Units/Angler_Male.tscn")
onready var angler_female_scn = preload("res://Entities/Player/Units/Angler_Female.tscn")

func add_unit(unit):
	match unit:
		constants.UNIT_TYPES.ANGLER_MALE:
			add_child(angler_male_scn.instance())
		constants.UNIT_TYPES.ANGLER_FEMALE:
			add_child(angler_female_scn.instance())

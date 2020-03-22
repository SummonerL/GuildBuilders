extends Node

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# all of the unit types
onready var angler_male_scn = preload("res://Entities/Player/Units/Angler_Male.tscn")
onready var angler_female_scn = preload("res://Entities/Player/Units/Angler_Female.tscn")
onready var woodcutter_male_scn = preload("res://Entities/Player/Units/Woodcutter_Male.tscn")
onready var woodcutter_female_scn = preload("res://Entities/Player/Units/Woodcutter_Female.tscn")

# keep track of all the nodes in our party
var party_members = []

# keep track of the unit that is currently 'active'
var active_unit = null

func get_all_units():
	return get_children()

func get_active_unit():
	return active_unit
	
func set_active_unit(unit):
	active_unit = unit

func add_unit(unit):
	match unit:
		constants.UNIT_TYPES.ANGLER_MALE:
			var angler_male_node = angler_male_scn.instance()
			add_child(angler_male_node)
			party_members.append(angler_male_node)
		constants.UNIT_TYPES.ANGLER_FEMALE:
			var angler_female_node = angler_female_scn.instance()
			add_child(angler_female_node)
			party_members.append(angler_female_node)
		constants.UNIT_TYPES.WOODCUTTER_MALE:
			var woodcutter_male_node = woodcutter_male_scn.instance()
			add_child(woodcutter_male_node)
			party_members.append(woodcutter_male_node)
		constants.UNIT_TYPES.WOODCUTTER_FEMALE:
			var woodcutter_female_node = woodcutter_female_scn.instance()
			add_child(woodcutter_female_node)
			party_members.append(woodcutter_female_node)

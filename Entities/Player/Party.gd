extends Node

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# keep track of the global player variables
onready var player = get_node("/root/Player_Globals")

# all of the unit types
onready var angler_male_scn = preload("res://Entities/Player/Units/Angler_Male.tscn")
onready var angler_female_scn = preload("res://Entities/Player/Units/Angler_Female.tscn")
onready var woodcutter_male_scn = preload("res://Entities/Player/Units/Woodcutter_Male.tscn")
onready var woodcutter_female_scn = preload("res://Entities/Player/Units/Woodcutter_Female.tscn")

# keep track of all the nodes in our party
var party_members = []

# keep track of the unit that is currently 'active'
var active_unit = null

# keep track of which units have yet to act this turn
var yet_to_act = []

func get_all_units():
	return get_children()

func get_active_unit():
	return active_unit
	
func set_active_unit(unit):
	active_unit = unit
	
func reset_yet_to_act():
	yet_to_act = party_members.duplicate()

func remove_from_yet_to_act(unit_id, hour_node = null):
	var index = 0
	var final_index = index
	var found = false
	
	for unit in yet_to_act:
		if (unit.unit_id == unit_id):
			final_index = index
			found = true
		index += 1
		
	if (final_index >= 0 && found):
		yet_to_act.remove(final_index)
		
	# if all of the unit's have acted, move forward a turn (hour)
	if (yet_to_act.size() == 0):
		player.move_to_next_hour()
		reset_yet_to_act()
		reset_unit_actions()
		
		if (hour_node != null):
			hour_node.update_time_of_day_info_text()

func reset_unit_actions():
	for unit in party_members:
		unit.reset_action_list()

func add_unit(unit):
	print('add unit')
	print (party_members)
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

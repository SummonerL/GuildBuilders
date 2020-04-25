extends Node

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# keep track of the global player variables
onready var player = get_node("/root/Player_Globals")

# bring in our abilities
onready var global_ability_list = get_node("/root/Abilities")

# all of the unit types
onready var angler_male_scn = preload("res://Entities/Player/Units/Angler_Male.tscn")
onready var angler_female_scn = preload("res://Entities/Player/Units/Angler_Female.tscn")
onready var woodcutter_male_scn = preload("res://Entities/Player/Units/Woodcutter_Male.tscn")
onready var woodcutter_female_scn = preload("res://Entities/Player/Units/Woodcutter_Female.tscn")
onready var woodworker_male_scn = preload("res://Entities/Player/Units/Woodworker_Male.tscn")
onready var woodworker_female_scn = preload("res://Entities/Player/Units/Woodworker_Female.tscn")

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
	yet_to_act = []
	for unit in party_members:
		if (unit.unit_awake):
			yet_to_act.append(unit)

func remove_from_yet_to_act(unit_id):
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

func empty_yet_to_act():
	yet_to_act = []

# function for determining if a unit is asleep at these coordinates
func is_unit_asleep_at(x, y):
	var is_asleep_here = false
	for unit in party_members:
		if (!unit.unit_awake && unit.unit_pos_x == x && unit.unit_pos_y == y):
			is_asleep_here = true
	return is_asleep_here

func reset_unit_actions():
	for unit in party_members:
		unit.reset_action_list()
		# also make sure we update their 'acted' state for the new turn
		unit.set_has_acted_state(false)

func did_unit_eat(unit):
	var ate = false
	for ability in unit.unit_abilities:
		if (ability.type == global_ability_list.ABILITY_TYPES.FOOD): # this unit has a food effect, therefore they ate
			ate = true
	
	return ate
		

func is_unit_hungry(unit):
	var hungry = false
	
	for ability in unit.unit_abilities:
		if (ability.name == global_ability_list.ABILITY_HUNGRY_NAME): # this unit has has the hungry effect
			hungry = true
			
	return hungry
# remove all food abilities from each unit
func remove_abilities_of_type(type):
	
	for unit in party_members:
		var gained_abilities = []
		var index = 0
		var unit_abilities = unit.unit_abilities.duplicate()
		for ability in unit_abilities:

			if (ability.type == type):
				gained_abilities += global_ability_list.remove_ability_from_unit(unit, ability, index)
				index -= 1
				
			index += 1
		
		unit.unit_abilities += gained_abilities # any new abilities the unit may have gained as a result of doing this

func reset_shaders():
	for unit in party_members:
		unit.remove_used_shader()

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
		constants.UNIT_TYPES.WOODWORKER_MALE:
			var woodworker_male_node = woodworker_male_scn.instance()
			add_child(woodworker_male_node)
			party_members.append(woodworker_male_node)
		constants.UNIT_TYPES.WOODWORKER_FEMALE:
			var woodworker_female_node = woodworker_female_scn.instance()
			add_child(woodworker_female_node)
			party_members.append(woodworker_female_node)

extends CanvasLayer

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in our skill information
onready var skill_info = get_node("/root/Skill_Info")

# preaload the letters + symbols
onready var letters_symbols_scn = preload("res://Entities/HUD/Letters_Symbols/Letters_Symbols.tscn")
var letters_symbols_node

const levels = [
	1,
	2,
	3,
	4,
	5,
	6,
	7,
	8,
	9,
	10,
	11,
	12,
	13,
	14,
	15,
	16,
	17,
	18,
	19,
	20
]

const LVL_TEXT = "Lv."

const MAX_WIDTH = 17

# keep track of the active skill we are looking at
var active_skill
var current_level = 1

func initialize_skill_detail_screen():
	letters_symbols_node = letters_symbols_scn.instance()
	add_child(letters_symbols_node)
	
	# make sure the letters sit on top
	letters_symbols_node.layer = self.layer + 1

func set_active_skill(skill):
	active_skill = skill

func set_current_level(level):
	current_level = level
	
func set_current_skill_icon(icon):
	add_child(icon)
	var icon2 = icon.duplicate() # add another on the right side
	add_child(icon2)
	
	icon.position = Vector2(3 * constants.DIA_TILE_WIDTH, 1 * constants.DIA_TILE_HEIGHT)
	icon.visible = true
	
	icon2.position = Vector2(15 * constants.DIA_TILE_WIDTH, 1 * constants.DIA_TILE_HEIGHT)
	icon2.visible = true
	
func populate_screen():
	# clear any letters / symbols
	letters_symbols_node.clearText()
	letters_symbols_node.clear_specials()
	
	# print the level we are currently looking at
	letters_symbols_node.print_immediately(LVL_TEXT + String(current_level), 
		Vector2((constants.DIA_TILES_PER_ROW - len(LVL_TEXT)) / 2, 2))
		
	# print the down / up arrow, depending on which level we are looking at
	if (current_level > levels[0]):
		letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.UP_ARROW, 
			Vector2(((constants.DIA_TILES_PER_ROW - 1) / 2) * constants.DIA_TILE_WIDTH, 1 * constants.DIA_TILE_HEIGHT))
			
	if (current_level < levels[levels.size() - 1]):
		letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.DOWN_ARROW, 
			Vector2(((constants.DIA_TILES_PER_ROW - 1) / 2) * constants.DIA_TILE_WIDTH, 16 * constants.DIA_TILE_HEIGHT))
		
	# print all of the things we can do at this level
	var start_y = 4
	
	var skill_unlocks = skill_info.SKILL_UNLOCKS[active_skill]
	
	for unlock in skill_unlocks:
		if (unlock.level_required == current_level):
			if (unlock.has('single_line') && unlock.single_line):
				letters_symbols_node.print_immediately(unlock.can_text + ' ' + unlock.skill_info_text, 
					Vector2((constants.DIA_TILES_PER_ROW - len(unlock.can_text + ' ' + unlock.skill_info_text)) / 2, start_y))
				start_y += 2
			else:
				letters_symbols_node.print_immediately(unlock.can_text, 
					Vector2((constants.DIA_TILES_PER_ROW - len(unlock.can_text)) / 2, start_y))
				start_y += 1
				letters_symbols_node.print_immediately(unlock.skill_info_text, 
					Vector2((constants.DIA_TILES_PER_ROW - len(unlock.skill_info_text)) / 2, start_y))
				start_y += 2
		
func _ready():
	initialize_skill_detail_screen()
	
func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		get_parent().kill_skill_detail_screen()
	if (event.is_action_pressed("ui_down")):
		if (current_level < levels[levels.size() - 1]):
			current_level+=1
			populate_screen()
		
	if (event.is_action_pressed("ui_up")):
		if (current_level > levels[0]):
			current_level -= 1
			populate_screen()

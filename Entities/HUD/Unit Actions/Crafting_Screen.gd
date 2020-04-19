extends CanvasLayer

# screen that gets displayed when a unit 'crafts' 

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in the global player variables
onready var player = get_node("/root/Player_Globals")

# bring in our global action list
onready var global_action_list = get_node("/root/Actions")

# bring in our guild variables/functions
onready var guild = get_node("/root/Guild")

# bring in our signals
onready var signals = get_node("/root/Signal_Manager")

# preaload the letters + symbols
onready var letters_symbols_scn = preload("res://Entities/HUD/Letters_Symbols/Letters_Symbols.tscn")
var letters_symbols_node

# various hud scenes
onready var hud_selection_list_scn = preload("res://Entities/HUD/Selection_List.tscn")

# our skill selection background sprite
onready var skill_selection_background_sprite = get_node("Skill_Selection_Screen")

# our skill icon sprites
onready var woodworking_skill_icon_sprite = get_node("Woodworking_Skill_Icon")

# keep an extra arrow to act as a selector
var selector_arrow

# keep track of the active unit
var active_unit

# keep track of the currently selected skill in the the user can choose for crafting
onready var all_skills = [
	constants.WOODWORKING
]
var current_skill_set = []
var current_skill = 0
var skill_start_index_tracker = 0
var skill_end_index_tracker = 0

# text for the crafting screen
const CRAFT_TEXT = 'Craft'
const WOODWORKING_TEXT = "Woodworking"

enum SCREENS {
	SKILL_SELECTION,
	ITEM_SELECTION,
	CONFIRMATION
}

# keep track of the screen we are actively looking at
var active_screen = SCREENS.SKILL_SELECTION

func crafting_screen_init():
	letters_symbols_node = letters_symbols_scn.instance()
	add_child(letters_symbols_node)
	
	# add an extra right arrow symbol to act as a selector
	selector_arrow = letters_symbols_node.arrow_right_sprite.duplicate()
	add_child(selector_arrow)
	
	selector_arrow.visible = false
	selector_arrow.position = Vector2(1 * constants.DIA_TILE_WIDTH, 1 * constants.DIA_TILE_HEIGHT)
	
	
	# make sure the letters sit on top
	letters_symbols_node.layer = self.layer + 1
	
	# dampen the background music while we are viewing the unit's information
	get_tree().get_current_scene().dampen_background_music()

func set_active_unit(unit):
	active_unit = unit
	
	# populate the skill selection screen
	populate_skill_selection_screen()

# useful functioning for quickly calculating the next level experience percentage
func calculate_next_level_percent(skill):
	return floor(active_unit.skill_xp[skill] / float(constants.experience_required[active_unit.skill_levels[skill]]) * 100.0)

func populate_skill_selection_screen(skill_start_index = 0):
	skill_start_index_tracker = skill_start_index
	
	# make the skill selection background sprite visible
	skill_selection_background_sprite.visible = true
	
	skill_end_index_tracker = skill_start_index_tracker + 2 # show 3 skills at a time
	if (skill_end_index_tracker > all_skills.size() - 1): # account for index
		skill_end_index_tracker = all_skills.size() - 1	

	woodworking_skill_icon_sprite.visible = false
	
	# skills text
	letters_symbols_node.print_immediately(CRAFT_TEXT, Vector2((constants.DIA_TILES_PER_ROW - len(CRAFT_TEXT)) / 2, 1))
	
	current_skill_set = all_skills.slice(skill_start_index_tracker, skill_end_index_tracker, 1) # only show 3 skills at a time
	
	var start_x = 1
	var start_y = 2
	
	# make the selector arrow visible
	if (all_skills.size() > 0):
		selector_arrow.visible = true
		selector_arrow.position = Vector2((start_x) * constants.DIA_TILE_WIDTH, ((start_y + 3) + ((current_skill - skill_start_index_tracker) * 4)) * constants.DIA_TILE_HEIGHT)


	# print the down / up arrow, depending on where we are in the list of skills
	if (current_skill_set.size() >= 3 && (skill_start_index_tracker + 2) < all_skills.size() - 1): # account for index
		letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.DOWN_ARROW, 
			Vector2(((constants.DIA_TILES_PER_ROW - 1) / 2) * constants.DIA_TILE_WIDTH, 16 * constants.DIA_TILE_HEIGHT))
			
	if (skill_start_index_tracker > 0):
		letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.UP_ARROW, 
			Vector2(((constants.DIA_TILES_PER_ROW - 1) / 2) * constants.DIA_TILE_WIDTH, 2 * constants.DIA_TILE_HEIGHT))
		
	var calc_next = 0
	
	for skill in current_skill_set:
		match(skill):
			constants.WOODWORKING:
				woodworking_skill_icon_sprite.visible = true
				woodworking_skill_icon_sprite.position = Vector2(start_x * constants.TILE_WIDTH, start_y * constants.TILE_HEIGHT)
				letters_symbols_node.print_immediately(WOODWORKING_TEXT, Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2)))
				var woodworking_lv_text = constants.LVL_TEXT + String(active_unit.skill_levels[constants.WOODWORKING])
				calc_next = calculate_next_level_percent(constants.WOODWORKING)
				woodworking_lv_text += "  " + constants.NEXT_LEVEL_TEXT + String(calc_next) + "%"
				letters_symbols_node.print_immediately(woodworking_lv_text, Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2) + 2))
				
		start_y += 2

func move_skills(direction):
	var start_x = 2
	var start_y = 3
	
	if (direction < 0):
		# move up
		if (current_skill > skill_start_index_tracker):
			current_skill += direction
			selector_arrow.visible = true
			selector_arrow.position = Vector2((start_x - 1) * constants.DIA_TILE_WIDTH, 
				(start_y + ((current_skill - skill_start_index_tracker) * 2)) * constants.DIA_TILE_HEIGHT)
			player.hud.full_text_destruction()
		else:
			if (letters_symbols_node.arrow_up_sprite.visible): # if we are allowed to move up
				current_skill += direction
				skill_start_index_tracker -= 4
				skill_end_index_tracker = skill_start_index_tracker + 3
				populate_skill_selection_screen(skill_start_index_tracker)
	else:
		if (current_skill < skill_end_index_tracker):
			current_skill += direction
			selector_arrow.visible = true
			selector_arrow.position = Vector2((start_x - 1) * constants.DIA_TILE_WIDTH, 
				(start_y + ((current_skill - skill_start_index_tracker) * 2)) * constants.DIA_TILE_HEIGHT)
			player.hud.full_text_destruction()
		else:
			if (letters_symbols_node.arrow_down_sprite.visible): # if we are allowed to move down
				current_skill += direction
				populate_skill_selection_screen(skill_end_index_tracker + direction)

func close_crafting_screen():
	# change the player state
	player.player_state = player.PLAYER_STATE.SELECTING_TILE
	
	# turn the music back up
	get_tree().get_current_scene().heighten_background_music()
	
	# kill ourself :(
	get_parent().remove_child(self)

func _ready():
	crafting_screen_init()
	
# input options for the crafting screen
func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		match(active_screen):
			SCREENS.SKILL_SELECTION:
				close_crafting_screen()
				# make sure we close the dialogue box as well, if it's present
				player.hud.full_text_destruction()
	if (event.is_action_pressed("ui_down")):
		match(active_screen):
			SCREENS.SKILL_SELECTION:
				move_skills(1)
	if (event.is_action_pressed("ui_up")):
		match(active_screen):
			SCREENS.SKILL_SELECTION:
				move_skills(-1)

extends CanvasLayer

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in the global player variables
onready var player = get_node("/root/Player_Globals")

# bring in our guild variables/functions
onready var guild = get_node("/root/Guild")

onready var general_info_sprite = get_node("General_Info_Sprite")
onready var quest_type_selection_sprite = get_node("Quest_Type_Selection_Sprite")
onready var guild_icon_sprite = get_node("guild_icon")
onready var quest_icon_sprite = get_node("quest_icon")

# preaload the letters + symbols
onready var letters_symbols_scn = preload("res://Entities/HUD/Letters_Symbols/Letters_Symbols.tscn")
var letters_symbols_node

# our quest details screen
onready var quest_details_scn = preload("res://Entities/HUD/Info Screens/Quest_Screen_Details.tscn")
var quest_details_node

# keep an extra arrow to act as a selector
var selector_arrow

const GUILD_TEXT = 'Guild'
const DAY_TEXT = 'Day:'
const TOTAL_SKILL_LV_TEXT = 'Total Lv.'
const QUESTS_TEXT = 'Quests'
const TYPE_MAIN = 'Main'
const TYPE_SIDE = 'Side'
const IN_PROGRESS_TEXT = 'In Progress:'
const COMPLETED_TEXT = 'Completed:'

enum SCREENS {
	GENERAL_INFO
	QUEST_TYPE_SELECT
}

onready var associated_sprites = [
	general_info_sprite,
	quest_type_selection_sprite
]

onready var quest_types = [
	TYPE_MAIN,
	TYPE_SIDE
]

onready var current_type = 0

onready var current_screen = SCREENS.GENERAL_INFO

func initialize_guild_info():
	letters_symbols_node = letters_symbols_scn.instance()
	add_child(letters_symbols_node)
	
	# make sure the text sits right on top of this
	letters_symbols_node.layer = layer + 1
	
	# add ane extra arrow to the screen to act as a selector
	selector_arrow = letters_symbols_node.arrow_right_sprite.duplicate()
	add_child(selector_arrow)

	# dampen the background music while we are viewing the guild information
	get_tree().get_current_scene().dampen_background_music()

	# set the initial screen
	change_screens()

func display_general_info():
	# show the guild icon
	guild_icon_sprite.visible = true
	guild_icon_sprite.position = Vector2((constants.DIA_TILES_PER_COL - 3) * constants.DIA_TILE_WIDTH, 1 * constants.DIA_TILE_HEIGHT)
	
	# print the guild text
	letters_symbols_node.print_immediately(GUILD_TEXT, 
		Vector2((constants.DIA_TILES_PER_ROW - len(GUILD_TEXT)) / 2, 1))

	# show the right arrow (for moving to the next screen)
	letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.RIGHT_ARROW, 
		Vector2((constants.DIA_TILES_PER_ROW - 2) * constants.DIA_TILE_WIDTH, 1 * constants.DIA_TILE_HEIGHT))
	
	# show the left arrow (for moving to the next screen)
	letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.LEFT_ARROW, 
		Vector2(1 * constants.DIA_TILE_WIDTH, 1 * constants.DIA_TILE_HEIGHT))
		
	# print the current day
	letters_symbols_node.print_immediately(DAY_TEXT + String(player.current_day), Vector2(1, 3))
	
	# print the total skill level
	player.party.calculate_total_skill_level()
	letters_symbols_node.print_immediately(TOTAL_SKILL_LV_TEXT + String(player.party.calculate_total_skill_level()), Vector2(1, 5))
	
func display_quest_type_selection():
	# show the quest icon
	quest_icon_sprite.visible = true
	quest_icon_sprite.position = Vector2((constants.DIA_TILES_PER_COL - 3) * constants.DIA_TILE_WIDTH, 1 * constants.DIA_TILE_HEIGHT)
	
	var start_x = 7
	var start_y = 2

	# make the selector arrow visible
	selector_arrow.visible = true
	selector_arrow.position = Vector2((start_x) * constants.DIA_TILE_WIDTH, ((start_y + 2) + (current_type * 6)) * constants.DIA_TILE_HEIGHT)
	
	# print the guild text
	letters_symbols_node.print_immediately(QUESTS_TEXT, 
		Vector2((constants.DIA_TILES_PER_ROW - len(QUESTS_TEXT)) / 2, 1))

	# show the right arrow (for moving to the next screen)
	letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.RIGHT_ARROW, 
		Vector2((constants.DIA_TILES_PER_ROW - 2) * constants.DIA_TILE_WIDTH, 1 * constants.DIA_TILE_HEIGHT))
	
	# show the left arrow (for moving to the next screen)
	letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.LEFT_ARROW, 
		Vector2(1 * constants.DIA_TILE_WIDTH, 1 * constants.DIA_TILE_HEIGHT))

	# print Main Quest text
	letters_symbols_node.print_immediately(TYPE_MAIN, Vector2((constants.DIA_TILES_PER_ROW - len(TYPE_MAIN)) / 2, 4))
	
	# in progress / completed text
	letters_symbols_node.print_immediately(IN_PROGRESS_TEXT + String(guild.main_in_progress.size()), Vector2(1, 6))
	var main_completed = String(guild.main_completed.size()) + "/" + String(guild.main_quests.size())
	letters_symbols_node.print_immediately(COMPLETED_TEXT + main_completed, Vector2(1, 8))
	
	# print the Side Quest Text
	letters_symbols_node.print_immediately(TYPE_SIDE, Vector2((constants.DIA_TILES_PER_ROW - len(TYPE_SIDE)) / 2, 10))
	letters_symbols_node.print_immediately(IN_PROGRESS_TEXT + String(guild.side_in_progress.size()), Vector2(1, 12))
	var side_completed = String(guild.side_completed.size()) + "/" + String(guild.side_quests.size())
	letters_symbols_node.print_immediately(COMPLETED_TEXT + side_completed, Vector2(1, 14))

func change_screens():
	# clear any letters / symbols
	letters_symbols_node.clearText()
	letters_symbols_node.clear_specials()
	
	# make all of our sprites invisible
	make_sprites_invisible()
	
	# display the corresponding background sprite
	associated_sprites[current_screen].visible = true
	
	match(current_screen):
		SCREENS.GENERAL_INFO:
			display_general_info()
		SCREENS.QUEST_TYPE_SELECT:
			display_quest_type_selection()

func make_sprites_invisible():
	selector_arrow.visible = false
	general_info_sprite.visible = false
	quest_type_selection_sprite.visible = false
	guild_icon_sprite.visible = false
	quest_icon_sprite.visible = false

func open_quest_details_screen():
	# pause this node
	set_process_input(false)
	
	# create a new instance of the quest details screen
	quest_details_node = quest_details_scn.instance()
	add_child(quest_details_node)
	
	# set the quest type
	quest_details_node.set_quest_type(current_type)
	
func close_quest_details_screen():
	# unpause this node
	set_process_input(true)
	
	# kill the quest details node
	remove_child(quest_details_node)

func close_guild_screen():
	# change the player state
	player.player_state = player.PLAYER_STATE.SELECTING_TILE
	
	# turn the music back up
	get_tree().get_current_scene().heighten_background_music()
	
	# kill ourself :(
	get_parent().remove_child(self)

func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		close_guild_screen()
		# make sure we close the dialogue box as well, if it's present
		player.hud.clearText()
		player.hud.completeText()
		player.hud.kill_timers()
	if (event.is_action_pressed("ui_accept")):
		match (current_screen):
			SCREENS.QUEST_TYPE_SELECT:
				open_quest_details_screen()
	if (event.is_action_pressed("ui_right")):
		# reset certain screen variables
		current_type = 0
		# change screens!
		if (current_screen >= (len(SCREENS) - 1) ): # account for index		
			current_screen = 0
		else:
			current_screen += 1
			
		change_screens()
	if (event.is_action_pressed("ui_left")):
		# reset certain screen variables
		current_type = 0
		if (current_screen <= 0 ): # account for index		
			current_screen = len(SCREENS) - 1 # account for index
		else:
			current_screen -= 1
			
		change_screens()
	if (event.is_action_pressed("ui_down")):
		match (current_screen):
			SCREENS.QUEST_TYPE_SELECT:
				if (current_type < (quest_types.size() - 1)): # account for index
					current_type += 1
					change_screens()
		
	if (event.is_action_pressed("ui_up")):
		match (current_screen):
			SCREENS.QUEST_TYPE_SELECT:
				if (current_type > 0):
					current_type -= 1
					change_screens()

func _ready():
	initialize_guild_info()

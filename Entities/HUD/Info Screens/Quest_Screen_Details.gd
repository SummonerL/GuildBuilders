extends CanvasLayer

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in the global player variables
onready var player = get_node("/root/Player_Globals")

# bring in our guild variables/functions
onready var guild = get_node("/root/Guild")

# preaload the letters + symbols
onready var letters_symbols_scn = preload("res://Entities/HUD/Letters_Symbols/Letters_Symbols.tscn")
var letters_symbols_node

# keep track of the currently selected quest in the quest details screen
var current_quest_set = []
var current_quest = 0
var quest_start_index_tracker = 0
var quest_end_index_tracker = 0

enum QUEST_TYPES {
	MAIN,
	SIDE
}

const QUEST_TYPE_NAMES = [
	'Main Quests',
	'Side Quests'
]

const NO_QUESTS_TEXT = 'No quests have been started or completed...'

# keep track of the quests that are in progress / completed
var active_in_progress_quests
var active_completed_quests

var current_quest_type

# keep an extra arrow to act as a selector
var selector_arrow

func initialize_quest_info_screen():
	letters_symbols_node = letters_symbols_scn.instance()
	add_child(letters_symbols_node)
	
	# make sure the text sits right on top of this
	letters_symbols_node.layer = layer + 1
	
	# add ane extra arrow to the screen to act as a selector
	selector_arrow = letters_symbols_node.arrow_right_sprite.duplicate()
	add_child(selector_arrow)

func set_quest_type(current_type):
	current_quest_type = current_type
	
	if (current_quest_type == QUEST_TYPES.MAIN):
		active_in_progress_quests = guild.main_in_progress
		active_completed_quests = guild.main_completed
	else:
		active_in_progress_quests = guild.side_in_progress
		active_completed_quests = guild.side_completed
	
	# repopulate the quest detail screen
	populate_quest_detail_screen()


func populate_quest_detail_screen(start_tracker = 0):
	quest_start_index_tracker = start_tracker
	
	# clear any letters / symbols
	letters_symbols_node.clearText()
	letters_symbols_node.clear_specials()
	
	# print the quest type text
	letters_symbols_node.print_immediately(QUEST_TYPE_NAMES[current_quest_type], 
		Vector2((constants.DIA_TILES_PER_ROW - len(QUEST_TYPE_NAMES[current_quest_type])) / 2, 1))
		
	var start_x = 2
	var start_y = 3
	
	# show in progress quests first
	var total_quests =  active_in_progress_quests + active_completed_quests
	
	quest_end_index_tracker = quest_start_index_tracker + 3
	if (quest_end_index_tracker > total_quests.size() - 1): # account for index
		quest_end_index_tracker = total_quests.size() - 1
	
	current_quest_set = total_quests.slice(quest_start_index_tracker, quest_end_index_tracker, 1) # only show 4 quests at a time
	
	# make the selector arrow visible
	if (total_quests.size() > 0):
		selector_arrow.visible = true
		selector_arrow.position = Vector2((start_x - 1) * constants.DIA_TILE_WIDTH, (start_y + ((current_quest - quest_start_index_tracker) * 2)) * constants.DIA_TILE_HEIGHT)
	else:
		player.hud.dialogueState = player.hud.STATES.INACTIVE
		player.hud.typeTextWithBuffer(NO_QUESTS_TEXT, true)
	
	# print the down / up arrow, depending on where we are in the list of items
	if (current_quest_set.size() >= 4 && (quest_start_index_tracker + 3) < total_quests.size() - 1): # account for index
		letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.DOWN_ARROW, 
			Vector2(((constants.DIA_TILES_PER_ROW - 1) / 2) * constants.DIA_TILE_WIDTH, 10 * constants.DIA_TILE_HEIGHT))
			
	if (quest_start_index_tracker > 0):
		letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.UP_ARROW, 
			Vector2(((constants.DIA_TILES_PER_ROW - 1) / 2) * constants.DIA_TILE_WIDTH, 2 * constants.DIA_TILE_HEIGHT))
	
	for quest in current_quest_set:
		letters_symbols_node.print_immediately(quest.name, Vector2(start_x, start_y))
		start_y += 2	

func move_quests(direction):
	var start_x = 2
	var start_y = 3
	
	if (direction < 0):
		# move up
		if (current_quest > quest_start_index_tracker):
			current_quest += direction
			selector_arrow.visible = true
			selector_arrow.position = Vector2((start_x - 1) * constants.DIA_TILE_WIDTH, 
				(start_y + ((current_quest - quest_start_index_tracker) * 2)) * constants.DIA_TILE_HEIGHT)
			player.hud.clearText()
			player.hud.completeText()
			player.hud.kill_timers()
		else:
			if (letters_symbols_node.arrow_up_sprite.visible): # if we are allowed to move up
				current_quest += direction
				quest_start_index_tracker -= 4
				quest_end_index_tracker = quest_start_index_tracker + 3
				populate_quest_detail_screen(quest_start_index_tracker)
	else:
		if (current_quest < quest_end_index_tracker):
			current_quest += direction
			selector_arrow.visible = true
			selector_arrow.position = Vector2((start_x - 1) * constants.DIA_TILE_WIDTH, 
				(start_y + ((current_quest - quest_start_index_tracker) * 2)) * constants.DIA_TILE_HEIGHT)
			player.hud.clearText()
			player.hud.completeText()
			player.hud.kill_timers()
		else:
			if (letters_symbols_node.arrow_down_sprite.visible): # if we are allowed to move down
				current_quest += direction
				populate_quest_detail_screen(quest_end_index_tracker + direction)

func _ready():
	initialize_quest_info_screen()
	
func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		# make sure we close the dialogue box as well, if it's present
		player.hud.clearText()
		player.hud.completeText()
		player.hud.kill_timers()
		
		get_parent().close_quest_details_screen()
		
	if (event.is_action_pressed("ui_down")):
		move_quests(1)
		
	if (event.is_action_pressed("ui_up")):
		move_quests(-1)

extends CanvasLayer

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in the global player variables
onready var player = get_node("/root/Player_Globals")

# bring in our global action list
onready var global_action_list = get_node("/root/Actions")

# bring in our items
onready var global_items_list = get_node("/root/Items")

# bring in our guild variables/functions
onready var guild = get_node("/root/Guild")

# bring in our signals
onready var signals = get_node("/root/Signal_Manager")

# preaload the letters + symbols
onready var letters_symbols_scn = preload("res://Entities/HUD/Letters_Symbols/Letters_Symbols.tscn")
var letters_symbols_node

# various hud scenes
onready var hud_selection_list_scn = preload("res://Entities/HUD/Selection_List.tscn")

# our dining background sprite
onready var dining_background_sprite = get_node("Dine_Background_Sprite")

# out dining icon sprite
onready var dining_icon_sprite = get_node("Dining_Icon_Sprite")

# keep an extra arrow to act as a selector
var selector_arrow

# keep track of the currently selected food item in the dining screen
var current_item_set = []
var current_item = 0
var depot_start_index_tracker = 0
var depot_end_index_tracker = 0

enum DINING_SCREEN_STATES {
	SELECTING_ITEM,
	SELECTING_OPTION
}

var dining_screen_state = DINING_SCREEN_STATES.SELECTING_ITEM

# keep track of the active unit
var active_unit

# text for the dining screen
const DINE_TEXT = 'Dining Hall'
const NO_FOOD_TEXT = "No food at the depot..."
const ALREADY_HAS_EFFECT_TEXT = ' already has that effect...'

# keep track of the food items at the depot
var current_food_items = []

func dining_screen_init():
	letters_symbols_node = letters_symbols_scn.instance()
	add_child(letters_symbols_node)
	
	# add ane extra arrow to the screen to act as a selector
	selector_arrow = letters_symbols_node.arrow_right_sprite.duplicate()
	add_child(selector_arrow)
	
	# make sure the letters sit on top
	letters_symbols_node.layer = self.layer + 1
	
	# dampen the background music while we are viewing the unit's information
	get_tree().get_current_scene().dampen_background_music()
	
	# go ahead and start printing the food items
	populate_food_items()

func populate_header():
	dining_icon_sprite.position = Vector2((constants.DIA_TILES_PER_COL - 2) * constants.DIA_TILE_WIDTH, 1 * constants.DIA_TILE_HEIGHT)

	# print dining text (centered)
	letters_symbols_node.print_immediately(DINE_TEXT, Vector2((constants.TILES_PER_COL) - (floor(len(DINE_TEXT) / 2.0)), 1))

# function for grabbing all of the food items from the depot (adds to current_food_items)
func get_food_items_from_depot():
	current_food_items = []
	
	var guild_items_index = 0
	
	for item in guild.current_items:
		if (item.type == global_items_list.ITEM_TYPES.FISH):
			current_food_items.append({
				"item": item,
				"index": guild_items_index
			})
			guild_items_index += 1

func populate_food_items(depot_start_index = 0):
	depot_start_index_tracker = depot_start_index
	
	# first get all of the food items
	get_food_items_from_depot()
	
	# clear any letters / symbols
	letters_symbols_node.clearText()
	letters_symbols_node.clear_specials()
	
	# make sure we close the dialogue box as well, if it's present
	player.hud.full_text_destruction()
	
	# go ahead and print the dining text and position the icon
	populate_header()
	
	# hide the selector arrow
	selector_arrow.visible = false
	
	var start_x = 2
	var start_y = 3
	
	depot_end_index_tracker = depot_start_index_tracker + 3
	
	if (depot_end_index_tracker > current_food_items.size() - 1): # account for index
		depot_end_index_tracker = current_food_items.size() - 1
		
	current_item_set = current_food_items.slice(depot_start_index_tracker, depot_end_index_tracker, 1) # only show 4 items at a time
	
	# make the selector arrow visible
	if (current_food_items.size() > 0):
		selector_arrow.visible = true
		selector_arrow.position = Vector2((start_x - 1) * constants.DIA_TILE_WIDTH, (start_y + ((current_item - depot_start_index_tracker) * 2)) * constants.DIA_TILE_HEIGHT)
	else:
		player.hud.dialogueState = player.hud.STATES.INACTIVE
		player.hud.typeTextWithBuffer(NO_FOOD_TEXT, true)
		
	# print the down / up arrow, depending on where we are in the list of food items
	if (current_item_set.size() >= 4 && (depot_start_index_tracker + 3) < current_food_items.size() - 1): # account for index
		letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.DOWN_ARROW, 
			Vector2(((constants.DIA_TILES_PER_ROW - 1) / 2) * constants.DIA_TILE_WIDTH, 10 * constants.DIA_TILE_HEIGHT))
			
	if (depot_start_index_tracker > 0):
		letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.UP_ARROW, 
			Vector2(((constants.DIA_TILES_PER_ROW - 1) / 2) * constants.DIA_TILE_WIDTH, 2 * constants.DIA_TILE_HEIGHT))

	for item in current_item_set:
		letters_symbols_node.print_immediately(item.item.name, Vector2(start_x, start_y))
		start_y += 2

func close_dining_screen():
	# change the player state
	player.player_state = player.PLAYER_STATE.SELECTING_TILE
	
	# turn the music back up
	get_tree().get_current_scene().heighten_background_music()
	
	# kill ourself :(
	get_parent().remove_child(self)

# a function used on the dining screen to move the currently selected item
func move_items(direction):
	var start_x = 2
	var start_y = 3
	
	if (direction < 0):
		# move up
		if (current_item > depot_start_index_tracker):
			current_item += direction
			selector_arrow.visible = true
			selector_arrow.position = Vector2((start_x - 1) * constants.DIA_TILE_WIDTH, 
				(start_y + ((current_item - depot_start_index_tracker) * 2)) * constants.DIA_TILE_HEIGHT)
			player.hud.full_text_destruction()
		else:
			if (letters_symbols_node.arrow_up_sprite.visible): # if we are allowed to move up
				current_item += direction
				depot_start_index_tracker -= 4
				depot_end_index_tracker = depot_start_index_tracker + 3
				populate_food_items(depot_start_index_tracker)
	else:
		if (current_item < depot_end_index_tracker):
			current_item += direction
			selector_arrow.visible = true
			selector_arrow.position = Vector2((start_x - 1) * constants.DIA_TILE_WIDTH, 
				(start_y + ((current_item - depot_start_index_tracker) * 2)) * constants.DIA_TILE_HEIGHT)
			player.hud.full_text_destruction()
		else:
			if (letters_symbols_node.arrow_down_sprite.visible): # if we are allowed to move down
				current_item += direction
				populate_food_items(depot_end_index_tracker + direction)

func _ready():
	# initialize the dining screen
	dining_screen_init()
	
# input options for the dining screen
func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		close_dining_screen()
		# make sure we close the dialogue box as well, if it's present
		player.hud.clearText()
		player.hud.completeText()
		player.hud.kill_timers()
	if (event.is_action_pressed("ui_down")):
		move_items(1)
	if (event.is_action_pressed("ui_up")):
		move_items(-1)
		

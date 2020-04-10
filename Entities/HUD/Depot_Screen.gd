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

const PORTRAIT_WIDTH = 3
const PORTRAIT_HEIGHT = 3

# our depot background sprite
onready var depot_background_sprite = get_node("Item_Info_Background_Sprite")

# keep two extra arrows to act as a selectors 
var selector_arrow_toggle
var selector_arrow_item

# keep track of the currently selected item in the depot screen
var current_item_set = []
var current_item = 0
var inv_start_index_tracker = 0
var inv_end_index_tracker = 0

enum SELECTIONS {
	UNIT,
	DEPOT
}

# keep track of the currently selected inv (the unit's, or the depot) 
var current_inv = SELECTIONS.UNIT

# keep track of the active unit
var active_unit

# text for the Depot screen
const DEPOT_TEXT = 'Depot'
const NO_ITEMS_TEXT = "No items..."

func depot_screen_init():
	letters_symbols_node = letters_symbols_scn.instance()
	add_child(letters_symbols_node)
	
	# add two extra right arrow symbols to act as selectors
	selector_arrow_toggle = letters_symbols_node.arrow_right_sprite.duplicate()
	add_child(selector_arrow_toggle)
	
	selector_arrow_toggle.visible = true
	selector_arrow_toggle.position = Vector2(1 * constants.DIA_TILE_WIDTH, 1 * constants.DIA_TILE_HEIGHT)
	
	selector_arrow_item = letters_symbols_node.arrow_right_sprite.duplicate()
	add_child(selector_arrow_item)
	
	# make sure the letters sit on top
	letters_symbols_node.layer = self.layer + 1
	
	# dampen the background music while we are viewing the unit's information
	get_tree().get_current_scene().dampen_background_music()
	
func switch_inventories(selection):
	# set the current inv
	current_inv = selection
	
	# reset the current_item
	current_item = 0
	
	match(selection):
		SELECTIONS.UNIT:
			selector_arrow_toggle.position = Vector2(1 * constants.DIA_TILE_WIDTH, 1 * constants.DIA_TILE_HEIGHT)
		SELECTIONS.DEPOT:
			selector_arrow_toggle.position = Vector2(((constants.DIA_TILES_PER_ROW / 2 + 1) * constants.DIA_TILE_WIDTH), 1 * constants.DIA_TILE_HEIGHT)
			
	# populate the unit / depot items
	populate_items()
	

func populate_items(inv_start_index = 0):
	inv_start_index_tracker = inv_start_index
	
	# clear any letters / symbols
	letters_symbols_node.clearText()
	letters_symbols_node.clear_specials()
	
	# make sure we close the dialogue box as well, if it's present
	player.hud.clearText()
	player.hud.completeText()
	player.hud.kill_timers()
	
	# hide the selector arrow
	selector_arrow_item.visible = false
	
	# reprint the unit / depot text
	print_unit_depot_text()
	
	# determine if we're looking at the unit's items or the depot's items
	var focus = active_unit
	if (current_inv == SELECTIONS.DEPOT):
		focus = guild
	
	var start_x = 2
	var start_y = 3
	
	inv_end_index_tracker = inv_start_index_tracker + 3
	if (inv_end_index_tracker > focus.current_items.size() - 1): # account for index
		inv_end_index_tracker = focus.current_items.size() - 1
	
	current_item_set = focus.current_items.slice(inv_start_index_tracker, inv_end_index_tracker, 1) # only show 4 items at a time
	
	print (current_item_set)
	# make the selector arrow visible, and start typing the initial item
	if (focus.current_items.size() > 0):
		selector_arrow_item.visible = true
		selector_arrow_item.position = Vector2((start_x - 1) * constants.DIA_TILE_WIDTH, (start_y + ((current_item - inv_start_index_tracker) * 2)) * constants.DIA_TILE_HEIGHT)

		# type the item description
		player.hud.dialogueState = player.hud.STATES.INACTIVE
		player.hud.typeTextWithBuffer(current_item_set[current_item - inv_start_index_tracker].description, true)
	else:
		player.hud.dialogueState = player.hud.STATES.INACTIVE
		player.hud.typeText(NO_ITEMS_TEXT, true)
	
	# print the down / up arrow, depending on where we are in the list of items
	if (current_item_set.size() >= 4 && (inv_start_index_tracker + 3) < focus.current_items.size() - 1): # account for index
		letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.DOWN_ARROW, 
			Vector2(((constants.DIA_TILES_PER_ROW - 1) / 2) * constants.DIA_TILE_WIDTH, 10 * constants.DIA_TILE_HEIGHT))
			
	if (inv_start_index_tracker > 0):
		letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.UP_ARROW, 
			Vector2(((constants.DIA_TILES_PER_ROW - 1) / 2) * constants.DIA_TILE_WIDTH, 2 * constants.DIA_TILE_HEIGHT))
	
	for item in current_item_set:
		letters_symbols_node.print_immediately(item.name, Vector2(start_x, start_y))
		start_y += 2

func set_unit(unit):
	active_unit = unit
	
	# go ahead and populate the unit's items
	populate_items()

func print_unit_depot_text():
	# print unit
	letters_symbols_node.print_immediately(active_unit.unit_name, Vector2(2, 1))

	# print depot text
	letters_symbols_node.print_immediately(DEPOT_TEXT, Vector2((constants.DIA_TILES_PER_ROW / 2) + 2, 1))

# a function used on the item screen to move the currently selected item
func move_items(direction):
	var start_x = 2
	var start_y = 3
	
	if (direction < 0):
		# move up
		if (current_item > inv_start_index_tracker):
			current_item += direction
			selector_arrow_item.visible = true
			selector_arrow_item.position = Vector2((start_x - 1) * constants.DIA_TILE_WIDTH, 
				(start_y + ((current_item - inv_start_index_tracker) * 2)) * constants.DIA_TILE_HEIGHT)
			player.hud.clearText()
			player.hud.completeText()
			player.hud.kill_timers()
			player.hud.dialogueState = player.hud.STATES.INACTIVE
			player.hud.typeText(current_item_set[current_item - inv_start_index_tracker].description, true)
		else:
			if (letters_symbols_node.arrow_up_sprite.visible): # if we are allowed to move up
				current_item += direction
				inv_start_index_tracker -= 4
				inv_end_index_tracker = inv_start_index_tracker + 3
				populate_items(inv_start_index_tracker)
	else:
		if (current_item < inv_end_index_tracker):
			current_item += direction
			selector_arrow_item.visible = true
			selector_arrow_item.position = Vector2((start_x - 1) * constants.DIA_TILE_WIDTH, 
				(start_y + ((current_item - inv_start_index_tracker) * 2)) * constants.DIA_TILE_HEIGHT)
			player.hud.clearText()
			player.hud.completeText()
			player.hud.kill_timers()
			player.hud.dialogueState = player.hud.STATES.INACTIVE
			player.hud.typeText(current_item_set[current_item - inv_start_index_tracker].description, true)
		else:
			if (letters_symbols_node.arrow_down_sprite.visible): # if we are allowed to move down
				current_item += direction
				populate_items(inv_end_index_tracker + direction)

# input options for the depot screen
func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		close_depot_screen()
		# make sure we close the dialogue box as well, if it's present
		player.hud.clearText()
		player.hud.completeText()
		player.hud.kill_timers()
	if (event.is_action_pressed("ui_right")): # toggle to the depot's inv
		if current_inv != SELECTIONS.DEPOT:
			switch_inventories(SELECTIONS.DEPOT)
	if (event.is_action_pressed("ui_left")):	 # toggle to the unit's inv
		if current_inv != SELECTIONS.UNIT:
			switch_inventories(SELECTIONS.UNIT)
	if (event.is_action_pressed("ui_down")):
		move_items(1)
	if (event.is_action_pressed("ui_up")):
		move_items(-1)

func close_depot_screen():
	# change the player state
	player.player_state = player.PLAYER_STATE.SELECTING_TILE
	
	# turn the music back up
	get_tree().get_current_scene().heighten_background_music()
	
	# kill ourself :(
	get_parent().remove_child(self)

func _ready():
	depot_screen_init()

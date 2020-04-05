extends CanvasLayer

# the hud item for selecting unit actions

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in the global player variables
onready var player = get_node("/root/Player_Globals")

# bring in our global action list
onready var global_action_list = get_node("/root/Actions")

# the letters and symbol scene
onready var letters_symbols_obj = preload("res://Entities/HUD/Letters_Symbols/Letters_Symbols.tscn")
var letters_symbols_node

# the change selection sound
onready var confirm_selection_sound = get_node("Confirm_Selection_Sound")

# select list is 4 tiles wide
const SELECT_LIST_WIDTH = 5

# 3 tiles high
const SELECT_LIST_1_HEIGHT = 2
const SELECT_LIST_2_HEIGHT = 3
const SELECT_LIST_3_HEIGHT = 4
const SELECT_LIST_4_HEIGHT = 5
const SELECT_LIST_5_HEIGHT = 6

var left_1
var left_2
var left_3
var left_4
var left_5

var right_1
var right_2
var right_3
var right_4
var right_5

var cancel_allowed

var side

var dead = false

# keep track of the current selection
var current_selected_item
var current_selected_item_index

var current_selected_pos

# keep track of the parent that created this selection list
var parent

# and all of the currently accessible actions
var action_list = []

# our actual selection list sprites
onready var selection_list_1_item = get_node("List_1_Item_Sprite")
onready var selection_list_2_item = get_node("List_2_Item_Sprite")
onready var selection_list_3_item = get_node("List_3_Item_Sprite")
onready var selection_list_4_item = get_node("List_4_Item_Sprite")
onready var selection_list_5_item = get_node("List_5_Item_Sprite")

func selection_list_init():
	left_1 = Vector2(0, (constants.TILES_PER_COL - SELECT_LIST_1_HEIGHT) * constants.TILE_WIDTH)
	right_1 = Vector2((constants.TILES_PER_ROW - SELECT_LIST_WIDTH) * constants.TILE_WIDTH, 
					(constants.TILES_PER_COL - SELECT_LIST_1_HEIGHT) * constants.TILE_WIDTH)
	
	left_2 = Vector2(0, (constants.TILES_PER_COL - SELECT_LIST_2_HEIGHT) * constants.TILE_WIDTH)
	right_2 = Vector2((constants.TILES_PER_ROW - SELECT_LIST_WIDTH) * constants.TILE_WIDTH, 
					(constants.TILES_PER_COL - SELECT_LIST_2_HEIGHT) * constants.TILE_WIDTH)
					
	left_3 = Vector2(0, (constants.TILES_PER_COL - SELECT_LIST_3_HEIGHT) * constants.TILE_WIDTH)
	right_3 = Vector2((constants.TILES_PER_ROW - SELECT_LIST_WIDTH) * constants.TILE_WIDTH, 
					(constants.TILES_PER_COL - SELECT_LIST_3_HEIGHT) * constants.TILE_WIDTH)
					
	left_4 = Vector2(0, (constants.TILES_PER_COL - SELECT_LIST_4_HEIGHT) * constants.TILE_WIDTH)
	right_4 = Vector2((constants.TILES_PER_ROW - SELECT_LIST_WIDTH) * constants.TILE_WIDTH, 
					(constants.TILES_PER_COL - SELECT_LIST_4_HEIGHT) * constants.TILE_WIDTH)

	left_5 = Vector2(0, (constants.TILES_PER_COL - SELECT_LIST_5_HEIGHT) * constants.TILE_WIDTH)
	right_5 = Vector2((constants.TILES_PER_ROW - SELECT_LIST_WIDTH) * constants.TILE_WIDTH, 
					(constants.TILES_PER_COL - SELECT_LIST_5_HEIGHT) * constants.TILE_WIDTH)
	
	# create a letters_symbols instance
	letters_symbols_node = letters_symbols_obj.instance()
	add_child(letters_symbols_node)
	
	position_selection_list()

func position_selection_list():
	if ((player.curs_pos_x - player.cam_pos_x) <= ((constants.TILES_PER_ROW / 2) - 1)):
		selection_list_1_item.position = right_1
		selection_list_2_item.position = right_2
		selection_list_3_item.position = right_3
		selection_list_4_item.position = right_4
		selection_list_5_item.position = right_5
		side = constants.SIDES.RIGHT
	
	if ((player.curs_pos_x - player.cam_pos_x) > ((constants.TILES_PER_ROW / 2) - 1)):
		selection_list_1_item.position = left_1
		selection_list_2_item.position = left_2
		selection_list_3_item.position = left_3
		selection_list_4_item.position = left_4
		selection_list_5_item.position = left_5
		side = constants.SIDES.LEFT
		
		pass
	pass

func populate_selection_list(actions, caller, can_cancel = true):
	# allows the user to cancel out of the menu
	cancel_allowed = can_cancel
	
	parent = caller
	var start_pos_x = 2
	if (side == constants.SIDES.RIGHT):
		start_pos_x += (constants.TILES_PER_ROW * 2) - (SELECT_LIST_WIDTH * 2)
	
	var start_pos_y = 1
	
	match len(actions):
		1:
			selection_list_1_item.visible = true
			start_pos_y += (constants.TILES_PER_COL * 2) - (SELECT_LIST_1_HEIGHT * 2)		
		2:
			selection_list_2_item.visible = true
			start_pos_y += (constants.TILES_PER_COL * 2) - (SELECT_LIST_2_HEIGHT * 2)
		3:
			selection_list_3_item.visible = true
			start_pos_y += (constants.TILES_PER_COL * 2) - (SELECT_LIST_3_HEIGHT * 2)
		4:
			selection_list_4_item.visible = true
			start_pos_y += (constants.TILES_PER_COL * 2) - (SELECT_LIST_4_HEIGHT * 2)
		5:
			selection_list_5_item.visible = true
			start_pos_y += (constants.TILES_PER_COL * 2) - (SELECT_LIST_5_HEIGHT * 2)

	# print the 'selection' icon beside the first option
	current_selected_pos = Vector2(start_pos_x * constants.DIA_TILE_WIDTH, start_pos_y * constants.DIA_TILE_HEIGHT)
	letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.RIGHT_ARROW, current_selected_pos)

	start_pos_x += 1

	for action in actions:
		letters_symbols_node.print_immediately(global_action_list.ACTION_LIST_NAMES[action], 
				Vector2(start_pos_x, start_pos_y))
		start_pos_y += 2
	
	# keep track of the currently selected item
	current_selected_item = actions[0]
	current_selected_item_index = 0
	
	action_list = actions
	

func _ready():
	selection_list_init()
	
func _input(event):
	if (!dead):
		# inputs for moving the selector
		if (event.is_action_pressed("ui_down")):
			# move the selector down
			var num_of_actions = action_list.size()
			if current_selected_item_index < (num_of_actions - 1): # account for 0 index
				current_selected_item = action_list[current_selected_item_index+1]
				current_selected_item_index += 1
				current_selected_pos.y += constants.TILE_HEIGHT
				letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.RIGHT_ARROW, current_selected_pos)
		if (event.is_action_pressed("ui_up")):
			# move the selector up
			if current_selected_item_index > 0:
				current_selected_item = action_list[current_selected_item_index-1]
				current_selected_item_index -= 1
				current_selected_pos.y -= constants.TILE_HEIGHT
				letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.RIGHT_ARROW, current_selected_pos)
				
		# cancel the selection list
		if (event.is_action_pressed("ui_cancel")):
			selection_list_1_item.visible = false
			selection_list_2_item.visible = false
			selection_list_3_item.visible = false
			selection_list_4_item.visible = false
			selection_list_5_item.visible = false
			letters_symbols_node.clear_text_non_dialogue()
			letters_symbols_node.clear_specials()
			dead = true
			kill_select_list()
			parent.cancel_select_list()

		# confirm selection
		if (event.is_action_pressed("ui_accept")):
			global_action_list.do_action(current_selected_item, parent)
			
			# play the confirmation sound
			confirm_selection_sound.play()
	
			# and kill ourself :(
			selection_list_1_item.visible = false
			selection_list_2_item.visible = false
			selection_list_3_item.visible = false
			selection_list_4_item.visible = false
			selection_list_5_item.visible = false
			letters_symbols_node.clear_text_non_dialogue()
			letters_symbols_node.clear_specials()
			confirm_selection_sound.connect("finished", self, "kill_select_list")
			dead = true

func kill_select_list():
	get_parent().remove_child(self)

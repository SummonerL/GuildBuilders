extends CanvasLayer

# the hud item for selecting unit actions

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in the global player variables
onready var player = get_node("/root/Player_Globals")

# bring in our global action list
onready var global_action_list = get_node("/root/Actions")

# bring in our signals
onready var signals = get_node("/root/Signal_Manager")

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
const SELECT_LIST_6_HEIGHT = 7

var left_1
var left_2
var left_3
var left_4
var left_5
var left_6

var right_1
var right_2
var right_3
var right_4
var right_5
var right_6

var cancel_allowed

var side

# keep track of various select list states
var confirmation = false
var confirmation_yes_signal = ''
var confirmation_no_signal = ''
var confirmation_text = ''
var accomodate_dialogue_tracker = false
var position_left_tracker = false
var position_right_tracker = false

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
onready var selection_list_6_item = get_node("List_6_Item_Sprite")

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
	
	left_6 = Vector2(0, (constants.TILES_PER_COL - SELECT_LIST_6_HEIGHT) * constants.TILE_WIDTH)
	right_6 = Vector2((constants.TILES_PER_ROW - SELECT_LIST_WIDTH) * constants.TILE_WIDTH, 
					(constants.TILES_PER_COL - SELECT_LIST_6_HEIGHT) * constants.TILE_WIDTH)
	
	# create a letters_symbols instance
	letters_symbols_node = letters_symbols_obj.instance()
	add_child(letters_symbols_node)
	
	position_selection_list()

func position_selection_list():
	# move the  window up to accomodate the text (if the correct param was passed)
	if (accomodate_dialogue_tracker):
		right_1.y -= (constants.DIA_TILE_HEIGHT * 5)
		right_2.y -= (constants.DIA_TILE_HEIGHT * 5)
		right_3.y -= (constants.DIA_TILE_HEIGHT * 5)
		right_4.y -= (constants.DIA_TILE_HEIGHT * 5)
		right_5.y -= (constants.DIA_TILE_HEIGHT * 5)
		right_6.y -= (constants.DIA_TILE_HEIGHT * 5)
		left_1.y -= (constants.DIA_TILE_HEIGHT * 5)
		left_2.y -= (constants.DIA_TILE_HEIGHT * 5)
		left_3.y -= (constants.DIA_TILE_HEIGHT * 5)
		left_4.y -= (constants.DIA_TILE_HEIGHT * 5)
		left_5.y -= (constants.DIA_TILE_HEIGHT * 5)
		left_6.y -= (constants.DIA_TILE_HEIGHT * 5)
		
	
	if (((player.curs_pos_x - player.cam_pos_x) <= ((constants.TILES_PER_ROW / 2) - 1)) || position_right_tracker ):
		selection_list_1_item.position = right_1
		selection_list_2_item.position = right_2
		selection_list_3_item.position = right_3
		selection_list_4_item.position = right_4
		selection_list_5_item.position = right_5
		selection_list_6_item.position = right_6
		side = constants.SIDES.RIGHT
	elif (((player.curs_pos_x - player.cam_pos_x) > ((constants.TILES_PER_ROW / 2) - 1)) || position_left_tracker):
		selection_list_1_item.position = left_1
		selection_list_2_item.position = left_2
		selection_list_3_item.position = left_3
		selection_list_4_item.position = left_4
		selection_list_5_item.position = left_5
		selection_list_6_item.position = left_6
		side = constants.SIDES.LEFT

func populate_selection_list(actions, caller, accomodate_dialogue = false, position_left = false, position_right = false, 
									can_cancel = true, yes_no = false, yes_no_text = '', signal_yes = '', signal_no = ''):
	
	# make sure our letters/symbols live on top of the select list
	letters_symbols_node.layer = self.layer + 1
	
	# set whether or not this is a confirmation window, and various other tracker variables
	confirmation = yes_no
	confirmation_text = yes_no_text
	confirmation_yes_signal = signal_yes
	confirmation_no_signal = signal_no
	accomodate_dialogue_tracker = accomodate_dialogue
	position_left_tracker = position_left
	position_right_tracker = position_right
	
	# reposition the list, if the correct param was passed
	if (accomodate_dialogue):
		position_selection_list()
	
	if (confirmation):
		actions = [
			global_action_list.COMPLETE_ACTION_LIST.YES,
			global_action_list.COMPLETE_ACTION_LIST.NO
		]
			
		# display the confirmation text
		if (len(confirmation_text) > 0):
			player.hud.typeTextWithBuffer(confirmation_text, true)
	
	# allows the user to cancel out of the menu
	cancel_allowed = can_cancel
	
	parent = caller
	var start_pos_x = 2
	if (side == constants.SIDES.RIGHT):
		start_pos_x += (constants.TILES_PER_ROW * 2) - (SELECT_LIST_WIDTH * 2)
	
	var start_pos_y = 1
	
	if (accomodate_dialogue):
		start_pos_y = -4
	
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
		6:
			selection_list_6_item.visible = true
			start_pos_y += (constants.TILES_PER_COL * 2) - (SELECT_LIST_6_HEIGHT * 2)

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
			if (cancel_allowed):
				selection_list_1_item.visible = false
				selection_list_2_item.visible = false
				selection_list_3_item.visible = false
				selection_list_4_item.visible = false
				selection_list_5_item.visible = false
				selection_list_6_item.visible = false
				letters_symbols_node.clear_text_non_dialogue()
				letters_symbols_node.clear_specials()
				dead = true
				kill_select_list()
				parent.cancel_select_list()

		# confirm selection
		if (event.is_action_pressed("ui_accept")):
			# if confirmation, behave a little differently
			if (confirmation):
				# clear any hud text, if this was a confirmation window
				player.hud.kill_timers()
				player.hud.completeText()
				player.hud.clearText()
				
				if (current_selected_item == global_action_list.COMPLETE_ACTION_LIST.YES):
					signals.emit_signal(confirmation_yes_signal)
				else:
					signals.emit_signal(confirmation_no_signal)
			else:
				global_action_list.do_action(current_selected_item, parent)
			
			# play the confirmation sound
			confirm_selection_sound.play()
	
			# and kill ourself :(
			selection_list_1_item.visible = false
			selection_list_2_item.visible = false
			selection_list_3_item.visible = false
			selection_list_4_item.visible = false
			selection_list_5_item.visible = false
			selection_list_6_item.visible = false
			letters_symbols_node.clear_text_non_dialogue()
			letters_symbols_node.clear_specials()
			confirm_selection_sound.connect("finished", self, "kill_select_list")
			dead = true

func kill_select_list():
	get_parent().remove_child(self)

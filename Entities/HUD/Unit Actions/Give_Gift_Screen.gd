extends CanvasLayer

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in the global player variables
onready var player = get_node("/root/Player_Globals")

# bring in our global action list
onready var global_action_list = get_node("/root/Actions")

# bring in our guild variables/functions
onready var guild = get_node("/root/Guild")

# bring in our items
onready var global_item_list = get_node("/root/Items")

# bring in our signals
onready var signals = get_node("/root/Signal_Manager")

# preload the letters + symbols
onready var letters_symbols_scn = preload("res://Entities/HUD/Letters_Symbols/Letters_Symbols.tscn")
var letters_symbols_node

# various hud scenes
onready var hud_selection_list_scn = preload("res://Entities/HUD/Selection_List.tscn")

# our depot background sprite
onready var depot_background_sprite = get_node("Give_Gift_Background_Sprite")

# keep an extra arrow to act as a selectors
var selector_arrow_item

# keep track of the currently selected item in the depot screen
var current_item_set = []
var current_item = 0
var inv_start_index_tracker = 0
var inv_end_index_tracker = 0

var all_items_list = [] # keep track of all the 'GIFT' items

enum TRADE_SCREEN_STATES {
	SELECTING_ITEM,
	SELECTING_OPTION
}

var trade_screen_state = TRADE_SCREEN_STATES.SELECTING_ITEM

onready var item_actions = [
	#global_action_list.COMPLETE_ACTION_LIST.TRANSFER_ITEM_ON_TRADE_SCREEN,
	global_action_list.COMPLETE_ACTION_LIST.VIEW_ITEM_INFO_ON_TRADE_SCREEN
]

# keep track of the active unit
var active_unit

# and the active diplomatic leader
var active_npc

# text for the gift screen
const NO_ITEMS_TEXT = "Nothing to give..."
const GIVE_ITEM_TEXT = "Give Item"

func gift_screen_init():
	letters_symbols_node = letters_symbols_scn.instance()
	add_child(letters_symbols_node)
	
	# add an extra right arrow symbols to act as selector
	
	selector_arrow_item = letters_symbols_node.arrow_right_sprite.duplicate()
	add_child(selector_arrow_item)
	
	# make sure the letters sit on top
	letters_symbols_node.layer = self.layer + 1
	
	# dampen the background music while we are viewing the unit's information
	get_tree().get_current_scene().dampen_background_music()
	
func set_unit(unit):
	active_unit = unit
	
	# filter the items to only show 'GIFTS'
	var item_index = 0
	for item in active_unit.current_items:
		if (item.type == global_item_list.ITEM_TYPES.DIPLOMATIC_GIFT):
			var the_item = {
				"item": item,
				"unit_item_index": item_index
			}
			
			all_items_list.push_back(the_item)
		
		item_index += 1
	
	populate_items()
	
func set_npc(npc):
	active_npc = npc
	
# give the current item to the npc
func give_current_item():
		
	# reposition the cursor and repopulate the list, now that we've removed that item
	if (current_item > (all_items_list.size() - 1)):
		if (current_item == inv_start_index_tracker && inv_start_index_tracker > 0):
			inv_start_index_tracker -= 4
		current_item -= 1
		
	populate_items(inv_start_index_tracker)
	
	#since we just finished with the selection list, unpause input in this node
	set_process_input(true)
	
func view_item_info():
	var item = all_items_list[current_item]
	
	# type the item info
	player.hud.dialogueState = player.hud.STATES.INACTIVE
	player.hud.typeTextWithBuffer(item.item.description, false, 'finished_viewing_item_info_depot') # reuse_signal

	yield(signals, "finished_viewing_item_info_depot")

	# since we just finished with the selection list, unpause input in this node
	set_process_input(true)
	
func cancel_select_list():
	# start processing input again (unpause this node)
	set_process_input(true)
	
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
	print_give_item_text()
	
	var start_x = 2
	var start_y = 3
	
	inv_end_index_tracker = inv_start_index_tracker + 3
	if (inv_end_index_tracker > all_items_list.size() - 1): # account for index
		inv_end_index_tracker = all_items_list.size() - 1
	
	current_item_set = all_items_list.slice(inv_start_index_tracker, inv_end_index_tracker, 1) # only show 4 items at a time
	
	# make the selector arrow visible
	if (all_items_list.size() > 0):
		selector_arrow_item.visible = true
		selector_arrow_item.position = Vector2((start_x - 1) * constants.DIA_TILE_WIDTH, (start_y + ((current_item - inv_start_index_tracker) * 2)) * constants.DIA_TILE_HEIGHT)

	else:
		player.hud.dialogueState = player.hud.STATES.INACTIVE
		player.hud.typeTextWithBuffer(NO_ITEMS_TEXT, true)
	
	# print the down / up arrow, depending on where we are in the list of items
	if (current_item_set.size() >= 4 && (inv_start_index_tracker + 3) < all_items_list.size() - 1): # account for index
		letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.DOWN_ARROW, 
			Vector2(((constants.DIA_TILES_PER_ROW - 1) / 2) * constants.DIA_TILE_WIDTH, 10 * constants.DIA_TILE_HEIGHT))
			
	if (inv_start_index_tracker > 0):
		letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.UP_ARROW, 
			Vector2(((constants.DIA_TILES_PER_ROW - 1) / 2) * constants.DIA_TILE_WIDTH, 2 * constants.DIA_TILE_HEIGHT))
	
	for item in current_item_set:
		letters_symbols_node.print_immediately(item.item.name, Vector2(start_x, start_y))
		start_y += 2
	
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
		
		else:
			if (letters_symbols_node.arrow_down_sprite.visible): # if we are allowed to move down
				current_item += direction
				populate_items(inv_end_index_tracker + direction)
	
func print_give_item_text():
	# print left unit
	letters_symbols_node.print_immediately(GIVE_ITEM_TEXT, Vector2((constants.DIA_TILES_PER_ROW - len(GIVE_ITEM_TEXT)) / 2, 1))

	
func close_give_screen():
	# change the player state
	player.player_state = player.PLAYER_STATE.SELECTING_TILE
	
	# turn the music back up
	get_tree().get_current_scene().heighten_background_music()
	
	# kill ourself :(
	get_parent().remove_child(self)
	
# input options for the trade screen
func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		close_give_screen()
		# make sure we close the dialogue box as well, if it's present
		player.hud.clearText()
		player.hud.completeText()
		player.hud.kill_timers()
	if (event.is_action_pressed("ui_down")):
		move_items(1)
	if (event.is_action_pressed("ui_up")):
		move_items(-1)
	if (event.is_action_pressed("ui_accept")):		
		# give the unit the option to 'give' or view 'info'
		if all_items_list.size() > 0:
			var hud_selection_list_node = hud_selection_list_scn.instance()
			add_child(hud_selection_list_node)
			hud_selection_list_node.layer = self.layer + 1
			hud_selection_list_node.populate_selection_list(item_actions, self, true, false, true) # can cancel, position to the right
			
			# temporarily stop processing input on this node (pause this node)
			set_process_input(false)
	
func _ready():
	gift_screen_init()

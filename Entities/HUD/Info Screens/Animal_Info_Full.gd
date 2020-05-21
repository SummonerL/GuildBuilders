extends CanvasLayer

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in the global player variables
onready var player = get_node("/root/Player_Globals")

# bring in our global action list
onready var global_action_list = get_node("/root/Actions")

# bring in our signals
onready var signals = get_node("/root/Signal_Manager")

# bring in our items
onready var global_items_list = get_node("/root/Items")

# preaload the letters + symbols
onready var letters_symbols_scn = preload("res://Entities/HUD/Letters_Symbols/Letters_Symbols.tscn")
var letters_symbols_node

# various hud scenes
onready var hud_selection_list_scn = preload("res://Entities/HUD/Selection_List.tscn")

# item info background sprite
onready var item_info_background_sprite = get_node("Item_Info_Background_Sprite")

var active_unit

# keep an extra arrow to act as a selector 
var selector_arrow

# keep track of the currently selected item in the item screen
var current_item_set = []
var current_item = 0
var inv_start_index_tracker = 0
var inv_end_index_tracker = 0

onready var item_actions = [
	global_action_list.COMPLETE_ACTION_LIST.VIEW_ITEM_INFO_IN_UNIT_SCREEN,
	global_action_list.COMPLETE_ACTION_LIST.TRASH_ITEM_IN_UNIT_SCREEN
]

const ITEM_TEXT = "Inventory"
const NO_ITEMS_TEXT = "No items..."
const TRASH_ITEM_TEXT = " discarded the item."
const CANT_DISCARD_TEXT = "This item can not be discarded."

func unit_info_full_init():
	letters_symbols_node = letters_symbols_scn.instance()
	add_child(letters_symbols_node)
	
	# add an extra right arrow symbol to act as a selector
	selector_arrow = letters_symbols_node.arrow_right_sprite.duplicate()
	add_child(selector_arrow)
	
	# make sure the letters sit on top
	letters_symbols_node.layer = self.layer + 1
	
	# dampen the background music while we are viewing the unit's information
	get_tree().get_current_scene().dampen_background_music()
	
# set the active unit that we are viewing information about
func set_unit(unit):
	active_unit = unit

func initialize_screen():
	# immediately populate the unit's items
	populate_item_screen()
	
func populate_item_screen(inv_start_index = 0):
	# clear any letters / symbols
	letters_symbols_node.clearText()
	letters_symbols_node.clear_specials()
	
	selector_arrow.visible = false
	
	# make sure we close the dialogue box as well, if it's present
	player.hud.clearText()
	player.hud.completeText()
	player.hud.kill_timers()

	inv_start_index_tracker = inv_start_index
	
	# make the item info screen visible
	item_info_background_sprite.visible = true

	# inventory use / limit
	var usage_text = String(active_unit.current_items.size()) + "/" + String(active_unit.item_limit)

	# item text
	letters_symbols_node.print_immediately(ITEM_TEXT + "  " + usage_text, 
		Vector2((constants.DIA_TILES_PER_ROW - len(ITEM_TEXT) - len("  ") - len(usage_text)) / 2, 1))
	
	var start_x = 2
	var start_y = 3
	
	inv_end_index_tracker = inv_start_index_tracker + 3
	if (inv_end_index_tracker > active_unit.current_items.size() - 1): # account for index
		inv_end_index_tracker = active_unit.current_items.size() - 1
	
	current_item_set = active_unit.current_items.slice(inv_start_index_tracker, inv_end_index_tracker, 1) # only show 4 items at a time
	
	# make the selector arrow visible
	if (active_unit.current_items.size() > 0):
		selector_arrow.visible = true
		selector_arrow.position = Vector2((start_x - 1) * constants.DIA_TILE_WIDTH, (start_y + ((current_item - inv_start_index_tracker) * 2)) * constants.DIA_TILE_HEIGHT)
	else:
		player.hud.dialogueState = player.hud.STATES.INACTIVE
		player.hud.typeTextWithBuffer(NO_ITEMS_TEXT, true)
	
	# print the down / up arrow, depending on where we are in the list of items
	if (current_item_set.size() >= 4 && (inv_start_index_tracker + 3) < active_unit.current_items.size() - 1): # account for index
		letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.DOWN_ARROW, 
			Vector2(((constants.DIA_TILES_PER_ROW - 1) / 2) * constants.DIA_TILE_WIDTH, 10 * constants.DIA_TILE_HEIGHT))
			
	if (inv_start_index_tracker > 0):
		letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.UP_ARROW, 
			Vector2(((constants.DIA_TILES_PER_ROW - 1) / 2) * constants.DIA_TILE_WIDTH, 2 * constants.DIA_TILE_HEIGHT))
	
	for item in current_item_set:
		letters_symbols_node.print_immediately(item.name, Vector2(start_x, start_y))
		start_y += 2
		
# when the unit has selected 'info' in the selection list
func show_item_info():
	var item = current_item_set[current_item - inv_start_index_tracker]
	# type the item description
	player.hud.dialogueState = player.hud.STATES.INACTIVE
	player.hud.typeTextWithBuffer(item.description, false, 'finished_viewing_text_generic') 
	
	yield(signals, "finished_viewing_text_generic")
	
	# unpause the node
	set_process_input(true)
	
# when the unit selects 'trash' in the selection list
func trash_item():
	# determine if we can discard this item
	var can_discard = (active_unit.current_items[current_item].has("can_discard") && 
						active_unit.current_items[current_item].can_discard)
	
	# remove the item from the unit
	if (can_discard):
		global_items_list.remove_item_from_unit(active_unit, current_item)
	
	# type the trash item text
	player.hud.dialogueState = player.hud.STATES.INACTIVE
	
	if (can_discard):
		player.hud.typeTextWithBuffer(active_unit.unit_name + TRASH_ITEM_TEXT, false, 'finished_viewing_text_generic') 
	else:
		player.hud.typeTextWithBuffer(CANT_DISCARD_TEXT, false, 'finished_viewing_text_generic') 
	
	yield(signals, "finished_viewing_text_generic")
	
	# reposition the cursor and repopulate the list, now that we've removed that item
	if (can_discard && current_item > (active_unit.current_items.size() - 1)):
		if (current_item == inv_start_index_tracker && inv_start_index_tracker > 0):
			inv_start_index_tracker -= 4
		current_item -= 1

	populate_item_screen(inv_start_index_tracker)

	# unpause the node
	set_process_input(true)

# a function used on the item screen to move the currently selected item
func move_items(direction):
	var start_x = 2
	var start_y = 3
	
	if (direction < 0):
		# move up
		if (current_item > inv_start_index_tracker):
			current_item += direction
			selector_arrow.visible = true
			selector_arrow.position = Vector2((start_x - 1) * constants.DIA_TILE_WIDTH, 
				(start_y + ((current_item - inv_start_index_tracker) * 2)) * constants.DIA_TILE_HEIGHT)
			player.hud.clearText()
			player.hud.completeText()
			player.hud.kill_timers()
		else:
			if (letters_symbols_node.arrow_up_sprite.visible): # if we are allowed to move up
				current_item += direction
				inv_start_index_tracker -= 4
				inv_end_index_tracker = inv_start_index_tracker + 3
				populate_item_screen(inv_start_index_tracker)
	else:
		if (current_item < inv_end_index_tracker):
			current_item += direction
			selector_arrow.visible = true
			selector_arrow.position = Vector2((start_x - 1) * constants.DIA_TILE_WIDTH, 
				(start_y + ((current_item - inv_start_index_tracker) * 2)) * constants.DIA_TILE_HEIGHT)
			player.hud.clearText()
			player.hud.completeText()
			player.hud.kill_timers()
		else:
			if (letters_symbols_node.arrow_down_sprite.visible): # if we are allowed to move down
				current_item += direction
				populate_item_screen(inv_end_index_tracker + direction)

# cancel the item select list
func cancel_select_list():
	# unpause this node
	set_process_input(true)

func _ready():
	unit_info_full_init()

# input options for the unfo screen
func _input(event):
	if (event.is_action_pressed("ui_accept")):
		# give the unit the option to view 'info' or 'trash'
		if active_unit.current_items.size() > 0:
			var hud_selection_list_node = hud_selection_list_scn.instance()
			add_child(hud_selection_list_node)
			hud_selection_list_node.layer = self.layer + 1
			
			hud_selection_list_node.populate_selection_list(item_actions, self, true, false, true) # can cancel, position to the right
		
			# temporarily stop processing input on this node (pause this node)
			set_process_input(false)
				
	if (event.is_action_pressed("ui_cancel")):
		close_unit_screen()
		# make sure we close the dialogue box as well, if it's present
		player.hud.clearText()
		player.hud.completeText()
		player.hud.kill_timers()
	if (event.is_action_pressed("ui_down")):
		move_items(1)
		
	if (event.is_action_pressed("ui_up")):
		move_items(-1)

func close_unit_screen():
	# change the player state
	player.player_state = player.PLAYER_STATE.SELECTING_TILE
	
	# turn the music back up
	get_tree().get_current_scene().heighten_background_music()
	
	# kill ourself :(
	get_parent().remove_child(self)


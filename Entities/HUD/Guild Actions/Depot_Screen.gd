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

enum DEPOT_SCREEN_STATES {
	SELECTING_ITEM,
	SELECTING_OPTION
}

var depot_screen_state = DEPOT_SCREEN_STATES.SELECTING_ITEM

onready var item_actions = [
	global_action_list.COMPLETE_ACTION_LIST.TRANSFER_ITEM_AT_DEPOT,
	global_action_list.COMPLETE_ACTION_LIST.VIEW_ITEM_INFO_AT_DEPOT,
	global_action_list.COMPLETE_ACTION_LIST.TRASH_ITEM_AT_DEPOT
]

# keep track of the currently selected inv (the unit's, or the depot) 
var current_inv = SELECTIONS.UNIT

# keep track of the 'focus' - either the unit or the guild
var focus

# keep track of the active unit
var active_unit

# text for the Depot screen
const DEPOT_TEXT = 'Depot'
const NO_ITEMS_TEXT = "No items..."
const CANT_CARRY_TEXT = ' can\'t carry anything else...'
const TRASH_ITEM_TEXT = ' discarded the item.'
const CANT_DISCARD_TEXT = "This item can not be discarded."
const CANT_MOVE_TEXT = "This item can not be moved."

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
	
func _on_cant_carry_item_dialogue_completion():
	#since we just finished with the selection list, unpause input in this node
	set_process_input(true)
	
func _on_finished_viewing_item_info():
	# since we just finished with the selection list, unpause input in this node
	set_process_input(true)
	
# helper function for sorting items by name
func sort_items_by_name(a, b):
	return a.name < b.name

# function for showing the item info
func show_item_info():
	var item = focus.current_items[current_item]
	
	signals.connect("finished_viewing_item_info_depot", self, "_on_finished_viewing_item_info", [], signals.CONNECT_ONESHOT)
	
	# type the item info
	player.hud.dialogueState = player.hud.STATES.INACTIVE
	player.hud.typeTextWithBuffer(item.description, false, 'finished_viewing_item_info_depot') 

# function for moving an item from the depot to unit, or visa/versa
func transfer_item():	
	# determine if the unit can carry anything else (if we are moving from depot -> unit)
	if (current_inv == SELECTIONS.DEPOT && (active_unit.current_items.size() >= active_unit.item_limit) ):
		signals.connect("cant_carry_item_dialogue_depot", self, "_on_cant_carry_item_dialogue_completion", [], signals.CONNECT_ONESHOT)
		
		player.hud.dialogueState = player.hud.STATES.INACTIVE
		player.hud.typeTextWithBuffer(active_unit.unit_name + CANT_CARRY_TEXT, false, 'cant_carry_item_dialogue_depot') 
		return
		
	
	# now move the item
	var item = focus.current_items[current_item]
	
	if (item.get("can_trade") == false): # some items can't be traded / moved
		player.hud.dialogueState = player.hud.STATES.INACTIVE
		player.hud.typeTextWithBuffer(CANT_MOVE_TEXT, false, 'finished_viewing_text_generic') 
		yield(signals, "finished_viewing_text_generic")
	else:
		if (current_inv == SELECTIONS.DEPOT):
			# remove from guild
			guild.remove_item_from_depot(current_item)
			
			# move to unit
			active_unit.receive_item(item)
		elif (current_inv == SELECTIONS.UNIT):
			# remove from unit
			global_item_list.remove_item_from_unit(focus, current_item)
			
			# move to depot
			guild.add_item_to_depot(item)
			
			# sort the guild items (for convenience)
			guild.current_items.sort_custom(self, 'sort_items_by_name')
			
			
		# reposition the cursor and repopulate the list, now that we've removed that item
		if (current_item > (focus.current_items.size() - 1)):
			if (current_item == inv_start_index_tracker && inv_start_index_tracker > 0):
				inv_start_index_tracker -= 4
			current_item -= 1
			
		populate_items(inv_start_index_tracker)
		
	#since we just finished with the selection list, unpause input in this node
	set_process_input(true)
		
# when the player wants to trash a selected item
func trash_item():
	# trash the item
	var item = focus.current_items[current_item]
	
	# determine if we can discard this item
	var can_discard = (item.has("can_discard") && item.can_discard)
	
	if (can_discard):
		if (current_inv == SELECTIONS.DEPOT):
			# remove from guild
			guild.current_items.remove(current_item)
			
			# sort the guild items (for convenience)
			guild.current_items.sort_custom(self, 'sort_items_by_name')
		elif (current_inv == SELECTIONS.UNIT):
			# remove from unit
			global_item_list.remove_item_from_unit(focus, current_item)
		
	# type the follow up text
	player.hud.dialogueState = player.hud.STATES.INACTIVE
	if (can_discard):
		player.hud.typeTextWithBuffer(active_unit.unit_name + TRASH_ITEM_TEXT, false, 'finished_viewing_text_generic') 
	else:
		player.hud.typeTextWithBuffer(CANT_DISCARD_TEXT, false, 'finished_viewing_text_generic') 
	
	yield(signals, "finished_viewing_text_generic")
		
	# reposition the cursor and repopulate the list, now that we've removed that item
	if (can_discard && current_item > (focus.current_items.size() - 1)):
		if (current_item == inv_start_index_tracker && inv_start_index_tracker > 0):
			inv_start_index_tracker -= 4
		current_item -= 1
		
	populate_items(inv_start_index_tracker)
	
	#since we just finished with the selection list, unpause input in this node
	set_process_input(true)
		
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
	focus = active_unit
	if (current_inv == SELECTIONS.DEPOT):
		focus = guild
	
	var start_x = 2
	var start_y = 3
	
	inv_end_index_tracker = inv_start_index_tracker + 3
	if (inv_end_index_tracker > focus.current_items.size() - 1): # account for index
		inv_end_index_tracker = focus.current_items.size() - 1
	
	current_item_set = focus.current_items.slice(inv_start_index_tracker, inv_end_index_tracker, 1) # only show 4 items at a time
	
	# make the selector arrow visible, and start typing the initial item
	if (focus.current_items.size() > 0):
		selector_arrow_item.visible = true
		selector_arrow_item.position = Vector2((start_x - 1) * constants.DIA_TILE_WIDTH, (start_y + ((current_item - inv_start_index_tracker) * 2)) * constants.DIA_TILE_HEIGHT)

	else:
		player.hud.dialogueState = player.hud.STATES.INACTIVE
		player.hud.typeTextWithBuffer(NO_ITEMS_TEXT, true)
	
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
	if (event.is_action_pressed("ui_accept")):		
		# give the unit the option to 'move' or view 'info'
		if focus.current_items.size() > 0:
			var hud_selection_list_node = hud_selection_list_scn.instance()
			add_child(hud_selection_list_node)
			hud_selection_list_node.layer = self.layer + 1
			hud_selection_list_node.populate_selection_list(item_actions, self, true, false, true) # can cancel, position to the right
			
			# temporarily stop processing input on this node (pause this node)
			set_process_input(false)

func cancel_select_list():
	# start processing input again (unpause this node)
	set_process_input(true)

func close_depot_screen():
	# change the player state
	player.player_state = player.PLAYER_STATE.SELECTING_TILE
	
	# turn the music back up
	get_tree().get_current_scene().heighten_background_music()
	
	# kill ourself :(
	get_parent().remove_child(self)

func _ready():
	depot_screen_init()

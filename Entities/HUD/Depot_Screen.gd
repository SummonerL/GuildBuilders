extends CanvasLayer

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in the global player variables
onready var player = get_node("/root/Player_Globals")

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
	
	# print depot text
	letters_symbols_node.print_immediately(DEPOT_TEXT, Vector2((constants.DIA_TILES_PER_ROW / 2) + 2, 1))
	
func switch_inventories(selection):
	# set the current inv
	current_inv = selection
	
	match(selection):
		SELECTIONS.UNIT:
			selector_arrow_toggle.position = Vector2(1 * constants.DIA_TILE_WIDTH, 1 * constants.DIA_TILE_HEIGHT)
		SELECTIONS.DEPOT:
			selector_arrow_toggle.position = Vector2(((constants.DIA_TILES_PER_ROW / 2 + 1) * constants.DIA_TILE_WIDTH), 1 * constants.DIA_TILE_HEIGHT)

func set_unit(unit):
	active_unit = unit
	
	# print unit
	letters_symbols_node.print_immediately(unit.unit_name, Vector2(2, 1))


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

func close_depot_screen():
	# change the player state
	player.player_state = player.PLAYER_STATE.SELECTING_TILE
	
	# turn the music back up
	get_tree().get_current_scene().heighten_background_music()
	
	# kill ourself :(
	get_parent().remove_child(self)

func _ready():
	depot_screen_init()

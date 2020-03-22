extends CanvasLayer

# the hud item for selecting unit actions

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in the global player variables
onready var player = get_node("/root/Player_Globals")

# the letters and symbol scene
onready var letters_symbols_obj = preload("res://Entities/HUD/Letters_Symbols/Letters_Symbols.tscn")
var letters_symbols_node

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

var side

# keep track of the current selection
var current_selected_item

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

func populate_selection_list(actions):
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
	
	letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.RIGHT_ARROW, 
							Vector2(start_pos_x * constants.DIA_TILE_WIDTH, start_pos_y * constants.DIA_TILE_HEIGHT))
	start_pos_x += 1

	for action in actions:
		letters_symbols_node.print_immediately(constants.ALL_ACTION_PRETTY_NAMES[constants.ALL_ACTIONS[action]], Vector2(start_pos_x, start_pos_y))
		start_pos_y += 2
	
	current_selected_item = actions[0]

func _ready():
	selection_list_init()

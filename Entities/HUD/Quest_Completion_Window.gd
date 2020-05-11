extends CanvasLayer

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in the global player variables
onready var player = get_node("/root/Player_Globals")

# the letters and symbol scene
onready var letters_symbols_obj = preload("res://Entities/HUD/Letters_Symbols/Letters_Symbols.tscn")
var letters_symbols_node

# the quest window sprite
onready var window_sprite = get_node("Quest_Completion_Window_Sprite")

onready var quest_icon_sprite = get_node("Quest_Icon_Sprite")

# question completion fanfare

# the item received sound
onready var item_get_sound = get_node("Item_Get_Sound")

# constants
const GOT_TEXT = 'Received'
const QUEST_TEXT = 'Quest '
const COMPLETED_TEXT = 'Completed!'

const WINDOW_WIDTH = 8
const WINDOW_HEIGHT = 4

const WINDOW_WIDTH_IN_DIA = 16
const WINDOW_HEIGHT_IN_DIA = 8

var pos_x
var pos_y

func window_init():
	# middle	
	
	pos_x = ((constants.DIA_TILES_PER_ROW * constants.DIA_TILE_WIDTH) / 2 ) - (WINDOW_WIDTH * constants.DIA_TILE_WIDTH)
	pos_y = 4 * constants.DIA_TILE_WIDTH
	window_sprite.position = Vector2(pos_x, pos_y)

	letters_symbols_node = letters_symbols_obj.instance()
	add_child(letters_symbols_node)
	
	# set icon positions
	quest_icon_sprite.position.x = pos_x + constants.DIA_TILE_WIDTH
	quest_icon_sprite.position.y = pos_y + constants.DIA_TILE_HEIGHT
	
	letters_symbols_node.print_immediately(QUEST_TEXT, Vector2((WINDOW_WIDTH + 3) - floor(len(QUEST_TEXT) / 2.0),
		(pos_y / constants.DIA_TILE_HEIGHT) + 1))
	
	letters_symbols_node.print_immediately(COMPLETED_TEXT, Vector2((WINDOW_WIDTH + 3) - floor(len(COMPLETED_TEXT) / 2.0),
		(pos_y / constants.DIA_TILE_HEIGHT) + 2))
		

func set_quest_name(quest):
	var quest_name =  quest.name
	
	# print the quest name
	letters_symbols_node.print_immediately(quest_name, Vector2((WINDOW_WIDTH + 1) - floor(len(quest_name) / 2.0),
		(pos_y / constants.DIA_TILE_HEIGHT) + 5))

func _ready():
	window_init()

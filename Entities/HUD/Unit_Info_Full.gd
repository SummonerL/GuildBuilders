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

var active_unit
var portrait_sprite

var typing_description = false


# keep track of the 'active' screen
var screen_list = [
	"BASIC_INFO"
]
var current_screen = screen_list[0]

const NAME_TEXT = "Name:"
const CLASS_TEXT = "Class:"

func unit_info_full_init():
	letters_symbols_node = letters_symbols_scn.instance()
	add_child(letters_symbols_node)
	
	# make sure the letters sit on top
	letters_symbols_node.layer = self.layer + 1

# set the active unit that we are viewing information about
func set_unit(unit):
	active_unit = unit
	
# create a portrait sprite for this unit
func set_portrait_sprite():
	portrait_sprite = Sprite.new()
	portrait_sprite.texture = active_unit.unit_portrait_sprite
	portrait_sprite.centered = false
	add_child(portrait_sprite)
	
	portrait_sprite.position = Vector2((constants.TILES_PER_ROW * constants.TILE_WIDTH) - ((PORTRAIT_WIDTH + 1) * constants.TILE_WIDTH), 
								constants.TILE_HEIGHT)

func initialize_screen():
	set_portrait_sprite()
	
	# print the name
	letters_symbols_node.print_immediately(NAME_TEXT, Vector2(1, 2))
	letters_symbols_node.print_immediately(active_unit.unit_name, Vector2(1, 4))
	
	# class
	letters_symbols_node.print_immediately(CLASS_TEXT, Vector2(1, 7))
	letters_symbols_node.print_immediately(active_unit.unit_class, Vector2(1, 9))

	# start rendering the unit description
	player.hud.dialogueState = player.hud.STATES.INACTIVE
	player.hud.typeText(active_unit.unit_bio, true)
	typing_description = true


func _ready():
	unit_info_full_init()

# input options for the unfo screen
func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		close_unit_screen()
		# make sure we close the dialogue box as well, if it's present
		player.hud.clearText()
		player.hud.completeText()

func close_unit_screen():
	# change the player state
	player.player_state = player.PLAYER_STATE.SELECTING_TILE
	# kill ourself :(
	get_parent().remove_child(self)

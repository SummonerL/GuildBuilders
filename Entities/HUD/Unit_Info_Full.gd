extends CanvasLayer

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in the global player variables
onready var player = get_node("/root/Player_Globals")

const PORTRAIT_WIDTH = 3
const PORTRAIT_HEIGHT = 3

var active_unit
var portrait_sprite

# list of actions the unit can take while viewing this screen
var action_list = [
	'STATS',
	'EXIT'
]

func unit_info_full_init():
	pass

# set the active unit that we are viewing information about
func set_unit(unit):
	active_unit = unit
	
	set_portrait_sprite()
	
# create a portrait sprite for this unit
func set_portrait_sprite():
	portrait_sprite = Sprite.new()
	portrait_sprite.texture = active_unit.unit_portrait_sprite
	portrait_sprite.centered = false
	add_child(portrait_sprite)
	
	portrait_sprite.position = Vector2((constants.TILES_PER_ROW * constants.TILE_WIDTH) - ((PORTRAIT_WIDTH + 1) * constants.TILE_WIDTH), 
								constants.TILE_HEIGHT)

func _ready():
	unit_info_full_init()

# input options for the unfo screen
func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		close_unit_screen()
	
func close_unit_screen():
	# change the player state
	player.player_state = player.PLAYER_STATE.SELECTING_TILE
	# kill ourself :(
	get_parent().remove_child(self)

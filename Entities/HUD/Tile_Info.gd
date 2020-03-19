extends CanvasLayer

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

const TILE_INFO_WIDTH = 4

# our actual tile info sprite
onready var tile_info_sprite = get_node("Tile_Info_Sprite")

var side
var left
var right


func tile_info_init():
	left = Vector2(0, 0)
	right = Vector2((constants.TILES_PER_ROW - TILE_INFO_WIDTH) * constants.TILE_WIDTH, 0)
	
	# set the starting position of the tile info hud
	change_sides(constants.SIDES.RIGHT)

func check_if_move_needed(curs_x):
	if (curs_x <= ((constants.TILES_PER_ROW / 2) - 1) && side == constants.SIDES.LEFT):
		change_sides(constants.SIDES.RIGHT)
		
	if (curs_x > ((constants.TILES_PER_ROW / 2) - 1) && side == constants.SIDES.RIGHT):
		change_sides(constants.SIDES.LEFT)

func change_sides(target_side):
	match target_side:
		constants.SIDES.LEFT:
			# position the tile info hud to the left
			side = constants.SIDES.LEFT
			tile_info_sprite.position = left
		constants.SIDES.RIGHT:
			# position the tile info hud to the right
			side = constants.SIDES.RIGHT
			tile_info_sprite.position = right
	pass

func _ready():
	tile_info_init()

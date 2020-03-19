extends CanvasLayer

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in the global player variables
onready var player = get_node("/root/Player_Globals")

const TILE_INFO_WIDTH = 4

# our actual tile info sprite
onready var tile_info_sprite = get_node("Tile_Info_Sprite")

# the letters and symbol scene
onready var letters_symbols_obj = preload("res://Entities/HUD/Letters_Symbols/Letters_Symbols.tscn")

# have 2 layers of potential tiles
onready var tileset_props_l1 = get_tree().get_nodes_in_group(constants.MAP_TILES_GROUP)[0]
onready var tileset_props_l2 = get_tree().get_nodes_in_group(constants.MAP_TILES_GROUP)[1]

# text constants, local to the Tile Info HUD
const HIDDEN_TILE_NAME = "???"
const MV_TEXT = "Mv."
const CANT_MOVE_TEXT = "Ø"

var side
var left
var right

var letters_symbols

var print_start_x
var print_start_y

func tile_info_init():
	left = Vector2(0, 0)
	right = Vector2((constants.TILES_PER_ROW - TILE_INFO_WIDTH) * constants.TILE_WIDTH, 0)
	
	# set the starting position of the tile info hud
	change_sides(constants.SIDES.RIGHT)
	
	# create a letters_symbols instance
	letters_symbols = letters_symbols_obj.instance()
	
	add_child(letters_symbols)
		
	update_tile_info_text()

func check_if_move_needed(curs_x):
	if (curs_x <= ((constants.TILES_PER_ROW / 2) - 1) && side == constants.SIDES.LEFT):
		change_sides(constants.SIDES.RIGHT)
		
	if (curs_x > ((constants.TILES_PER_ROW / 2) - 1) && side == constants.SIDES.RIGHT):
		change_sides(constants.SIDES.LEFT)

func clear_tile_info_text():
	letters_symbols.clear_text_non_dialogue()

func update_tile_info_text():
	clear_tile_info_text()
	
	# update the start pos based on the position of the info tile
	
	print_start_x = 2
	print_start_y = 1
	
	if (side == constants.SIDES.RIGHT):
		print_start_x += constants.DIA_TILES_PER_ROW - (TILE_INFO_WIDTH * 2)
	
	# get the name of the tile that the cursor is on
	var tile_l1_type = tileset_props_l1.get_tile_at_coordinates(Vector2(player.curs_pos_x, player.curs_pos_y))
	var tile_l1_name
	var tile_l1_mv
	if (tile_l1_type):
		tile_l1_name = tileset_props_l1.TILE_INFO_HUD_NAME[tile_l1_type]
		tile_l1_mv = tileset_props_l1.get_movement_cost(tile_l1_type)
	else:
		tile_l1_name = HIDDEN_TILE_NAME
		tile_l1_mv = constants.CANT_MOVE
	
	var tile_l2_type = tileset_props_l2.get_tile_at_coordinates(Vector2(player.curs_pos_x, player.curs_pos_y))
	var tile_l2_name = ""
	var tile_l2_mv = 0
	if (tile_l2_type):
		tile_l2_name = tileset_props_l2.TILE_INFO_HUD_NAME[tile_l2_type]
		tile_l2_mv = tileset_props_l1.get_movement_cost(tile_l2_type)
		
	var total_move = tile_l1_mv + tile_l2_mv
	var total_move_str = MV_TEXT
	if (total_move >= constants.CANT_MOVE):
		total_move_str += CANT_MOVE_TEXT
	else:
		total_move_str += String(total_move)
	
	var print_name = tile_l1_name
	
	if (len(tile_l2_name) > 0):
		print_name = tile_l2_name
		
	letters_symbols.print_immediately(print_name, Vector2(print_start_x, print_start_y))
	letters_symbols.print_immediately(total_move_str, Vector2(print_start_x, print_start_y+1))
	

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

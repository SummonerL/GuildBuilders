extends Node

# this is the generic animal class that all animal types with extend

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in the global player variables
onready var player = get_node("/root/Player_Globals")

# the animal type
var type

# the animals position
var animal_pos_x = 0
var animal_pos_y = 0

# the animals sprite
var animal_sprite

# called from extended script
func animal_base_init():
	pass

func set_animal_position(pos):
	animal_pos_x = pos.x
	animal_pos_y = pos.y
	self.global_position = Vector2(pos.x*constants.TILE_WIDTH, 
								pos.y*constants.TILE_HEIGHT)

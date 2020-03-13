extends Node2D

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")
	
func set_square_position(pos_x, pos_y):
	self.global_position = Vector2(pos_x*constants.TILE_WIDTH, 
									pos_y*constants.TILE_HEIGHT)

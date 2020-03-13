extends "res://Entities/Player/Units/Unit_Class.gd"

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in our global player variables
onready var player = get_node("/root/Player_Globals")

func unit_init():
	unit_pos_x = 6
	unit_pos_y = 6
	
	self.global_position = Vector2(unit_pos_x*constants.TILE_WIDTH, 
									unit_pos_y*constants.TILE_HEIGHT)

func _ready():
	unit_init()

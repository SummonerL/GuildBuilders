extends "res://Entities/Player/Units/Unit_Class.gd"

# bring in our global player variables
onready var player = get_node("/root/Player_Globals")

func unit_init():
	unit_pos_x = 7
	unit_pos_y = 1
	
	base_move = 3
	
	self.global_position = Vector2(unit_pos_x*constants.TILE_WIDTH, 
									unit_pos_y*constants.TILE_HEIGHT)
	
func _ready():
	unit_init()

func _input(event):
	if event.is_action_pressed("ui_focus_next"):
		calculate_eligible_tiles()
		


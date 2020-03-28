extends "res://Entities/Player/Units/Unit_Class.gd"

onready var ps = preload("res://Sprites/characters/woodcutter_male_portrait1.png")

func unit_init():
	unit_pos_x = 9
	unit_pos_y = 7
	
	unit_portrait_sprite = ps
	
	unit_name = "Axel"
	unit_class = "Woodcutter"
	
	age = 27
	
	unit_bio = "Yo! I'm Axel. I'm all about living the simple life. Nothing makes me happier than the smell of freshly cut "
	unit_bio += "cedar. All I want is a quiet life surrounded by nature. That pretty much sums me up!"
	
	base_move = 3
	
	skill_levels[constants.WOODCUTTING] = 5
	
	self.global_position = Vector2(unit_pos_x*constants.TILE_WIDTH, 
									unit_pos_y*constants.TILE_HEIGHT)
	
func _ready():
	unit_base_init()
	unit_init()

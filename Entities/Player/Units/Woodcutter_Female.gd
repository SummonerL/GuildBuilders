extends "res://Entities/Player/Units/Unit_Class.gd"

onready var ps = preload("res://Sprites/characters/woodcutter_female_portrait.png")

func unit_init():
	unit_pos_x = 7
	unit_pos_y = 7
	
	unit_portrait_sprite = ps
	
	unit_name = "Willow"
	unit_class = "Woodcutter"
	age = 17
	unit_bio = "Hey there! Willow here. I may be young, but don't count me out. I can swing an axe with the best of 'em! "
	unit_bio += "My parents passed away when I was a young child, so I had to grow up fast. My goal in life is simply to be "
	unit_bio += "reliable and provide for those I love. Thanks for reading!"
	
	base_move = 4
	
	skill_levels[constants.WOODCUTTING] = 5
	
	# add the unit's starting ability
	global_ability_list.add_ability_to_unit(self, global_ability_list.ability_reliable)
	
	self.global_position = Vector2(unit_pos_x*constants.TILE_WIDTH, 
									unit_pos_y*constants.TILE_HEIGHT)
	
func _ready():
	unit_base_init()
	unit_init()

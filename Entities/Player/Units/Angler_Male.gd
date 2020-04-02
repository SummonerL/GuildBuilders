extends "res://Entities/Player/Units/Unit_Class.gd"

onready var ps = preload("res://Sprites/characters/angler_male_portrait1.png")

func unit_init():
	unit_pos_x = 11
	unit_pos_y = 10
	
	unit_portrait_sprite = ps
	
	unit_id = 4

	unit_name = "Rodrik"
	unit_class = "Angler"
	
	age = 13
	
	unit_bio = "..."
	
	base_move = 3
	
	skill_levels[constants.FISHING] = 5
	
	# give the male angler some starting items
	global_items_list.add_item_to_unit(self, global_items_list.item_softwood_rod)
	
	self.global_position = Vector2(unit_pos_x*constants.TILE_WIDTH, 
									unit_pos_y*constants.TILE_HEIGHT)
	
func _ready():
	unit_base_init()
	unit_init()

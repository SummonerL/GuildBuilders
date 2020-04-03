extends "res://Entities/Player/Units/Unit_Class.gd"

onready var ps = preload("res://Sprites/characters/angler_female_portrait1.png")

func get_unit_move_sound():
	return unit_move_sound
	
func unit_init():
	unit_pos_x = 19
	unit_pos_y = 4
	
	unit_id = 3

	unit_name = "Coral"
	age = 17
	unit_class = "Angler"
	
	unit_portrait_sprite = ps
	
	unit_sprite_node = get_node("Angler_Female_Sprite")
	
	base_move = 6
	
	skill_levels[constants.FISHING] = 5
	
	# give the female angler some starting items
	global_items_list.add_item_to_unit(self, global_items_list.item_softwood_rod)
	
	self.global_position = Vector2(unit_pos_x*constants.TILE_WIDTH, 
									unit_pos_y*constants.TILE_HEIGHT)

func _ready():
	unit_base_init()
	unit_init()
	

extends "res://Entities/Player/Units/Unit_Class.gd"

onready var ps = preload("res://Sprites/characters/angler_male_portrait1.png")

# keep track of all the unique dialogue for this charater
const CANT_FISH_WITHOUT_ROD_TEXT = 'Oh no.. I don\'t have any fishing equipment. It looks like I can\'t do this right now...'
const NO_MORE_FISH_TEXT = 'No more fish... There\'s never enough in the world.' 

func unit_init():
	unit_pos_x = 11
	unit_pos_y = 10
	
	unit_portrait_sprite = ps
	
	unit_sprite_node = get_node("Angler_Male_Sprite")
	
	unit_id = 4

	unit_name = "Rodrik"
	unit_class = "Angler"
	
	age = 13
	
	unit_bio = "..."
	
	base_move = 3
	
	skill_levels[constants.FISHING] = 5
	
	# give the male angler some starting items
	global_items_list.add_item_to_unit(self, global_items_list.item_softwood_rod)
	
	# add the unit's starting ability
	global_ability_list.add_ability_to_unit(self, global_ability_list.ability_growing_boy)
	
	self.global_position = Vector2(unit_pos_x*constants.TILE_WIDTH, 
									unit_pos_y*constants.TILE_HEIGHT)
	
func _ready():
	unit_base_init()
	unit_init()

extends "res://Entities/Player/Units/Unit_Class.gd"

onready var ps = preload("res://Sprites/characters/woodworker_female_portrait.png")

# keep track of all the unique dialogue for this charater
const CANT_FISH_WITHOUT_ROD_TEXT = '...'
const NO_MORE_FISH_TEXT = '...' 

const CANT_WOODCUT_WITHOUT_AXE_TEXT = '...'
const NO_MORE_WOOD_TEXT = '...'

const INVENTORY_FULL_TEXT = '...'

const WAKE_UP_TEXT = '...'
const BED_TIME_TEXT = '...'

func unit_init():	
	unit_portrait_sprite = ps

	unit_sprite_node = get_node("Woodworker_Female_Sprite")
	
	unit_id = 6

	unit_name = "..."
	unit_class = "Woodworker"
	
	age = 27
	
	unit_bio = "..."
	unit_bio += "..."
	
	base_move = 3
	
	skill_levels[constants.WOODWORKING] = 5
	
	# give the male woodworker some starting items
	global_items_list.add_item_to_unit(self, global_items_list.item_handsaw)
	
	# add the unit's starting ability
	global_ability_list.add_ability_to_unit(self, global_ability_list.ability_artistic)
	
	self.global_position = Vector2(unit_pos_x*constants.TILE_WIDTH, 
									unit_pos_y*constants.TILE_HEIGHT)
	
func _ready():
	unit_base_init()
	unit_init()

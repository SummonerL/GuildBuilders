extends "res://Entities/Player/Units/Unit_Class.gd"

onready var ps = preload("res://Sprites/characters/woodworker_male_portrait1.png")

# keep track of all the unique dialogue for this charater
const CANT_FISH_WITHOUT_ROD_TEXT = '...'
const NO_MORE_FISH_TEXT = '...' 

const CANT_WOODCUT_WITHOUT_AXE_TEXT = '...'
const NO_MORE_WOOD_TEXT = '...'

const INVENTORY_FULL_TEXT = '...'

const WAKE_UP_TEXT = 'I wish I could just sleep in...'
const BED_TIME_TEXT = 'Finally... Time for bed.'

func unit_init():	
	unit_portrait_sprite = ps

	unit_sprite_node = get_node("Woodworker_Male_Sprite")
	
	unit_id = 5

	unit_name = "Sawyer"
	unit_class = "Woodworker"
	
	age = 35
	
	unit_bio = "Hey... I\'m Sawyer. Frankly, there's not a lot to say about me, but I try to do the best I can with my craft."
	unit_bio += " We\'ll get along as long as you don\'t interrupt me while I\'m working."
	
	base_move = 3
	
	skill_levels[constants.WOODWORKING] = 5
	
	# give the male woodworker some starting items
	global_items_list.add_item_to_unit(self, global_items_list.item_handsaw)
	
	# add the unit's starting ability
	
	self.global_position = Vector2(unit_pos_x*constants.TILE_WIDTH, 
									unit_pos_y*constants.TILE_HEIGHT)
	
func _ready():
	unit_base_init()
	unit_init()

extends "res://Entities/Player/Units/Unit_Class.gd"

onready var ps = preload("res://Sprites/characters/woodworker_male_portrait1.png")

# keep track of all the unique dialogue for this charater
const CANT_FISH_WITHOUT_ROD_TEXT = '...'
const NO_MORE_FISH_TEXT = '...' 

const CANT_WOODCUT_WITHOUT_AXE_TEXT = '...'
const NO_MORE_WOOD_TEXT = '...'

const INVENTORY_FULL_TEXT = '...'

func unit_init():
	unit_pos_x = 0
	unit_pos_y = 1
	
	unit_portrait_sprite = ps

	unit_sprite_node = get_node("Woodworker_Male_Sprite")
	
	unit_id = 5

	unit_name = "Sawyer"
	unit_class = "Woodworker"
	
	age = 35
	
	unit_bio = "..."
	unit_bio += "..."
	
	base_move = 3
	
	#skill_levels[constants.WOODWORKING] = 5
	
	# give the male woodworker some starting items
	
	# add the unit's starting ability
	
	self.global_position = Vector2(unit_pos_x*constants.TILE_WIDTH, 
									unit_pos_y*constants.TILE_HEIGHT)
	
func _ready():
	unit_base_init()
	unit_init()

extends "res://Entities/Player/Units/Unit_Class.gd"

onready var ps = preload("res://Sprites/characters/miner_female_portrait.png")

# keep track of all the unique dialogue for this charater
const CANT_FISH_WITHOUT_ROD_TEXT = '...'
const NO_MORE_FISH_TEXT = '...' 

const CANT_WOODCUT_WITHOUT_AXE_TEXT = '...'
const NO_MORE_WOOD_TEXT = '...'

const CANT_MINE_WITHOUT_PICKAXE_TEXT = '...'
const NO_MORE_ORE_TEXT = '...'

const INVENTORY_FULL_TEXT = '...'

const NOT_SKILLED_ENOUGH_TEXT = '...'

const WAKE_UP_TEXT = '...'
const BED_TIME_TEXT = '...'
const HUNGRY_TEXT = '...'

func unit_init():	
	unit_portrait_sprite = ps

	unit_sprite_node = get_node("Miner_Female_Sprite")
	
	unit_id = 8

	unit_name = "Jade"
	unit_class = "Miner"
	
	age = 22
	
	unit_bio = "..."
	unit_bio += "..."
	
	base_move = 3
	
	skill_levels[constants.MINING] = 5
	
	# give the male woodworker some starting items
	global_items_list.add_item_to_unit(self, global_items_list.item_sturdy_pickaxe)
	global_items_list.add_item_to_unit(self, global_items_list.item_jumbofish)
	
	# add the unit's starting ability
	starting_ability = global_ability_list.ability_gem_hunter
	global_ability_list.add_ability_to_unit(self, global_ability_list.ability_gem_hunter)
	
	self.global_position = Vector2(unit_pos_x*constants.TILE_WIDTH, 
									unit_pos_y*constants.TILE_HEIGHT)
	
func _ready():
	unit_base_init()
	unit_init()

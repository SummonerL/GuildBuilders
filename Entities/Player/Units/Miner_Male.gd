extends "res://Entities/Player/Units/Unit_Class.gd"

onready var ps = preload("res://Sprites/characters/miner_male_portrait.png")

# keep track of all the unique dialogue for this charater
const CANT_FISH_WITHOUT_ROD_TEXT = '...'
const NO_MORE_FISH_TEXT = '...' 

const CANT_WOODCUT_WITHOUT_AXE_TEXT = '...'
const NO_MORE_WOOD_TEXT = '...'

const CANT_MINE_WITHOUT_PICKAXE_TEXT = '...'
const NO_MORE_ORE_TEXT = '...'

const CANT_TAP_WITHOUT_TAPPER_TEXT = '...'

const NOTHING_HERE_GENERIC_TEXT = "It's empty..."

const INVENTORY_FULL_TEXT = '...'

const NOT_SKILLED_ENOUGH_TEXT = '...'

const WAKE_UP_TEXT = '...'
const BED_TIME_TEXT = '...'
const HUNGRY_TEXT = '...'

const TOWER_CLIMB_TEXT = "I'm not a fan of heights, but this view is wonderful!"

func unit_init():	
	unit_portrait_sprite = ps

	unit_sprite_node = get_node("Miner_Male_Sprite")
	
	unit_id = 7

	unit_name = "Rocko"
	unit_class = "Miner"
	
	age = 31
	
	unit_bio = "..."
	unit_bio += "..."
	
	base_move = 3
	
	item_mounting_representation = global_items_list.item_rocko_mount_representation
	
	skill_levels[constants.MINING] = 5
	
	# give the male woodworker some starting items
	global_items_list.add_item_to_unit(self, global_items_list.item_sturdy_pickaxe)
	global_items_list.add_item_to_unit(self, global_items_list.item_jumbofish)
	
	# add the unit's starting ability
	starting_ability = global_ability_list.ability_tunneler
	global_ability_list.add_ability_to_unit(self, global_ability_list.ability_tunneler)
	
	self.global_position = Vector2(unit_pos_x*constants.TILE_WIDTH, 
									unit_pos_y*constants.TILE_HEIGHT)
	
func _ready():
	unit_base_init()
	unit_init()

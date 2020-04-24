extends "res://Entities/Player/Units/Unit_Class.gd"

onready var ps = preload("res://Sprites/characters/angler_male_portrait1.png")

# keep track of all the unique dialogue for this charater
const CANT_FISH_WITHOUT_ROD_TEXT = 'Oh no.. I don\'t have any fishing equipment. It looks like I can\'t do this right now...'
const NO_MORE_FISH_TEXT = 'No more fish... There\'s never enough in the world.' 

const CANT_WOODCUT_WITHOUT_AXE_TEXT = 'I probably need an axe for this...'
const NO_MORE_WOOD_TEXT = 'Time to move on to another area. No more wood here!'

const INVENTORY_FULL_TEXT = 'Hmm... I don\'t think I can carry anything else. I should try that later.'

const WAKE_UP_TEXT = 'Time to get up! There\'s fish to catch!'
const BED_TIME_TEXT = 'I can barely hold my eyes open... I should head back.'

func unit_init():
	unit_portrait_sprite = ps
	
	unit_sprite_node = get_node("Angler_Male_Sprite")
	
	unit_id = 4

	unit_name = "Rodrik"
	unit_class = "Angler"
	
	age = 13
	
	unit_bio = "Isn\'t fish delicious? There\'s something about fish that I can\'t get enough of... I want to try eating every fish in the world! "
	unit_bio += "I\'m Rodrik by the way."
	
	base_move = 3
	
	skill_levels[constants.FISHING] = 5
	
	# give the male angler some starting items
	global_items_list.add_item_to_unit(self, global_items_list.item_softwood_rod)
	global_items_list.add_item_to_unit(self, global_items_list.item_musclefish)
	
	# add the unit's starting ability
	global_ability_list.add_ability_to_unit(self, global_ability_list.ability_growing_boy)
	
	self.global_position = Vector2(unit_pos_x*constants.TILE_WIDTH, 
									unit_pos_y*constants.TILE_HEIGHT)
	
func _ready():
	unit_base_init()
	unit_init()

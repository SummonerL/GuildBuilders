extends "res://Entities/Player/Units/Unit_Class.gd"

onready var ps = preload("res://Sprites/characters/woodcutter_female_portrait.png")

# keep track of all the unique dialogue for this charater
const CANT_FISH_WITHOUT_ROD_TEXT = 'I\'m ill-prepared for this. I should come back next time with some fishing equipment.'
const NO_MORE_FISH_TEXT = 'There\'s no more fish here.... I should come back later.' 

const CANT_WOODCUT_WITHOUT_AXE_TEXT = 'How could I forget my trusty axe...? Better come back later.'
const NO_MORE_WOOD_TEXT = '...and that\'s enough for that area. Let\'s look elsewhere.'

const INVENTORY_FULL_TEXT = 'If only I had a bigger bag... I should try this again after I free up some space.'

const WAKE_UP_TEXT = 'Ugh... I can\'t sleep. Might as well get started.'
const BED_TIME_TEXT = 'I should get to bed so I can be just as productive tomorrow!'

func unit_init():
	unit_portrait_sprite = ps
	
	unit_sprite_node = get_node("Woodcutter_Female_Sprite")
	
	unit_id = 1
	
	unit_name = "Willow"
	unit_class = "Woodcutter"
	age = 17
	unit_bio = "Hey there! Willow here. I may be young, but don't count me out. I can swing an axe with the best of 'em! "
	unit_bio += "My parents passed away when I was a young child, so I had to grow up fast. My goal in life is simply to be "
	unit_bio += "reliable and provide for those I love. Thanks for reading!"
	
	base_move = 3
	
	skill_levels[constants.WOODCUTTING] = 5
	
	# give the female woodcutter some starting items
	global_items_list.add_item_to_unit(self, global_items_list.item_sturdy_axe)
	
	# add the unit's starting ability
	global_ability_list.add_ability_to_unit(self, global_ability_list.ability_insomniac)
	
	self.global_position = Vector2(unit_pos_x*constants.TILE_WIDTH, 
									unit_pos_y*constants.TILE_HEIGHT)
	
func _ready():
	unit_base_init()
	unit_init()

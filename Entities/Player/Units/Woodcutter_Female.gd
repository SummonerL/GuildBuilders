extends "res://Entities/Player/Units/Unit_Class.gd"

onready var ps = preload("res://Sprites/characters/woodcutter_female_portrait.png")

# keep track of all the unique dialogue for this charater
const CANT_FISH_WITHOUT_ROD_TEXT = 'I\'m ill-prepared for this. I should come back next time with some fishing equipment.'
const NO_MORE_FISH_TEXT = 'There\'s no more fish here.... I should come back later.' 

const CANT_WOODCUT_WITHOUT_AXE_TEXT = 'How could I forget my trusty axe...? Better come back later.'
const NO_MORE_WOOD_TEXT = '...and that\'s enough for that area. Let\'s look elsewhere.'

const CANT_MINE_WITHOUT_PICKAXE_TEXT = 'This looks tough to do without any kind of mining equipment...'
const NO_MORE_ORE_TEXT = 'Hmm... it doesn\'t look like there\'s anything else here...'

const CANT_TAP_WITHOUT_TAPPER_TEXT = 'I\'ll probably need a tree tapper if I want to do that...'

const NOTHING_HERE_GENERIC_TEXT = "Nothing to find here..."

const INVENTORY_FULL_TEXT = 'If only I had a bigger bag... I should try this again after I free up some space.'

const NOT_SKILLED_ENOUGH_TEXT = 'If only I were a little more skilled at this...'

const WAKE_UP_TEXT = 'Ugh... I can\'t sleep. Might as well get started.'
const BED_TIME_TEXT = 'I should get to bed so I can be just as productive tomorrow!'
const HUNGRY_TEXT = 'I wish I had eaten yesterday...'

const TOWER_CLIMB_TEXT = 'What a stunning view!'

func unit_init():	
	#TEMP ---------
	#unit_pos_x = 39
	#unit_pos_y = 9
	
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
	
	item_mounting_representation = global_items_list.item_willow_mount_representation
	
	skill_levels[constants.WOODCUTTING] = 5
	
	# give the female woodcutter some starting items
	global_items_list.add_item_to_unit(self, global_items_list.item_sturdy_axe)
	global_items_list.add_item_to_unit(self, global_items_list.item_jumbofish)
	
	#TEMP
	skill_levels[constants.DIPLOMACY] = 5
	skill_levels[constants.BEAST_MASTERY] = 5
	global_items_list.add_item_to_unit(self, global_items_list.item_catfish)
	global_items_list.add_item_to_unit(self, global_items_list.item_catfish)
	global_items_list.add_item_to_unit(self, global_items_list.item_catfish)
	global_items_list.add_item_to_unit(self, global_items_list.item_walking_stick)
	global_items_list.add_item_to_unit(self, global_items_list.item_willow_mount_representation)
	
	# add the unit's starting ability
	starting_ability = global_ability_list.ability_insomniac
	global_ability_list.add_ability_to_unit(self, global_ability_list.ability_insomniac)
	
	self.global_position = Vector2(unit_pos_x*constants.TILE_WIDTH, 
									unit_pos_y*constants.TILE_HEIGHT)
	
func _ready():
	unit_base_init()
	unit_init()

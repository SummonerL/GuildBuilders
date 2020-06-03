extends "res://Entities/Player/Units/Unit_Class.gd"

onready var ps = preload("res://Sprites/characters/woodworker_female_portrait.png")

# keep track of all the unique dialogue for this charater
const CANT_FISH_WITHOUT_ROD_TEXT = 'I should come back with some fishing equipment...'
const NO_MORE_FISH_TEXT = 'No more fishies here! Let\'s try someplace else.' 

const CANT_WOODCUT_WITHOUT_AXE_TEXT = 'I don\'t think I can do that without an axe...'
const NO_MORE_WOOD_TEXT = 'I think I\'ve exhausted this area...'

const CANT_MINE_WITHOUT_PICKAXE_TEXT = 'Hmm... I should try this again when I have some mining equipment.'
const NO_MORE_ORE_TEXT = '...and I think that about does it for this area. Nothing else to find here.'

const NOTHING_HERE_GENERIC_TEXT = "Hmm... looks like nothing is here."

const INVENTORY_FULL_TEXT = 'If I try to carry anything else I\'ll probably collapse!'

const NOT_SKILLED_ENOUGH_TEXT = 'One day I\'ll be skilled enough to tackle this!'

const WAKE_UP_TEXT = 'Another beautiful morning! Maybe I should go for a jog to get my creative juices flowing.'
const BED_TIME_TEXT = 'So... sleepy... Time for bed...'
const HUNGRY_TEXT = 'Wow, I got too wrapped up in my work and forgot to eat...'

const TOWER_CLIMB_TEXT = 'This view is incredible! I wish I could capture it somehow...'

func unit_init():	
	unit_portrait_sprite = ps

	unit_sprite_node = get_node("Woodworker_Female_Sprite")
	
	unit_id = 6

	unit_name = "Hazel"
	unit_class = "Woodworker"
	
	age = 27
	
	unit_bio = "Hazel here! I pour my heart and soul into everything that I do. I express myself through my creations. "
	unit_bio += "My goal is to inspire people throughout the world with my beautiful works of art!"
	
	base_move = 3
	
	skill_levels[constants.WOODWORKING] = 5
	
	# give the female woodworker some starting items
	global_items_list.add_item_to_unit(self, global_items_list.item_handsaw)
	global_items_list.add_item_to_unit(self, global_items_list.item_jumbofish)
	
	# TEMP
	global_items_list.add_item_to_unit(self, global_items_list.item_birch_logs)
	
	# add the unit's starting ability
	starting_ability = global_ability_list.ability_artistic
	global_ability_list.add_ability_to_unit(self, global_ability_list.ability_artistic)
	
	self.global_position = Vector2(unit_pos_x*constants.TILE_WIDTH, 
									unit_pos_y*constants.TILE_HEIGHT)
	
func _ready():
	unit_base_init()
	unit_init()

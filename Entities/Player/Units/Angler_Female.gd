extends "res://Entities/Player/Units/Unit_Class.gd"

onready var ps = preload("res://Sprites/characters/angler_female_portrait1.png")

# keep track of all the unique dialogue for this charater
const CANT_FISH_WITHOUT_ROD_TEXT = 'How could I forget my fishing equipment? I guess I\'ll have to come back later...'
const NO_MORE_FISH_TEXT = 'Even with my eyes, I\'m not seeing any more fish here.' 

const CANT_WOODCUT_WITHOUT_AXE_TEXT = 'I\'m not sure if I can do that without an axe...'
const NO_MORE_WOOD_TEXT = 'I\'ve exhausted this area. Time to find another spot!'

const INVENTORY_FULL_TEXT = 'My hands are full... Looks like I\'m going to have to come back later.'

const NOT_SKILLED_ENOUGH_TEXT = 'That looks a bit too tough for me...'

const WAKE_UP_TEXT = 'Mornin\' already? Let\'s get started!'
const BED_TIME_TEXT = 'That\'s enough for today. I need sleep...'
const HUNGRY_TEXT = 'I should\'ve eaten something yesterday...'

func get_unit_move_sound():
	return unit_move_sound
	
func unit_init():	
	unit_id = 3

	unit_name = "Ripley"
	unit_class = "Angler"
	
	age = 17
	
	unit_bio = "How\'s it going? I\'m Ripley. I grew up on the Evast River, so I know a thing or two about fish. The key to catchin' "
	unit_bio += "fish is to catch them off guard. In one day\'s time, I can catch enough fish to feed a village!"
	
	unit_portrait_sprite = ps
	
	unit_sprite_node = get_node("Angler_Female_Sprite")
	
	base_move = 3
	
	skill_levels[constants.FISHING] = 5
	
	# give the female angler some starting items
	global_items_list.add_item_to_unit(self, global_items_list.item_flexible_rod)
	global_items_list.add_item_to_unit(self, global_items_list.item_jumbofish)
	
	# add the unit's starting ability
	starting_ability = global_ability_list.ability_river_queen
	global_ability_list.add_ability_to_unit(self, global_ability_list.ability_river_queen)
	
	self.global_position = Vector2(unit_pos_x*constants.TILE_WIDTH, 
									unit_pos_y*constants.TILE_HEIGHT)

func _ready():
	unit_base_init()
	unit_init()
	

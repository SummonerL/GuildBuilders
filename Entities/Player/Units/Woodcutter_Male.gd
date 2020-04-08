extends "res://Entities/Player/Units/Unit_Class.gd"

onready var ps = preload("res://Sprites/characters/woodcutter_male_portrait1.png")

# keep track of all the unique dialogue for this charater
const CANT_FISH_WITHOUT_ROD_TEXT = 'I don\'t know how I\'m going to be able to fish without any equipment...'
const NO_MORE_FISH_TEXT = 'There\'s no more fish here. I guess I must have scared them away.' 

const INVENTORY_FULL_TEXT = 'Surprisingly, I don\'t think I can carry any thing else. I\'ll try this again later.'

func unit_init():
	unit_pos_x = 9
	unit_pos_y = 7
	
	unit_portrait_sprite = ps

	unit_sprite_node = get_node("Woodcutter_Male_Sprite")
	
	unit_id = 2

	unit_name = "Axel"
	unit_class = "Woodcutter"
	
	age = 27
	
	unit_bio = "Yo! I'm Axel. I'm all about living the simple life. Nothing makes me happier than the smell of freshly cut "
	unit_bio += "cedar. All I want is a quiet life surrounded by nature. That pretty much sums me up!"
	
	base_move = 3
	
	skill_levels[constants.WOODCUTTING] = 5
	
	# add the unit's starting ability
	global_ability_list.add_ability_to_unit(self, global_ability_list.ability_roughing_it)
	
	self.global_position = Vector2(unit_pos_x*constants.TILE_WIDTH, 
									unit_pos_y*constants.TILE_HEIGHT)
	
func _ready():
	unit_base_init()
	unit_init()

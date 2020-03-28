extends CanvasLayer

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in the global player variables
onready var player = get_node("/root/Player_Globals")

# preaload the letters + symbols
onready var letters_symbols_scn = preload("res://Entities/HUD/Letters_Symbols/Letters_Symbols.tscn")
var letters_symbols_node

const PORTRAIT_WIDTH = 3
const PORTRAIT_HEIGHT = 3

# the unit info background sprite
onready var unit_info_background_sprite = get_node("Unit_Info_Background_Sprite")

# skill info background sprite
onready var skill_info_background_sprite = get_node("Skill_Info_Background_Full_Sprite")

# all of the skill sprites
onready var mining_skill_icon_sprite = get_node("Mining_Skill_Icon")
onready var fishing_skill_icon_sprite = get_node("Fishing_Skill_Icon")
onready var woodcutting_skill_icon_sprite = get_node("Woodcutting_Skill_Icon")

var active_unit
var portrait_sprite

var typing_description = false


# keep track of the 'active' screen
enum screen_list {
	BASIC_INFO,
	SKILL_INFO
}

var current_screen = screen_list.BASIC_INFO

const NAME_TEXT = "Name:"
const AGE_TEXT = "Age:"
const CLASS_TEXT = "Class:"
const MOVE_TEXT = "Mv."
const WAKE_TEXT = "Wk."
const SKILL_TEXT = "Skills"
const LVL_TEXT = "Lv."
const WOODCUTTING_TEXT = "Woodcutting"
const FISHING_TEXT = "Fishing"
const MINING_TEXT = "Mining"

func unit_info_full_init():
	letters_symbols_node = letters_symbols_scn.instance()
	add_child(letters_symbols_node)
	
	# make sure the letters sit on top
	letters_symbols_node.layer = self.layer + 1

# set the active unit that we are viewing information about
func set_unit(unit):
	active_unit = unit
	
# create a portrait sprite for this unit
func set_portrait_sprite():
	portrait_sprite = Sprite.new()
	portrait_sprite.texture = active_unit.unit_portrait_sprite
	portrait_sprite.centered = false
	portrait_sprite.visible = false
	add_child(portrait_sprite)
	
	portrait_sprite.position = Vector2((constants.TILES_PER_ROW * constants.TILE_WIDTH) - ((PORTRAIT_WIDTH + 1) * constants.TILE_WIDTH), 
								constants.TILE_HEIGHT)

func initialize_screen():		
	set_portrait_sprite()
	change_screen()


func type_unit_bio(timer = null):
	if (timer):
		timer.stop()
		remove_child(timer)

	player.hud.dialogueState = player.hud.STATES.INACTIVE
	player.hud.typeText(active_unit.unit_bio, true)
	typing_description = true

func populate_basic_info_screen():
	# make the background screen visible
	unit_info_background_sprite.visible = true
	
	# make the portrait sprite visible
	portrait_sprite.visible = true
	
	# show the right arrow (for moving to the next screen)
	letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.RIGHT_ARROW, 
		Vector2((constants.DIA_TILES_PER_ROW - 2) * constants.DIA_TILE_WIDTH, 10 * constants.DIA_TILE_HEIGHT))
	
	# show the left arrow (for moving to the next screen)
	letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.LEFT_ARROW, 
		Vector2(1 * constants.DIA_TILE_WIDTH, 10 * constants.DIA_TILE_HEIGHT))
	
	# print the name
	letters_symbols_node.print_immediately(active_unit.unit_name, Vector2(1, 2))
	
	# print the unit's age
	letters_symbols_node.print_immediately(AGE_TEXT + String(active_unit.age), Vector2(1, 4))

	# print the unit's movement
	letters_symbols_node.print_immediately(MOVE_TEXT + String(active_unit.base_move), Vector2(1, 6))
	
	# print the unit's wake-up time
	letters_symbols_node.print_immediately(WAKE_TEXT + String(constants.TIMES_OF_DAY[active_unit.wake_up_time]), Vector2(1, 8))
	
	# class
	var class_length = len(active_unit.unit_class)
	
	letters_symbols_node.print_immediately(active_unit.unit_class, Vector2((constants.DIA_TILES_PER_ROW - class_length) / 2, 10))
	
	# start rendering the unit description
	# we need to add a small timer to 'buffer' the input, so the opening of the menu doesn't
	# interact with the _input of the dialogue hud
	var timer = Timer.new()
	timer.connect("timeout", self, "type_unit_bio", [timer])
	timer.wait_time = .05
	add_child(timer)
	timer.start()

func populate_skill_info_screen():
	# make the skill info background sprite visible
	skill_info_background_sprite.visible = true
	
	mining_skill_icon_sprite.visible = true
	fishing_skill_icon_sprite.visible = true
	woodcutting_skill_icon_sprite.visible = true
	
	# show the right arrow (for moving to the next screen)
	letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.RIGHT_ARROW, 
		Vector2((constants.DIA_TILES_PER_ROW - 2) * constants.DIA_TILE_WIDTH, 1 * constants.DIA_TILE_HEIGHT))
	
	# show the left arrow (for moving to the next screen)
	letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.LEFT_ARROW, 
		Vector2(1 * constants.DIA_TILE_WIDTH, 1 * constants.DIA_TILE_HEIGHT))
	
	# skills text
	letters_symbols_node.print_immediately(SKILL_TEXT, Vector2((constants.DIA_TILES_PER_ROW - len(SKILL_TEXT)) / 2, 1))
	
	
	var start_x = 1
	var start_y = 2
	
	# fishing
	fishing_skill_icon_sprite.position = Vector2(start_x * constants.TILE_WIDTH, start_y * constants.TILE_HEIGHT)
	letters_symbols_node.print_immediately(FISHING_TEXT, Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2)))
	letters_symbols_node.print_immediately(LVL_TEXT + String(active_unit.skill_levels[constants.FISHING]), Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2) + 2))
	start_y += 2

	# woodcutting
	woodcutting_skill_icon_sprite.position = Vector2(start_x * constants.TILE_WIDTH, start_y * constants.TILE_HEIGHT)
	letters_symbols_node.print_immediately(WOODCUTTING_TEXT, Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2)))
	letters_symbols_node.print_immediately(LVL_TEXT + String(active_unit.skill_levels[constants.WOODCUTTING]), Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2) + 2))
	start_y += 2
	
	# mining
	mining_skill_icon_sprite.position = Vector2(start_x * constants.TILE_WIDTH, start_y * constants.TILE_HEIGHT)
	letters_symbols_node.print_immediately(MINING_TEXT, Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2)))
	letters_symbols_node.print_immediately(LVL_TEXT + String(active_unit.skill_levels[constants.MINING]), Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2) + 2))
	
func make_all_sprites_invisible():
	for node in self.get_children():
		if node is Sprite:
			node.visible = false

func change_screen():
	# clear any letters / symbols
	letters_symbols_node.clearText()
	
	# make all sprites invisible
	make_all_sprites_invisible()
	
	# make sure we close the dialogue box as well, if it's present
	player.hud.clearText()
	player.hud.completeText()
	player.hud.kill_timers()
	
	# change the screen
	match(current_screen):
		screen_list.BASIC_INFO:
			populate_basic_info_screen()
		screen_list.SKILL_INFO:
			populate_skill_info_screen()

func _ready():
	unit_info_full_init()

# input options for the unfo screen
func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		close_unit_screen()
		# make sure we close the dialogue box as well, if it's present
		player.hud.clearText()
		player.hud.completeText()
		player.hud.kill_timers()
	if (event.is_action_pressed("ui_right")):
		# change screens!
		if (current_screen >= (len(screen_list) - 1) ): # account for index		
			current_screen = 0
		else:
			current_screen += 1
			
		change_screen()

	if (event.is_action_pressed("ui_left")):
		# change screens!
		if (current_screen <= 0 ): # account for index		
			current_screen = len(screen_list) - 1 # account for index
		else:
			current_screen -= 1
			
		change_screen()

func close_unit_screen():
	# change the player state
	player.player_state = player.PLAYER_STATE.SELECTING_TILE
	# kill ourself :(
	get_parent().remove_child(self)

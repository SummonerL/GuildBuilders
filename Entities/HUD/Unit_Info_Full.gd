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

# item info background sprite
onready var item_info_background_sprite = get_node("Item_Info_Background_Sprite")

# all of the skill sprites
onready var mining_skill_icon_sprite = get_node("Mining_Skill_Icon")
onready var fishing_skill_icon_sprite = get_node("Fishing_Skill_Icon")
onready var woodcutting_skill_icon_sprite = get_node("Woodcutting_Skill_Icon")

var active_unit
var portrait_sprite

# keep track of the 'active' screen
enum screen_list {
	BASIC_INFO,
	ITEMS,
	SKILL_INFO,
	ABILITY_INFO
}

# keep an extra arrow to act as a selector 
var selector_arrow

# keep track of the currently selected item in the item screen
var current_item_set = []
var current_item = 0
var inv_start_index_tracker = 0
var inv_end_index_tracker = 0

# keep track of the currently selected ability in the ability screen
var current_abil_set = []
var current_abil = 0
var abil_start_index_tracker = 0
var abil_end_index_tracker = 0

var current_screen = screen_list.BASIC_INFO

const NAME_TEXT = "Name:"
const AGE_TEXT = "Age:"
const CLASS_TEXT = "Class:"
const MOVE_TEXT = "Mv."
const WAKE_TEXT = "Wake:"
const BED_TEXT = "Bed:"
const SKILL_TEXT = "Skills"
const ITEM_TEXT = "Inventory"
const ABILITIES_TEXT = "Abilities"
const NEXT_LEVEL_TEXT = "Nxt."
const LVL_TEXT = "Lv."
const WOODCUTTING_TEXT = "Woodcutting"
const FISHING_TEXT = "Fishing"
const MINING_TEXT = "Mining"

const NO_ITEMS_TEXT = "No items..."
const NO_ABIL_TEXT = "No abilities..."

func unit_info_full_init():
	letters_symbols_node = letters_symbols_scn.instance()
	add_child(letters_symbols_node)
	
	# add an extra right arrow symbol to act as a selector
	selector_arrow = letters_symbols_node.arrow_right_sprite.duplicate()
	add_child(selector_arrow)
	
	# make sure the letters sit on top
	letters_symbols_node.layer = self.layer + 1
	
	# dampen the background music while we are viewing the unit's information
	get_tree().get_current_scene().dampen_background_music()

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
								constants.DIA_TILE_HEIGHT)

func initialize_screen():		
	set_portrait_sprite()
	change_screen()


func type_unit_bio(timer = null):
	if (timer):
		timer.stop()
		remove_child(timer)

	player.hud.dialogueState = player.hud.STATES.INACTIVE
	player.hud.typeText(active_unit.unit_bio, true)

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
	
	# print the unit's bed time
	letters_symbols_node.print_immediately(BED_TEXT + String(constants.TIMES_OF_DAY[active_unit.bed_time]), 
		Vector2((constants.DIA_TILES_PER_ROW - len(BED_TEXT + String(constants.TIMES_OF_DAY[active_unit.bed_time]))) - 1, 8))
	
	# class
	var class_length = len(active_unit.unit_class)
	
	letters_symbols_node.print_immediately(active_unit.unit_class, Vector2((constants.DIA_TILES_PER_ROW - class_length) / 2, 10))
	
	# start rendering the unit description
	# we need to add a small timer to 'buffer' the input, so the opening of the menu doesn't
	# interact with the _input of the dialogue hud
	var timer = Timer.new()
	timer.connect("timeout", self, "type_unit_bio", [timer])
	timer.wait_time = .01
	add_child(timer)
	timer.start()

# useful functioning for quickly calculating the next level experience percentage
func calculate_next_level_percent(skill):
	return floor(active_unit.skill_xp[skill] / float(constants.experience_required[active_unit.skill_levels[skill]]) * 100.0)
	
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
	
	var calc_next = 0
	
	# fishing
	fishing_skill_icon_sprite.position = Vector2(start_x * constants.TILE_WIDTH, start_y * constants.TILE_HEIGHT)
	letters_symbols_node.print_immediately(FISHING_TEXT, Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2)))
	var fishing_lv_text = LVL_TEXT + String(active_unit.skill_levels[constants.FISHING])
	calc_next = calculate_next_level_percent(constants.FISHING)
	fishing_lv_text += "  " + NEXT_LEVEL_TEXT + String(calc_next) + "%"
	letters_symbols_node.print_immediately(fishing_lv_text, Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2) + 2))
	start_y += 2

	# woodcutting
	woodcutting_skill_icon_sprite.position = Vector2(start_x * constants.TILE_WIDTH, start_y * constants.TILE_HEIGHT)
	letters_symbols_node.print_immediately(WOODCUTTING_TEXT, Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2)))
	var woodcutting_lv_text = LVL_TEXT + String(active_unit.skill_levels[constants.WOODCUTTING])
	calc_next = calculate_next_level_percent(constants.WOODCUTTING)
	woodcutting_lv_text += "  " + NEXT_LEVEL_TEXT + String(calc_next) + "%"
	letters_symbols_node.print_immediately(woodcutting_lv_text, Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2) + 2))
	start_y += 2
	
	# mining
	mining_skill_icon_sprite.position = Vector2(start_x * constants.TILE_WIDTH, start_y * constants.TILE_HEIGHT)
	letters_symbols_node.print_immediately(MINING_TEXT, Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2)))
	var mining_lv_text = LVL_TEXT + String(active_unit.skill_levels[constants.MINING])
	calc_next = calculate_next_level_percent(constants.MINING)
	mining_lv_text += "  " + NEXT_LEVEL_TEXT + String(calc_next) + "%"
	letters_symbols_node.print_immediately(mining_lv_text, Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2) + 2))
	
func populate_item_screen(inv_start_index = 0):
	inv_start_index_tracker = inv_start_index
	
	# make the item info screen visible
	item_info_background_sprite.visible = true
	
	# show the right arrow (for moving to the next screen)
	letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.RIGHT_ARROW, 
		Vector2((constants.DIA_TILES_PER_ROW - 2) * constants.DIA_TILE_WIDTH, 1 * constants.DIA_TILE_HEIGHT))
	
	# show the left arrow (for moving to the next screen)
	letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.LEFT_ARROW, 
		Vector2(1 * constants.DIA_TILE_WIDTH, 1 * constants.DIA_TILE_HEIGHT))

	# inventory use / limit
	var usage_text = String(active_unit.current_items.size()) + "/" + String(active_unit.item_limit)

	# item text
	letters_symbols_node.print_immediately(ITEM_TEXT + "  " + usage_text, 
		Vector2((constants.DIA_TILES_PER_ROW - len(ITEM_TEXT) - len("  ") - len(usage_text)) / 2, 1))
	
	var start_x = 2
	var start_y = 3
	
	inv_end_index_tracker = inv_start_index_tracker + 3
	if (inv_end_index_tracker > active_unit.current_items.size() - 1): # account for index
		inv_end_index_tracker = active_unit.current_items.size() - 1
	
	current_item_set = active_unit.current_items.slice(inv_start_index_tracker, inv_end_index_tracker, 1) # only show 4 items at a time
	
	# make the selector arrow visible, and start typing the initial item
	if (active_unit.current_items.size() > 0):
		selector_arrow.visible = true
		selector_arrow.position = Vector2((start_x - 1) * constants.DIA_TILE_WIDTH, (start_y + ((current_item - inv_start_index_tracker) * 2)) * constants.DIA_TILE_HEIGHT)

		# type the item description
		player.hud.dialogueState = player.hud.STATES.INACTIVE
		player.hud.typeText(current_item_set[current_item - inv_start_index_tracker].description, true)
	else:
		player.hud.dialogueState = player.hud.STATES.INACTIVE
		player.hud.typeText(NO_ITEMS_TEXT, true)
	
	# print the down / up arrow, depending on where we are in the list of items
	if (current_item_set.size() >= 4 && (inv_start_index_tracker + 3) < active_unit.current_items.size() - 1): # account for index
		letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.DOWN_ARROW, 
			Vector2(((constants.DIA_TILES_PER_ROW - 1) / 2) * constants.DIA_TILE_WIDTH, 10 * constants.DIA_TILE_HEIGHT))
			
	if (inv_start_index_tracker > 0):
		letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.UP_ARROW, 
			Vector2(((constants.DIA_TILES_PER_ROW - 1) / 2) * constants.DIA_TILE_WIDTH, 2 * constants.DIA_TILE_HEIGHT))
	
	for item in current_item_set:
		letters_symbols_node.print_immediately(item.name, Vector2(start_x, start_y))
		start_y += 2

# a function used on the item screen to move the currently selected item
func move_items(direction):
	var start_x = 2
	var start_y = 3
	
	if (direction < 0):
		# move up
		if (current_item > inv_start_index_tracker):
			current_item += direction
			selector_arrow.visible = true
			selector_arrow.position = Vector2((start_x - 1) * constants.DIA_TILE_WIDTH, 
				(start_y + ((current_item - inv_start_index_tracker) * 2)) * constants.DIA_TILE_HEIGHT)
			player.hud.clearText()
			player.hud.completeText()
			player.hud.kill_timers()
			player.hud.dialogueState = player.hud.STATES.INACTIVE
			player.hud.typeText(current_item_set[current_item - inv_start_index_tracker].description, true)
		else:
			if (letters_symbols_node.arrow_up_sprite.visible): # if we are allowed to move up
				current_item += direction
				inv_start_index_tracker -= 4
				inv_end_index_tracker = inv_start_index_tracker + 3
				change_screen(inv_start_index_tracker)
	else:
		if (current_item < inv_end_index_tracker):
			current_item += direction
			selector_arrow.visible = true
			selector_arrow.position = Vector2((start_x - 1) * constants.DIA_TILE_WIDTH, 
				(start_y + ((current_item - inv_start_index_tracker) * 2)) * constants.DIA_TILE_HEIGHT)
			player.hud.clearText()
			player.hud.completeText()
			player.hud.kill_timers()
			player.hud.dialogueState = player.hud.STATES.INACTIVE
			player.hud.typeText(current_item_set[current_item - inv_start_index_tracker].description, true)
		else:
			if (letters_symbols_node.arrow_down_sprite.visible): # if we are allowed to move down
				current_item += direction
				change_screen(inv_end_index_tracker + direction)

func populate_ability_screen(abil_start_index = 0):
	abil_start_index_tracker = abil_start_index
	
	# reuse the item info background sprite
	item_info_background_sprite.visible = true

	# show the right arrow (for moving to the next screen)
	letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.RIGHT_ARROW, 
		Vector2((constants.DIA_TILES_PER_ROW - 2) * constants.DIA_TILE_WIDTH, 1 * constants.DIA_TILE_HEIGHT))
	
	# show the left arrow (for moving to the next screen)
	letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.LEFT_ARROW, 
		Vector2(1 * constants.DIA_TILE_WIDTH, 1 * constants.DIA_TILE_HEIGHT))
		
	# ability text
	letters_symbols_node.print_immediately(ABILITIES_TEXT, 
		Vector2((constants.DIA_TILES_PER_ROW - len(ABILITIES_TEXT)) / 2, 1))
	
	var start_x = 2
	var start_y = 3
	
	abil_end_index_tracker = abil_start_index_tracker + 3
	if (abil_end_index_tracker > active_unit.unit_abilities.size() - 1): # account for index
		abil_end_index_tracker = active_unit.unit_abilities.size() - 1
	
	current_abil_set = active_unit.unit_abilities.slice(abil_start_index_tracker, abil_end_index_tracker, 1) # only show 4 abilities at a time
	
	# make the selector arrow visible, and start typing the initial ability
	if (active_unit.unit_abilities.size() > 0):
		selector_arrow.visible = true
		selector_arrow.position = Vector2((start_x - 1) * constants.DIA_TILE_WIDTH, (start_y + ((current_abil - abil_start_index_tracker) * 2)) * constants.DIA_TILE_HEIGHT)

		# type the ability description
		player.hud.dialogueState = player.hud.STATES.INACTIVE
		player.hud.typeText(current_abil_set[current_abil - abil_start_index_tracker].description, true)
	else:
		player.hud.dialogueState = player.hud.STATES.INACTIVE
		player.hud.typeText(NO_ABIL_TEXT, true)
	
	# print the down / up arrow, depending on where we are in the list of abilities
	if (current_abil_set.size() >= 4 && (abil_start_index_tracker + 3) < active_unit.unit_abilities.size() - 1): # account for index
		letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.DOWN_ARROW, 
			Vector2(((constants.DIA_TILES_PER_ROW - 1) / 2) * constants.DIA_TILE_WIDTH, 10 * constants.DIA_TILE_HEIGHT))
			
	if (abil_start_index_tracker > 0):
		letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.UP_ARROW, 
			Vector2(((constants.DIA_TILES_PER_ROW - 1) / 2) * constants.DIA_TILE_WIDTH, 2 * constants.DIA_TILE_HEIGHT))
	
	for ability in current_abil_set:
		letters_symbols_node.print_immediately(ability.name, Vector2(start_x, start_y))
		start_y += 2
	
func move_abilities(direction):
	var start_x = 2
	var start_y = 3
	
	if (direction < 0):
		# move up
		if (current_abil > abil_start_index_tracker):
			current_abil += direction
			selector_arrow.visible = true
			selector_arrow.position = Vector2((start_x - 1) * constants.DIA_TILE_WIDTH, 
				(start_y + ((current_abil - abil_start_index_tracker) * 2)) * constants.DIA_TILE_HEIGHT)
			player.hud.clearText()
			player.hud.completeText()
			player.hud.kill_timers()
			player.hud.dialogueState = player.hud.STATES.INACTIVE
			player.hud.typeText(current_abil_set[current_abil - abil_start_index_tracker].description, true)
		else:
			if (letters_symbols_node.arrow_up_sprite.visible): # if we are allowed to move up
				current_abil += direction
				abil_start_index_tracker -= 4
				abil_end_index_tracker = abil_start_index_tracker + 3
				change_screen(abil_start_index_tracker)
	else:
		if (current_abil < abil_end_index_tracker):
			current_abil += direction
			selector_arrow.visible = true
			selector_arrow.position = Vector2((start_x - 1) * constants.DIA_TILE_WIDTH, 
				(start_y + ((current_abil - abil_start_index_tracker) * 2)) * constants.DIA_TILE_HEIGHT)
			player.hud.clearText()
			player.hud.completeText()
			player.hud.kill_timers()
			player.hud.dialogueState = player.hud.STATES.INACTIVE
			player.hud.typeText(current_abil_set[current_abil - abil_start_index_tracker].description, true)
		else:
			if (letters_symbols_node.arrow_down_sprite.visible): # if we are allowed to move down
				current_abil += direction
				change_screen(abil_end_index_tracker + direction)

func make_all_sprites_invisible():
	# make the selector arrow invisible
	selector_arrow.visible = false
	
	for node in self.get_children():
		if node is Sprite:
			node.visible = false

func change_screen(screen_start_index = 0):
	# clear any letters / symbols
	letters_symbols_node.clearText()
	letters_symbols_node.clear_specials()
	
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
		screen_list.ITEMS:
			populate_item_screen(screen_start_index)
		screen_list.ABILITY_INFO:
			populate_ability_screen(screen_start_index)

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
		# reset variables if on specific screens
		match(current_screen):
			screen_list.ITEMS:
				current_item = 0
			screen_list.ABILITY_INFO:
				current_abil = 0
		# change screens!
		if (current_screen >= (len(screen_list) - 1) ): # account for index		
			current_screen = 0
		else:
			current_screen += 1
			
		change_screen()

	if (event.is_action_pressed("ui_left")):
		# reset variables if on specific screens
		match(current_screen):
			screen_list.ITEMS:
				current_item = 0
			screen_list.ABILITY_INFO:
				current_abil = 0
		# change screens!
		if (current_screen <= 0 ): # account for index		
			current_screen = len(screen_list) - 1 # account for index
		else:
			current_screen -= 1
			
		change_screen()
		
	if (event.is_action_pressed("ui_down")):
		match (current_screen):
			screen_list.ITEMS:
				move_items(1)
			screen_list.ABILITY_INFO:
				move_abilities(1)
		
	if (event.is_action_pressed("ui_up")):
		match (current_screen):
			screen_list.ITEMS:
				move_items(-1)
			screen_list.ABILITY_INFO:
				move_abilities(-1)

func close_unit_screen():
	# change the player state
	player.player_state = player.PLAYER_STATE.SELECTING_TILE
	
	# turn the music back up
	get_tree().get_current_scene().heighten_background_music()
	
	# kill ourself :(
	get_parent().remove_child(self)

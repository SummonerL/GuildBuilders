extends CanvasLayer

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in the global player variables
onready var player = get_node("/root/Player_Globals")

# bring in our global action list
onready var global_action_list = get_node("/root/Actions")

# bring in our abilities
onready var global_ability_list = get_node("/root/Abilities")

# bring in our items
onready var global_items_list = get_node("/root/Items")

# bring in our signals
onready var signals = get_node("/root/Signal_Manager")

# preaload the letters + symbols
onready var letters_symbols_scn = preload("res://Entities/HUD/Letters_Symbols/Letters_Symbols.tscn")
var letters_symbols_node

const PORTRAIT_WIDTH = 3
const PORTRAIT_HEIGHT = 3

# preload the full skill detail screen
onready var full_skill_detail_screen = preload("res://Entities/HUD/Info Screens/Skill_Details_Full.tscn")
var full_skill_detail_screen_node

# various hud scenes
onready var hud_selection_list_scn = preload("res://Entities/HUD/Selection_List.tscn")

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
onready var woodworking_skill_icon_sprite = get_node("Woodworking_Skill_Icon")
onready var smithing_skill_icon_sprite = get_node("Smithing_Skill_Icon")
onready var fashioning_skill_icon_sprite = get_node("Fashioning_Skill_Icon")
onready var beast_mastery_skill_icon_sprite = get_node("Beast_Mastery_Skill_Icon")
onready var diplomacy_skill_icon_sprite = get_node("Diplomacy_Skill_Icon")

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

# keep track of the currently selected skill in the skill screen
onready var all_skills = [
	constants.FISHING,
	constants.WOODCUTTING,
	constants.MINING,
	constants.WOODWORKING,
	constants.SMITHING,
	constants.FASHIONING,
	constants.BEAST_MASTERY,
	constants.DIPLOMACY
]

onready var all_skill_icons = [
	fishing_skill_icon_sprite,
	woodcutting_skill_icon_sprite,
	mining_skill_icon_sprite,
	woodworking_skill_icon_sprite,
	smithing_skill_icon_sprite,
	fashioning_skill_icon_sprite,
	beast_mastery_skill_icon_sprite,
	diplomacy_skill_icon_sprite
]

var current_skill_set = []
var current_skill = 0
var skill_start_index_tracker = 0
var skill_end_index_tracker = 0

var current_screen = screen_list.BASIC_INFO

onready var item_actions = [
	global_action_list.COMPLETE_ACTION_LIST.VIEW_ITEM_INFO_IN_UNIT_SCREEN,
	global_action_list.COMPLETE_ACTION_LIST.TRASH_ITEM_IN_UNIT_SCREEN
]

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
const WOODWORKING_TEXT = "Woodworking"
const SMITHING_TEXT = "Smithing"
const FASHIONING_TEXT = "Fashioning"
const BEAST_MASTERY_TEXT = "Beast Mastery"
const DIPLOMACY_TEXT = "Diplomacy"

const NO_ITEMS_TEXT = "No items..."
const NO_ABIL_TEXT = "No abilities..."

const TRASH_ITEM_TEXT = " discarded the item."
const CANT_DISCARD_TEXT = "This item can not be discarded."
const USE_ITEM_TEXT = " used the "
const ALREADY_HAS_EFFECT_TEXT = ' already has that effect.'

const CANT_USE_ITEM_ACTING = 'You can\'t use items after acting...'

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
	
func populate_skill_info_screen(skill_start_index = 0):
	skill_start_index_tracker = skill_start_index
	
	# make the skill info background sprite visible
	skill_info_background_sprite.visible = true
	
	skill_end_index_tracker = skill_start_index_tracker + 2 # show 3 skills at a time
	if (skill_end_index_tracker > all_skills.size() - 1): # account for index
		skill_end_index_tracker = all_skills.size() - 1	

	mining_skill_icon_sprite.visible = false
	fishing_skill_icon_sprite.visible = false
	woodcutting_skill_icon_sprite.visible = false
	woodworking_skill_icon_sprite.visible = false
	smithing_skill_icon_sprite.visible = false
	fashioning_skill_icon_sprite.visible = false
	beast_mastery_skill_icon_sprite.visible = false
	diplomacy_skill_icon_sprite.visible = false
	
	# show the right arrow (for moving to the next screen)
	letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.RIGHT_ARROW, 
		Vector2((constants.DIA_TILES_PER_ROW - 2) * constants.DIA_TILE_WIDTH, 1 * constants.DIA_TILE_HEIGHT))
	
	# show the left arrow (for moving to the next screen)
	letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.LEFT_ARROW, 
		Vector2(1 * constants.DIA_TILE_WIDTH, 1 * constants.DIA_TILE_HEIGHT))
	
	# skills text
	letters_symbols_node.print_immediately(SKILL_TEXT, Vector2((constants.DIA_TILES_PER_ROW - len(SKILL_TEXT)) / 2, 1))
	
	current_skill_set = all_skills.slice(skill_start_index_tracker, skill_end_index_tracker, 1) # only show 3 skills at a time
	
	var start_x = 1
	var start_y = 2
	
	# make the selector arrow visible
	if (all_skills.size() > 0):
		selector_arrow.visible = true
		selector_arrow.position = Vector2((start_x) * constants.DIA_TILE_WIDTH, ((start_y + 3) + ((current_skill - skill_start_index_tracker) * 4)) * constants.DIA_TILE_HEIGHT)


	# print the down / up arrow, depending on where we are in the list of skills
	if (current_skill_set.size() >= 3 && (skill_start_index_tracker + 2) < all_skills.size() - 1): # account for index
		letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.DOWN_ARROW, 
			Vector2(((constants.DIA_TILES_PER_ROW - 1) / 2) * constants.DIA_TILE_WIDTH, 16 * constants.DIA_TILE_HEIGHT))
			
	if (skill_start_index_tracker > 0):
		letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.UP_ARROW, 
			Vector2(((constants.DIA_TILES_PER_ROW - 1) / 2) * constants.DIA_TILE_WIDTH, 2 * constants.DIA_TILE_HEIGHT))
		
	var calc_next = 0
	
	for skill in current_skill_set:
		match(skill):
			constants.FISHING:
				fishing_skill_icon_sprite.visible = true
				fishing_skill_icon_sprite.position = Vector2(start_x * constants.TILE_WIDTH, start_y * constants.TILE_HEIGHT)
				letters_symbols_node.print_immediately(FISHING_TEXT, Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2)))
				var fishing_lv_text = LVL_TEXT + String(active_unit.skill_levels[constants.FISHING])
				calc_next = calculate_next_level_percent(constants.FISHING)
				fishing_lv_text += "  " + NEXT_LEVEL_TEXT + String(calc_next) + "%"
				letters_symbols_node.print_immediately(fishing_lv_text, Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2) + 2))
			constants.WOODCUTTING:
				woodcutting_skill_icon_sprite.visible = true
				woodcutting_skill_icon_sprite.position = Vector2(start_x * constants.TILE_WIDTH, start_y * constants.TILE_HEIGHT)
				letters_symbols_node.print_immediately(WOODCUTTING_TEXT, Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2)))
				var woodcutting_lv_text = LVL_TEXT + String(active_unit.skill_levels[constants.WOODCUTTING])
				calc_next = calculate_next_level_percent(constants.WOODCUTTING)
				woodcutting_lv_text += "  " + NEXT_LEVEL_TEXT + String(calc_next) + "%"
				letters_symbols_node.print_immediately(woodcutting_lv_text, Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2) + 2))
			constants.MINING:
				mining_skill_icon_sprite.visible = true
				mining_skill_icon_sprite.position = Vector2(start_x * constants.TILE_WIDTH, start_y * constants.TILE_HEIGHT)
				letters_symbols_node.print_immediately(MINING_TEXT, Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2)))
				var mining_lv_text = LVL_TEXT + String(active_unit.skill_levels[constants.MINING])
				calc_next = calculate_next_level_percent(constants.MINING)
				mining_lv_text += "  " + NEXT_LEVEL_TEXT + String(calc_next) + "%"
				letters_symbols_node.print_immediately(mining_lv_text, Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2) + 2))
			constants.WOODWORKING:
				woodworking_skill_icon_sprite.visible = true
				woodworking_skill_icon_sprite.position = Vector2(start_x * constants.TILE_WIDTH, start_y * constants.TILE_HEIGHT)
				letters_symbols_node.print_immediately(WOODWORKING_TEXT, Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2)))
				var woodworking_lv_text = LVL_TEXT + String(active_unit.skill_levels[constants.WOODWORKING])
				calc_next = calculate_next_level_percent(constants.WOODWORKING)
				woodworking_lv_text += "  " + NEXT_LEVEL_TEXT + String(calc_next) + "%"
				letters_symbols_node.print_immediately(woodworking_lv_text, Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2) + 2))
			constants.SMITHING:
				smithing_skill_icon_sprite.visible = true
				smithing_skill_icon_sprite.position = Vector2(start_x * constants.TILE_WIDTH, start_y * constants.TILE_HEIGHT)
				letters_symbols_node.print_immediately(SMITHING_TEXT, Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2)))
				var smithing_lv_text = LVL_TEXT + String(active_unit.skill_levels[constants.SMITHING])
				calc_next = calculate_next_level_percent(constants.SMITHING)
				smithing_lv_text += "  " + NEXT_LEVEL_TEXT + String(calc_next) + "%"
				letters_symbols_node.print_immediately(smithing_lv_text, Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2) + 2))
			constants.FASHIONING:
				fashioning_skill_icon_sprite.visible = true
				fashioning_skill_icon_sprite.position = Vector2(start_x * constants.TILE_WIDTH, start_y * constants.TILE_HEIGHT)
				letters_symbols_node.print_immediately(FASHIONING_TEXT, Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2)))
				var fashioning_lv_text = LVL_TEXT + String(active_unit.skill_levels[constants.FASHIONING])
				calc_next = calculate_next_level_percent(constants.FASHIONING)
				fashioning_lv_text += "  " + NEXT_LEVEL_TEXT + String(calc_next) + "%"
				letters_symbols_node.print_immediately(fashioning_lv_text, Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2) + 2))
			constants.BEAST_MASTERY:
				beast_mastery_skill_icon_sprite.visible = true
				beast_mastery_skill_icon_sprite.position = Vector2(start_x * constants.TILE_WIDTH, start_y * constants.TILE_HEIGHT)
				letters_symbols_node.print_immediately(BEAST_MASTERY_TEXT, Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2)))
				var beast_mastery_lv_text = LVL_TEXT + String(active_unit.skill_levels[constants.BEAST_MASTERY])
				calc_next = calculate_next_level_percent(constants.BEAST_MASTERY)
				beast_mastery_lv_text += "  " + NEXT_LEVEL_TEXT + String(calc_next) + "%"
				letters_symbols_node.print_immediately(beast_mastery_lv_text, Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2) + 2))
			constants.DIPLOMACY:
				diplomacy_skill_icon_sprite.visible = true
				diplomacy_skill_icon_sprite.position = Vector2(start_x * constants.TILE_WIDTH, start_y * constants.TILE_HEIGHT)
				letters_symbols_node.print_immediately(DIPLOMACY_TEXT, Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2)))
				var diplomacy_lv_text = LVL_TEXT + String(active_unit.skill_levels[constants.DIPLOMACY])
				calc_next = calculate_next_level_percent(constants.DIPLOMACY)
				diplomacy_lv_text += "  " + NEXT_LEVEL_TEXT + String(calc_next) + "%"
				letters_symbols_node.print_immediately(diplomacy_lv_text, Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2) + 2))
				
		start_y += 2
		
	
	
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
	
	# make the selector arrow visible
	if (active_unit.current_items.size() > 0):
		selector_arrow.visible = true
		selector_arrow.position = Vector2((start_x - 1) * constants.DIA_TILE_WIDTH, (start_y + ((current_item - inv_start_index_tracker) * 2)) * constants.DIA_TILE_HEIGHT)
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

# when the unit has selected 'use' in the selection list
func use_item():
	
	# check if the unit has acted
	if (active_unit.has_acted):
		player.hud.dialogueState = player.hud.STATES.INACTIVE
		player.hud.typeTextWithBuffer(CANT_USE_ITEM_ACTING, false, 'finished_viewing_text_generic') 
	
		yield(signals, "finished_viewing_text_generic")
		
		# unpause the node and return
		set_process_input(true)
		
		return
	
	var item = current_item_set[current_item - inv_start_index_tracker]
	var item_used = false
	
	# if the item has a usage ability, add that ability
	if (item.has("use_ability") && !global_ability_list.unit_has_ability(active_unit, item.use_ability.name)):
		# print the used text
		player.hud.dialogueState = player.hud.STATES.INACTIVE
		player.hud.typeTextWithBuffer(active_unit.unit_name + USE_ITEM_TEXT + item.name + ".", false, 'finished_viewing_text_generic') 
	
		yield(signals, "finished_viewing_text_generic")
		
		# additional text that is displayed when the item is used
		if (item.has("use_text")):
			player.hud.dialogueState = player.hud.STATES.INACTIVE
			player.hud.typeTextWithBuffer(active_unit.unit_name + item.use_text, false, 'finished_viewing_text_generic') 
		
			yield(signals, "finished_viewing_text_generic")
		
		# add the ability to the unit
		global_ability_list.add_ability_to_unit(active_unit, item.use_ability)
		
		# break the item, if necessary
		if (item.has("use_breaks") && item.use_breaks):
			global_items_list.item_broke(item, active_unit)
			yield(signals, "finished_viewing_text_generic")
			yield(get_tree().create_timer(.1), "timeout")
			# reposition the cursor and repopulate the list, now that we've removed that item
			if (current_item > (active_unit.current_items.size() - 1)):
				if (current_item == inv_start_index_tracker && inv_start_index_tracker > 0):
					inv_start_index_tracker -= 4
				current_item -= 1
		
			change_screen(inv_start_index_tracker)
			
	elif (item.has("use_ability") && global_ability_list.unit_has_ability(active_unit, item.use_ability.name)):
		# already has that effect
		player.hud.dialogueState = player.hud.STATES.INACTIVE
		player.hud.typeTextWithBuffer(active_unit.unit_name + ALREADY_HAS_EFFECT_TEXT, false, 'finished_viewing_text_generic') 
	
		yield(signals, "finished_viewing_text_generic")
	
	# if the item has "can_place" (i.e. birdhouse)
	elif (item.has("can_place")):
		get_tree().get_current_scene().place_item_in_world(item, active_unit, self)
		# close the unit screen
		return
	# if the item triggers another action
	elif (item.has("triggers_action")):
		# pause this node
		set_process_input(false)
		
		# initiate an action
		global_action_list.do_action(global_action_list.COMPLETE_ACTION_LIST.WRITE_LETTER, active_unit, 
			{
				"item": item,
				"item_index": current_item,
				"unit_info_screen": self
			})
		
		# let the action unpause this node (if needed)
		return
	else:
		pass
	
	# unpause the node
	set_process_input(true)

# when the unit has selected 'info' in the selection list
func show_item_info():
	var item = current_item_set[current_item - inv_start_index_tracker]
	# type the item description
	player.hud.dialogueState = player.hud.STATES.INACTIVE
	player.hud.typeTextWithBuffer(item.description, false, 'finished_viewing_text_generic') 
	
	yield(signals, "finished_viewing_text_generic")
	
	# unpause the node
	set_process_input(true)
	
# when the unit selects 'trash' in the selection list
func trash_item():
	# determine if we can discard this item
	var can_discard = (active_unit.current_items[current_item].has("can_discard") && 
						active_unit.current_items[current_item].can_discard)
	
	# remove the item from the unit
	if (can_discard):
		global_items_list.remove_item_from_unit(active_unit, current_item)
	
	# type the trash item text
	player.hud.dialogueState = player.hud.STATES.INACTIVE
	
	if (can_discard):
		player.hud.typeTextWithBuffer(active_unit.unit_name + TRASH_ITEM_TEXT, false, 'finished_viewing_text_generic') 
	else:
		player.hud.typeTextWithBuffer(CANT_DISCARD_TEXT, false, 'finished_viewing_text_generic') 
	
	yield(signals, "finished_viewing_text_generic")
	
	# reposition the cursor and repopulate the list, now that we've removed that item
	if (can_discard && current_item > (active_unit.current_items.size() - 1)):
		if (current_item == inv_start_index_tracker && inv_start_index_tracker > 0):
			inv_start_index_tracker -= 4
		current_item -= 1

	change_screen(inv_start_index_tracker)

	# unpause the node
	set_process_input(true)
		

# if the item gets removed (do to placing or 'using' in some way)
func remove_item():
	# remove the item from the unit
	global_items_list.remove_item_from_unit(active_unit, current_item)
	
	# type the trash item text
	player.hud.dialogueState = player.hud.STATES.INACTIVE
	
	# reposition the cursor and repopulate the list, now that we've removed that item
	if (current_item > (active_unit.current_items.size() - 1)):
		if (current_item == inv_start_index_tracker && inv_start_index_tracker > 0):
			inv_start_index_tracker -= 4
		current_item -= 1

	change_screen(inv_start_index_tracker)
	
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
		else:
			if (letters_symbols_node.arrow_down_sprite.visible): # if we are allowed to move down
				current_item += direction
				change_screen(inv_end_index_tracker + direction)

# cancel the item select list
func cancel_select_list():
	# unpause this node
	set_process_input(true)

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

func move_skills(direction):
	var start_x = 2
	var start_y = 5
	
	if (direction < 0):
		# move up
		if (current_skill > skill_start_index_tracker):
			current_skill += direction
			selector_arrow.visible = true
			selector_arrow.position = Vector2((start_x - 1) * constants.DIA_TILE_WIDTH, 
				(start_y + ((current_skill - skill_start_index_tracker) * 4)) * constants.DIA_TILE_HEIGHT)
			player.hud.full_text_destruction()
		else:
			if (letters_symbols_node.arrow_up_sprite.visible): # if we are allowed to move up
				current_skill += direction
				skill_start_index_tracker -= 3
				skill_end_index_tracker = skill_start_index_tracker + 2
				change_screen(skill_start_index_tracker)
	else:
		if (current_skill < skill_end_index_tracker):
			current_skill += direction
			selector_arrow.visible = true
			selector_arrow.position = Vector2((start_x - 1) * constants.DIA_TILE_WIDTH, 
				(start_y + ((current_skill - skill_start_index_tracker) * 4)) * constants.DIA_TILE_HEIGHT)
			player.hud.full_text_destruction()
		else:
			if (letters_symbols_node.arrow_down_sprite.visible): # if we are allowed to move down
				current_skill += direction
				change_screen(skill_end_index_tracker + direction)

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
			populate_skill_info_screen(screen_start_index)
		screen_list.ITEMS:
			populate_item_screen(screen_start_index)
		screen_list.ABILITY_INFO:
			populate_ability_screen(screen_start_index)

# a callback that the skill detail uses to tell us to kill it
func kill_skill_detail_screen():
	remove_child(full_skill_detail_screen_node)
	
	# unpause this node
	set_process_input(true)
	

func _ready():
	unit_info_full_init()

# input options for the unfo screen
func _input(event):
	if (event.is_action_pressed("ui_accept")):
		# this is currently only applicable on the skill info screen
		match(current_screen):
			screen_list.SKILL_INFO:
				# pause this node
				set_process_input(false)
				
				# open the skill detail screen
				full_skill_detail_screen_node = full_skill_detail_screen.instance()
				add_child(full_skill_detail_screen_node)
				
				full_skill_detail_screen_node.set_active_skill(all_skills[current_skill])
				full_skill_detail_screen_node.set_current_level(active_unit.skill_levels[all_skills[current_skill]])
				full_skill_detail_screen_node.set_current_skill_icon(all_skill_icons[current_skill].duplicate())
				full_skill_detail_screen_node.populate_screen()
			screen_list.ITEMS:
				# give the unit the option to view 'info' or 'trash'
				if active_unit.current_items.size() > 0:
					var hud_selection_list_node = hud_selection_list_scn.instance()
					add_child(hud_selection_list_node)
					hud_selection_list_node.layer = self.layer + 1
					
					# if this item is 'usable' add that action to the list
					var use_item = []
					var item = current_item_set[current_item - inv_start_index_tracker]
					if (item.has("can_use") && item.can_use):
						use_item.push_front(global_action_list.COMPLETE_ACTION_LIST.USE_ITEM_IN_UNIT_INFO_SCREEN)
					
					hud_selection_list_node.populate_selection_list(use_item + item_actions, self, true, false, true) # can cancel, position to the right
				
					# temporarily stop processing input on this node (pause this node)
					set_process_input(false)
				
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
			screen_list.SKILL_INFO:
				current_skill = 0
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
			screen_list.SKILL_INFO:
				current_skill = 0
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
			screen_list.SKILL_INFO:
				move_skills(1)
		
	if (event.is_action_pressed("ui_up")):
		match (current_screen):
			screen_list.ITEMS:
				move_items(-1)
			screen_list.ABILITY_INFO:
				move_abilities(-1)
			screen_list.SKILL_INFO:
				move_skills(-1)

func close_unit_screen():
	# change the player state
	player.player_state = player.PLAYER_STATE.SELECTING_TILE
	
	# turn the music back up
	get_tree().get_current_scene().heighten_background_music()
	
	# kill ourself :(
	get_parent().remove_child(self)

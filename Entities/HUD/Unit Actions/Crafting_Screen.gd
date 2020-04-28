extends CanvasLayer

# screen that gets displayed when a unit 'crafts' 

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in the global player variables
onready var player = get_node("/root/Player_Globals")

# bring in our global action list
onready var global_action_list = get_node("/root/Actions")

# bring in our items
onready var global_items_list = get_node("/root/Items")

# bring in our skill information
onready var skill_info = get_node("/root/Skill_Info")

# bring in our guild variables/functions
onready var guild = get_node("/root/Guild")

# bring in our signals
onready var signals = get_node("/root/Signal_Manager")

# preaload the letters + symbols
onready var letters_symbols_scn = preload("res://Entities/HUD/Letters_Symbols/Letters_Symbols.tscn")
var letters_symbols_node

# various hud scenes
onready var hud_selection_list_scn = preload("res://Entities/HUD/Selection_List.tscn")

# our skill selection background sprite
onready var skill_selection_background_sprite = get_node("Skill_Selection_Screen")

# our recipe selection background sprite
onready var recipe_selection_background_sprite = get_node("Recipe_Selection_Screen")

# our skill icon sprites
onready var woodworking_skill_icon_sprite = get_node("Woodworking_Skill_Icon")

# keep an extra arrow to act as a selector
var selector_arrow

# keep track of the active unit
var active_unit

# keep track of the active skill that the unit is performing
var active_skill

# keep track of the currently selected skill in the the user can choose for crafting
onready var all_skills = [
	constants.WOODWORKING
]
var current_skill_set = []
var current_skill = 0
var skill_start_index_tracker = 0
var skill_end_index_tracker = 0

# keep track of the currently selected recipe the user can choose from (associated with a skill)
var all_recipes = []
var current_recipe_set = []
var current_recipe = 0
var recipe_start_index_tracker = 0
var recipe_end_index_tracker

# text for the crafting screen
const CRAFT_TEXT = 'Craft'
const WOODWORKING_TEXT = "Woodworking"

const RECIPES_TEXT = ' Recipes'
const NO_RECIPES_TEXT = 'No recipes...'
const LVL_REQUIRED_TEXT = 'Lv.'
const TOOL_TEXT = 'Tool'
const DOES_NOT_HAVE_LEVEL_TEXT = ' does not have the required skill level to craft that...'
const DOES_NOT_HAVE_ITEMS_TEXT = ' does not have the required items to craft that...'
const CAN_CRAFT_TEXT = ' can craft this!'
const CRAFT_THIS_ITEM_TEXT = 'Craft this item?'
const CANT_CARRY_ANYTHING_ELSE_TEXT = ' can\'t carry anything else...'

enum SCREENS {
	SKILL_SELECTION,
	RECIPE_SELECTION,
	CONFIRMATION
}

onready var recipe_actions = [
	global_action_list.COMPLETE_ACTION_LIST.CRAFT_RECIPE_IN_CRAFTING_SCREEN,
	global_action_list.COMPLETE_ACTION_LIST.VIEW_ITEM_INFO_IN_CRAFTING_SCREEN
]

# keep track of the screen we are actively looking at
var active_screen = SCREENS.SKILL_SELECTION

func crafting_screen_init():
	letters_symbols_node = letters_symbols_scn.instance()
	add_child(letters_symbols_node)
	
	# add an extra right arrow symbol to act as a selector
	selector_arrow = letters_symbols_node.arrow_right_sprite.duplicate()
	add_child(selector_arrow)
	
	selector_arrow.visible = false
	selector_arrow.position = Vector2(1 * constants.DIA_TILE_WIDTH, 1 * constants.DIA_TILE_HEIGHT)
	
	
	# make sure the letters sit on top
	letters_symbols_node.layer = self.layer + 1
	
	# dampen the background music while we are viewing the unit's information
	get_tree().get_current_scene().dampen_background_music()

func _on_confirm_craft(crafting, recipe = null, item_indexes = []):
	# unpause the node
	set_process_input(true)
	
	# disconnect the unused signal
	if (crafting):
		signals.disconnect("confirm_generic_no", self, "_on_confirm_craft")
	else:
		signals.disconnect("confirm_generic_yes", self, "_on_confirm_craft")
	
	if (crafting):
		# first, remove the items from the player
		item_indexes.invert() # invert, as we will be removing items as we iterate and want to prevent errors
		for index in item_indexes:
			global_items_list.remove_item_from_unit(active_unit, index)
			
		# wrap things up up in our global action
		global_action_list.finished_crafting_selection(active_skill, recipe.item, active_unit)
		
	else:	
		# go back to the previous screen
		cancel_screen()

func set_active_unit(unit):
	active_unit = unit
	
	# populate the skill selection screen
	populate_skill_selection_screen()

# useful functioning for quickly calculating the next level experience percentage
func calculate_next_level_percent(skill):
	return floor(active_unit.skill_xp[skill] / float(constants.experience_required[active_unit.skill_levels[skill]]) * 100.0)

func populate_skill_selection_screen(skill_start_index = 0):	
	skill_start_index_tracker = skill_start_index
	
	# make the skill selection background sprite visible
	skill_selection_background_sprite.visible = true
	
	skill_end_index_tracker = skill_start_index_tracker + 2 # show 3 skills at a time
	if (skill_end_index_tracker > all_skills.size() - 1): # account for index
		skill_end_index_tracker = all_skills.size() - 1	

	woodworking_skill_icon_sprite.visible = false
	
	# skills text
	letters_symbols_node.print_immediately(CRAFT_TEXT, Vector2((constants.DIA_TILES_PER_ROW - len(CRAFT_TEXT)) / 2, 1))
	
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
			constants.WOODWORKING:
				woodworking_skill_icon_sprite.visible = true
				woodworking_skill_icon_sprite.position = Vector2(start_x * constants.TILE_WIDTH, start_y * constants.TILE_HEIGHT)
				letters_symbols_node.print_immediately(WOODWORKING_TEXT, Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2)))
				var woodworking_lv_text = constants.LVL_TEXT + String(active_unit.skill_levels[constants.WOODWORKING])
				calc_next = calculate_next_level_percent(constants.WOODWORKING)
				woodworking_lv_text += "  " + constants.NEXT_LEVEL_TEXT + String(calc_next) + "%"
				letters_symbols_node.print_immediately(woodworking_lv_text, Vector2(((start_x + 1 ) * 2) + 1, (start_y * 2) + 2))
				
		start_y += 2

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
				change_screens(SCREENS.SKILL_SELECTION, skill_start_index_tracker)
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
				change_screens(SCREENS.SKILL_SELECTION, skill_end_index_tracker + direction)

func move_recipes(direction):
	var start_x = 2
	var start_y = 3
	
	if (direction < 0):
		# move up
		if (current_recipe > recipe_start_index_tracker):
			current_recipe += direction
			selector_arrow.visible = true
			selector_arrow.position = Vector2((start_x - 1) * constants.DIA_TILE_WIDTH, 
				(start_y + ((current_recipe - recipe_start_index_tracker) * 2)) * constants.DIA_TILE_HEIGHT)
			player.hud.full_text_destruction()
		else:
			if (letters_symbols_node.arrow_up_sprite.visible): # if we are allowed to move up
				current_recipe += direction
				recipe_start_index_tracker -= 4
				recipe_end_index_tracker = recipe_start_index_tracker + 3
				change_screens(SCREENS.RECIPE_SELECTION, recipe_start_index_tracker)
	else:
		if (current_recipe < recipe_end_index_tracker):
			current_recipe += direction
			selector_arrow.visible = true
			selector_arrow.position = Vector2((start_x - 1) * constants.DIA_TILE_WIDTH, 
				(start_y + ((current_recipe - recipe_start_index_tracker) * 2)) * constants.DIA_TILE_HEIGHT)
			player.hud.full_text_destruction()
		else:
			if (letters_symbols_node.arrow_down_sprite.visible): # if we are allowed to move down
				current_recipe += direction
				change_screens(SCREENS.RECIPE_SELECTION, recipe_end_index_tracker + direction)

# function for showing info about the item this recipe produces
func view_item_info():
	var item = all_recipes[current_recipe].item
	
	# type the item info
	player.hud.dialogueState = player.hud.STATES.INACTIVE
	player.hud.typeTextWithBuffer(item.description, false, 'finished_viewing_text_generic') 
	
	yield(signals, "finished_viewing_text_generic")
	
	# unpause the node
	set_process_input(true)

func close_crafting_screen():
	# change the player state
	player.player_state = player.PLAYER_STATE.SELECTING_TILE
	
	# turn the music back up
	get_tree().get_current_scene().heighten_background_music()
	
	# kill ourself :(
	get_parent().remove_child(self)

func make_background_sprites_invisible():
	skill_selection_background_sprite.visible = false
	recipe_selection_background_sprite.visible = false
	
	woodworking_skill_icon_sprite.visible = false
	
	selector_arrow.visible = false

func determine_recipes():
	all_recipes = []
	
	var recipes = skill_info.SKILL_UNLOCKS[active_skill]
	
	for recipe in recipes:
		if (recipe.type == skill_info.UNLOCK_TYPES.RECIPE):
			all_recipes.append(recipe)
			
func populate_recipe_confirmation_screen():
	# reuse the recipe background sprite visible
	recipe_selection_background_sprite.visible = true
	
	# get all of the item information
	var recipe = all_recipes[current_recipe]
	
	# print the name of the recipe
	letters_symbols_node.print_immediately(recipe.item.name, Vector2((constants.DIA_TILES_PER_ROW - len(recipe.item.name)) / 2, 1))
	
	# keep track of all of the items that the unit must expend to craft this item
	var item_indexes = []
	
	# and the total quantity of items required to craft this item
	var total_items_required = 0
	
	# a flag to keep track of whether or not the user has the required materials to craft this item
	var unit_has_items = true
	
	var start_y = 3
	# print the required ingredients
	for ingredient in recipe.resources_required:
		var name = ingredient.item.name + " x" + String(ingredient.quantity)
		# increase the total items required
		total_items_required += ingredient.quantity
		
		var symbol = ''
		# determine if the unit has this item
		
		var has_item_array = global_items_list.unit_has_item(active_unit, ingredient.item, ingredient.quantity)
		if (has_item_array.size() > 0):
			item_indexes += has_item_array
			symbol = constants.CHECK_SYMBOL
		else:
			# the user does not have this item
			symbol = constants.X_SYMBOL
			unit_has_items = false
			
		
		letters_symbols_node.print_immediately(name + ' ' + symbol, Vector2(1, start_y))
		start_y += 1
		
	# determine the tool type
	var tool_type
	match(active_skill):
		constants.WOODWORKING:
			tool_type = global_items_list.ITEM_TYPES.SAW
	
	var has_tool = (global_items_list.unit_has_tool(active_unit, tool_type) >= 0)
	
	# show the tool text
	if (!recipe.has('no_tool_required')):
		var symbol = ''
		if (has_tool):
			symbol = constants.CHECK_SYMBOL
		else:
			symbol = constants.X_SYMBOL
			unit_has_items = false # the unit can't craft
		
		letters_symbols_node.print_immediately(TOOL_TEXT + ' ' + symbol, Vector2(1, 10))
	
	# show the level required text
	letters_symbols_node.print_immediately(LVL_REQUIRED_TEXT + String(recipe.level_required), 
					Vector2(14, 10))
	
	# show the corresponding skill icon
	match (active_skill):
		constants.WOODWORKING:
			woodworking_skill_icon_sprite.visible = true
			woodworking_skill_icon_sprite.position = Vector2(constants.DIA_TILE_WIDTH * 11, 9 * constants.DIA_TILE_HEIGHT)

	# if the unit doesn't have the required skill level, type a message
	if (recipe.level_required > active_unit.skill_levels[active_skill]):
		player.hud.dialogueState = player.hud.STATES.INACTIVE
		player.hud.typeTextWithBuffer(active_unit.unit_name + DOES_NOT_HAVE_LEVEL_TEXT, true)
	elif (!unit_has_items):
		# the unit does not have the required items
		player.hud.dialogueState = player.hud.STATES.INACTIVE
		player.hud.typeTextWithBuffer(active_unit.unit_name + DOES_NOT_HAVE_ITEMS_TEXT, true)
	elif (active_unit.is_inventory_full(total_items_required)):
		# tell the player that the unit's inventory is full
		player.hud.dialogueState = player.hud.STATES.INACTIVE
		player.hud.typeTextWithBuffer(active_unit.unit_name + CANT_CARRY_ANYTHING_ELSE_TEXT, true)
	else:
		# otherwise, the unit can craft the item!
		player.hud.dialogueState = player.hud.STATES.INACTIVE
		player.hud.typeTextWithBuffer(active_unit.unit_name + CAN_CRAFT_TEXT, false, 'finished_viewing_text_generic')
		
		# pause the node (no cancelling while we are yielding to a signal)
		
		set_process_input(false)
		
		yield(signals, "finished_viewing_text_generic")
		
		var hud_selection_list_node = hud_selection_list_scn.instance()
		add_child(hud_selection_list_node)
		hud_selection_list_node.layer = layer + 1
		
		# connect signals for confirming whether or not to craft an item
		signals.connect("confirm_generic_yes", self, "_on_confirm_craft", [true, recipe, item_indexes], CONNECT_ONESHOT)
		signals.connect("confirm_generic_no", self, "_on_confirm_craft", [false], CONNECT_ONESHOT)
		
		# populate the selection list with a yes/no confirmation
		hud_selection_list_node.populate_selection_list([], self, true, false, true, false, true, CRAFT_THIS_ITEM_TEXT, 
														'confirm_generic_yes', 'confirm_generic_no')
		

func populate_recipe_selection_screen(recipe_start_index = 0):	
	# make the recipe background sprite visible
	recipe_selection_background_sprite.visible = true
	
	# determine the list of recipes associated with the skill
	determine_recipes()
	
	recipe_start_index_tracker = recipe_start_index
	
	# make the recipe selection background sprite visible
	recipe_selection_background_sprite.visible = true
	
	recipe_end_index_tracker = recipe_start_index_tracker + 3 # show 4 recipes at a time
	if (recipe_end_index_tracker > all_recipes.size() - 1): # account for index
		recipe_end_index_tracker = all_recipes.size() - 1	
	
	# show the corresponding skill icon
	match (active_skill):
		constants.WOODWORKING:
			woodworking_skill_icon_sprite.visible = true
			woodworking_skill_icon_sprite.position = Vector2((constants.DIA_TILES_PER_COL - 2) * constants.DIA_TILE_WIDTH, 1 * constants.DIA_TILE_HEIGHT)
	
	# recipe text
	letters_symbols_node.print_immediately(RECIPES_TEXT, Vector2((constants.DIA_TILES_PER_ROW - len(RECIPES_TEXT)) / 2 - 1, 1))
	
	current_recipe_set = all_recipes.slice(recipe_start_index_tracker, recipe_end_index_tracker, 1) # only show 4 recipes at a time
	
	var start_x = 2
	var start_y = 3
	
	# make the selector arrow visible
	if (all_recipes.size() > 0):
		selector_arrow.visible = true
		selector_arrow.position = Vector2((start_x - 1) * constants.DIA_TILE_WIDTH, (start_y + ((current_recipe - recipe_start_index_tracker) * 2)) * constants.DIA_TILE_HEIGHT)
	else:
		player.hud.dialogueState = player.hud.STATES.INACTIVE
		player.hud.typeText(NO_RECIPES_TEXT, true)

	# print the down / up arrow, depending on where we are in the list of recipes
	if (current_recipe_set.size() >= 4 && (recipe_start_index_tracker + 3) < all_recipes.size() - 1): # account for index
		letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.DOWN_ARROW, 
			Vector2(((constants.DIA_TILES_PER_ROW - 1) / 2) * constants.DIA_TILE_WIDTH, 10 * constants.DIA_TILE_HEIGHT))
			
	if (recipe_start_index_tracker > 0):
		letters_symbols_node.print_special_immediately(constants.SPECIAL_SYMBOLS.UP_ARROW, 
			Vector2(((constants.DIA_TILES_PER_ROW - 1) / 2) * constants.DIA_TILE_WIDTH, 2 * constants.DIA_TILE_HEIGHT))
	
	for recipe in current_recipe_set:
		letters_symbols_node.print_immediately(recipe.item.name, Vector2(start_x, start_y))
		start_y += 2
	
func change_screens(screen, screen_start_index = 0):
	active_screen = screen

	# clear any letters / symbols
	letters_symbols_node.clearText()
	letters_symbols_node.clear_specials()
	
	# make all background sprites invisible
	make_background_sprites_invisible()
	
	# make sure the node is unpaused
	set_process_input(true)
	
	# behave differently based on the screen we are switching to
	match(active_screen):
		SCREENS.RECIPE_SELECTION:
			populate_recipe_selection_screen(screen_start_index)
		SCREENS.SKILL_SELECTION:
			populate_skill_selection_screen(screen_start_index)
		SCREENS.CONFIRMATION:
			populate_recipe_confirmation_screen()
			
func cancel_select_list():
	# start processing input again (unpause this node)
	set_process_input(true)

func _ready():
	crafting_screen_init()
	
func cancel_screen():
	# reset certain tracking variables
	match(active_screen):
		SCREENS.SKILL_SELECTION:
			close_crafting_screen()
			# make sure we close the dialogue box as well, if it's present
			player.hud.full_text_destruction()
		SCREENS.RECIPE_SELECTION:
			# make sure we close the dialogue box, if it's present
			player.hud.full_text_destruction()
			current_recipe = 0 # reset recipe variables
			change_screens(SCREENS.SKILL_SELECTION)
		SCREENS.CONFIRMATION:
			# make sure we close the dialogue box, if it's present
			player.hud.full_text_destruction()
			change_screens(SCREENS.RECIPE_SELECTION, recipe_start_index_tracker)
	
# input options for the crafting screen
func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		cancel_screen()	
	if (event.is_action_pressed("ui_down")):
		match(active_screen):
			SCREENS.SKILL_SELECTION:
				move_skills(1)
			SCREENS.RECIPE_SELECTION:
				move_recipes(1)
	if (event.is_action_pressed("ui_up")):
		match(active_screen):
			SCREENS.SKILL_SELECTION:
				move_skills(-1)
			SCREENS.RECIPE_SELECTION:
				move_recipes(-1)
	if (event.is_action_pressed("ui_accept")):		
		# behave differently based on the active screen
		match (active_screen):
			SCREENS.SKILL_SELECTION:
				# set the active skill
				active_skill = all_skills[current_skill]
				
				# move to the recipe list screen
				change_screens(SCREENS.RECIPE_SELECTION)
			SCREENS.RECIPE_SELECTION:
				# populate a select list to 'CRAFT' or view item 'INFO'
				if all_recipes.size() > 0:
					var hud_selection_list_node = hud_selection_list_scn.instance()
					add_child(hud_selection_list_node)
					hud_selection_list_node.layer = self.layer + 1
					hud_selection_list_node.populate_selection_list(recipe_actions, self, true, false, true) # can cancel, position to the right
					
					# temporarily stop processing input on this node (pause this node)
					set_process_input(false)

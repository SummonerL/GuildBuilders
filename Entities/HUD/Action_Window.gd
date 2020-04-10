extends CanvasLayer

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in the global player variables
onready var player = get_node("/root/Player_Globals")

# the letters and symbol scene
onready var letters_symbols_obj = preload("res://Entities/HUD/Letters_Symbols/Letters_Symbols.tscn")
var letters_symbols_node

# the action window sprite
onready var window_sprite = get_node("Action_Window_Sprite")

# the skill icon sprites
onready var mining_icon_sprite = get_node("Mining_Skill_Icon")
onready var woodcutting_icon_sprite = get_node("Woodcutting_Skill_Icon")
onready var fishing_icon_sprite = get_node("Fishing_Skill_Icon")

# the xp gain sound
onready var xp_gain_sound = get_node("XP_Gain_Sound")

# the level up fanfare
onready var level_up_fanfare = get_node("Level_Up_Fanfare")

# the item received sound
onready var item_get_sound = get_node("Item_Get_Sound")

# constants
const GOT_TEXT = 'Got'
const EXCLAMATION = '!'
const NEXT_LEVEL_TEXT = "Nxt."
const LVL_TEXT = "Lv."

const XP_GAINED_SPEED = .1

const WINDOW_WIDTH = 8
const WINDOW_HEIGHT = 4

const WINDOW_WIDTH_IN_DIA = 16
const WINDOW_HEIGHT_IN_DIA = 8

var pos_x
var pos_y

func window_init():	
	# middle	
	pos_x = ((constants.DIA_TILES_PER_ROW * constants.DIA_TILE_WIDTH) / 2 ) - (WINDOW_WIDTH * constants.DIA_TILE_WIDTH)
	pos_y = 4 * constants.DIA_TILE_WIDTH
	window_sprite.position = Vector2(pos_x, pos_y)

	letters_symbols_node = letters_symbols_obj.instance()
	add_child(letters_symbols_node)
	
	# set icon positions
	mining_icon_sprite.position.x = pos_x + constants.DIA_TILE_WIDTH
	mining_icon_sprite.position.y = pos_y + constants.DIA_TILE_HEIGHT
	
	woodcutting_icon_sprite.position.x = pos_x + constants.DIA_TILE_WIDTH
	woodcutting_icon_sprite.position.y = pos_y + constants.DIA_TILE_HEIGHT
	
	fishing_icon_sprite.position.x = pos_x + constants.DIA_TILE_WIDTH
	fishing_icon_sprite.position.y = pos_y + constants.DIA_TILE_HEIGHT

# useful functioning for quickly calculating the next level experience percentage
func calculate_next_level_percent(xp, level_before):
	return floor(xp / float(constants.experience_required[level_before]) * 100)

func set_skill(skill):
	var pretty_name = ''
	
	match(skill):
		constants.FISHING:
			pretty_name = constants.FISHING_PRETTY
			
			letters_symbols_node.print_immediately(pretty_name, Vector2((WINDOW_WIDTH + 2) - floor(len(pretty_name) / 2.0),
				(pos_y / constants.DIA_TILE_HEIGHT) + 1))
				
			fishing_icon_sprite.visible = true
		constants.WOODCUTTING:
			pretty_name = constants.WOODCUTTING_PRETTY
			
			letters_symbols_node.print_immediately(pretty_name, Vector2((WINDOW_WIDTH + 3) - floor(len(pretty_name) / 2.0),
				(pos_y / constants.DIA_TILE_HEIGHT) + 1))
				
			woodcutting_icon_sprite.visible = true

func receive_item(item):
	var receive_text = item.name + EXCLAMATION

	letters_symbols_node.print_immediately(GOT_TEXT, Vector2((WINDOW_WIDTH + 2) - floor(len(GOT_TEXT) / 2.0),
		(pos_y / constants.DIA_TILE_HEIGHT) + 3))


	letters_symbols_node.print_immediately(receive_text, Vector2((WINDOW_WIDTH + 2) - floor(len(receive_text) / 2.0),
		(pos_y / constants.DIA_TILE_HEIGHT) + 4))
		
	# play the item get sound
	item_get_sound.play()
		
	
func show_xp_reward(unit, reward, skill, level_before, level_after, xp_after, xp_before, parent, timer = null):
	
	if (timer):
		timer.stop()
		remove_child(timer)

	var calc_next_lv_before = calculate_next_level_percent(xp_before, level_before)
	var calc_next_lv_after = calculate_next_level_percent(xp_after, level_before)
	
	if (level_after > level_before): # the unit leveled up!
		calc_next_lv_after = 100
		
	var current_wait_time = XP_GAINED_SPEED
	for percent in range(calc_next_lv_before, calc_next_lv_after +1):
		var level_up = false
		if (percent == 100):
			level_up = true
			
		var print_timer = Timer.new()
		print_timer.wait_time = current_wait_time
		print_timer.connect("timeout", self, "print_lvl_xp", [level_before, percent, level_up, print_timer])
		add_child(print_timer)
		print_timer.start()
		current_wait_time += XP_GAINED_SPEED #+ (percent / 200.0)   -- Maybe slow down as we approach 100% (mob psycho)
		
		# if the player leveled up. retrigger this function to show more xp at the next level
		if (level_up):
			var show_more_timer = Timer.new()
			show_more_timer.wait_time = current_wait_time + 3 # account for level up fanfare
			show_more_timer.connect("timeout", self, "show_xp_reward", [unit, reward, skill, level_before + 1, level_after, xp_after, 0, parent, show_more_timer])
			add_child(show_more_timer)
			show_more_timer.start()
			return
		
	# after showing the xp, call back to the parent to indicate we've finished with the action screen
	var finished_timer = Timer.new()
	finished_timer.wait_time = current_wait_time
	finished_timer.connect("timeout", self, "action_window_finished", [parent, skill, reward, finished_timer])
	add_child(finished_timer)
	finished_timer.start()

func print_lvl_xp(level, percent, level_up = false, timer = null):
	if timer:
		timer.stop()
		remove_child(timer)
		
	var lv_text = LVL_TEXT + String(level)
	lv_text += "  " + NEXT_LEVEL_TEXT + String(percent) + "%  "
	letters_symbols_node.print_immediately(lv_text, Vector2((pos_x / constants.DIA_TILE_WIDTH) + 1, 
		(pos_y / constants.DIA_TILE_HEIGHT) + 6))
		
	# play the xp gain sound
	xp_gain_sound.play()
	
	if (level_up): # congrats!
		var sound_timer = Timer.new()
		sound_timer.wait_time = 1
		sound_timer.connect("timeout", self, "play_level_up_sound", [sound_timer])
		add_child(sound_timer)
		sound_timer.start()

func play_level_up_sound(timer = null):
	if (timer):
		timer.stop()
		remove_child(timer)

	level_up_fanfare.play()
	

func action_window_finished(parent, skill, reward, timer = null):
	if (timer):
		timer.stop()
		remove_child(timer)
	
	parent.action_window_finished(skill, reward)

func _ready():
	window_init()

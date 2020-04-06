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

# constants
const GOT_TEXT = 'Got'
const EXCLAMATION = '!'
const NEXT_LEVEL_TEXT = "Nxt."
const LVL_TEXT = "Lv."

const XP_GAINED_SPEED = .1

const WINDOW_WIDTH = 8
const window_HEIGHT = 4

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
func calculate_next_level_percent(xp, level_before, skill):
	return stepify(xp / float(constants.experience_required[level_before]) * 100, 1)

func set_skill(skill):
	var pretty_name = ''
	var window_end_x = pos_x + window_sprite.texture.get_width()
	
	var window_start_y = window_sprite.position.y
	
	match(skill):
		constants.FISHING:
			pretty_name = constants.FISHING_PRETTY
			
			letters_symbols_node.print_immediately(pretty_name, Vector2(window_end_x / constants.DIA_TILE_WIDTH / 2 - (len(pretty_name) / 2), 
				(pos_y / constants.DIA_TILE_HEIGHT) + 1))
				
			fishing_icon_sprite.visible = true

func receive_item(item):
	var receive_text = item.name + EXCLAMATION
	var window_end_x = pos_x + window_sprite.texture.get_width()

	letters_symbols_node.print_immediately(GOT_TEXT, Vector2((window_end_x / constants.DIA_TILE_WIDTH) / 2 - (len(GOT_TEXT) / 2),
		(pos_y / constants.DIA_TILE_HEIGHT) + 3))

	letters_symbols_node.print_immediately(receive_text, Vector2((window_end_x / constants.DIA_TILE_WIDTH) / 2 - (len(receive_text) / 2),
		(pos_y / constants.DIA_TILE_HEIGHT) + 4))
		
	
func show_xp_reward(unit, reward, skill, level_before, xp_after, xp_before):

	var calc_next_lv_before = calculate_next_level_percent(xp_before, level_before, constants.FISHING)
	var calc_next_lv_after = calculate_next_level_percent(xp_after, level_before, constants.FISHING)
		
	var current_wait_time = XP_GAINED_SPEED
	for percent in range(calc_next_lv_before, calc_next_lv_after):
		var timer = Timer.new()
		timer.wait_time = current_wait_time
		timer.connect("timeout", self, "print_lvl_xp", [level_before, percent, timer])
		add_child(timer)
		timer.start()
		current_wait_time += XP_GAINED_SPEED

func print_lvl_xp(level, percent, timer = null):
	if timer:
		timer.stop()
		remove_child(timer)
		
	var lv_text = LVL_TEXT + String(level)
	lv_text += "  " + NEXT_LEVEL_TEXT + String(percent) + "%"
	letters_symbols_node.print_immediately(lv_text, Vector2((pos_x / constants.DIA_TILE_WIDTH) + 1, 
		(pos_y / constants.DIA_TILE_HEIGHT) + 6))
		
	# play the xp gain sound
	xp_gain_sound.play()

func _ready():
	window_init()

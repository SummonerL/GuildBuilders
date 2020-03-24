extends CanvasLayer

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in our game config vars
onready var game_cfg_vars = get_node("/root/Game_Config")

# local constants
const DIA_TILE_WIDTH = 8
const DIA_TILE_HEIGHT = 8
const DIALOGUE_HEIGHT = 48
const DIALOGUE_WIDTH = 160

onready var tile_map = get_node("TileMap")
onready var arrow_down_sprite = get_node("Arrow_Down_Sprite")
onready var arrow_right_sprite = get_node("Arrow_Right_Sprite")
onready var dialogue_sound = get_node("Dialogue_Sound")

var tileSet
var currentTime = 0

func stopTimer(timer):
	timer.stop()
	remove_child(timer)
	
func timeoutTimer(timer): # trigger the timeout early
	timer.start(.0001)
	

func setTextCell(letterSymbol, pos, timer = null, sound = true):
	tile_map.set_cellv(pos, tileSet.find_tile_by_name("LS_Code_" + String(letterSymbol.ord_at(0))))
	
	# if there is a timer, stop it
	if (timer):
		stopTimer(timer)
	
	# play the dialogue sound
	if (sound):
		dialogue_sound.play()
	
func letters_symbols_init():
	tileSet = tile_map.get_tileset()
	
	# position arrow down sprite
	arrow_down_sprite.position = Vector2(constants.SCREEN_WIDTH - (DIA_TILE_WIDTH*3), constants.SCREEN_HEIGHT - (DIA_TILE_HEIGHT*2))
	
func startArrowDownTimer():
	var downArrowTimer = Timer.new()
	downArrowTimer.wait_time = currentTime
	downArrowTimer.connect("timeout", self, "showArrowDown", [downArrowTimer])
	add_child(downArrowTimer)
	downArrowTimer.start()
	
func showArrowDown(downArrowTimer):
	arrow_down_sprite.visible = true
	stopTimer(downArrowTimer) # stop and remove timer
	
func hideArrowDown():
	arrow_down_sprite.visible = false
	
func clearText():
	tile_map.clear()
	hideArrowDown()
	currentTime = 0
	
func clear_text_non_dialogue():
	tile_map.clear()
	
func clear_specials():
	arrow_down_sprite.visible = false
	arrow_right_sprite.visible = false
	
func generateLetterSymbol(letterSymbol, pos):
	# generate text, using a timer
	var textTimer = Timer.new()
	textTimer.wait_time = currentTime + game_cfg_vars.messageSpeed
	currentTime = currentTime + game_cfg_vars.messageSpeed
	
	textTimer.connect("timeout", self, "setTextCell", [letterSymbol, pos, textTimer])
	add_child(textTimer)
	
	textTimer.start()

func print_immediately(text, start_pos):
	for letter in text:
		setTextCell(letter, start_pos, null, false)
		start_pos.x += 1
	pass
	
func print_special_immediately(special_symbol, pos):
	match(special_symbol):
		constants.SPECIAL_SYMBOLS.RIGHT_ARROW:
			arrow_right_sprite.position = pos
			arrow_right_sprite.visible = true
			

# Called when the node enters the scene tree for the first time.
func _ready():
	letters_symbols_init()

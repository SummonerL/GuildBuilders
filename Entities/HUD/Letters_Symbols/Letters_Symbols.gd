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

onready var tileMap = get_node("TileMap")
onready var arrowDownSprite = get_node("Arrow_Down_Sprite")
onready var dialogueSound = get_node("Dialogue_Sound")

var tileSet
var currentTime = 0

func stopTimer(timer):
	timer.stop()
	remove_child(timer)
	
func timeoutTimer(timer): # trigger the timeout early
	timer.start(.0001)
	

func setTextCell(letterSymbol, pos, timer):
	tileMap.set_cellv(pos, tileSet.find_tile_by_name("LS_Code_" + String(letterSymbol.ord_at(0))))
	stopTimer(timer) # stop + remove the timer
	
	#play the dialogue sound
	dialogueSound.play()
	
func letters_symbols_init():
	tileSet = tileMap.get_tileset()
	
	# position arrow down sprite
	arrowDownSprite.position = Vector2(constants.SCREEN_WIDTH - (DIA_TILE_WIDTH*3), constants.SCREEN_HEIGHT - (DIA_TILE_HEIGHT*2))
	
func startArrowDownTimer():
	var downArrowTimer = Timer.new()
	downArrowTimer.wait_time = currentTime
	downArrowTimer.connect("timeout", self, "showArrowDown", [downArrowTimer])
	add_child(downArrowTimer)
	downArrowTimer.start()
	
func showArrowDown(downArrowTimer):
	arrowDownSprite.visible = true
	stopTimer(downArrowTimer) # stop and remove timer
	
func hideArrowDown():
	arrowDownSprite.visible = false
	
func clearText():
	tileMap.clear()
	hideArrowDown()
	currentTime = 0
	
func generateLetterSymbol(letterSymbol, pos):
	# generate text, using a timer
	var textTimer = Timer.new()
	textTimer.wait_time = currentTime + game_cfg_vars.messageSpeed
	currentTime = currentTime + game_cfg_vars.messageSpeed
	
	textTimer.connect("timeout", self, "setTextCell", [letterSymbol, pos, textTimer])
	add_child(textTimer)
	
	textTimer.start()

# Called when the node enters the scene tree for the first time.
func _ready():
	letters_symbols_init()

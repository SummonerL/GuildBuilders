extends CanvasLayer

const MESSAGE_SPEED = .05
const SCREEN_HEIGHT = 144
const SCREEN_WIDTH = 160
const TILE_HEIGHT = 16
const TILE_WIDTH = 16
const DIA_TILE_WIDTH = 8
const DIA_TILE_HEIGHT = 8
const DIALOGUE_HEIGHT = 48
const DIALOGUE_WIDTH = 160

onready var tileMap = get_node("TileMap")
onready var arrowDownSprite = get_node("Arrow_Down_Sprite")
onready var dialogueSound = get_node("Dialogue_Sound")

var tileSet
var currentTime = 0

func setTextCell(letterSymbol, pos, timer, last):
	print(letterSymbol.ord_at(0))
	tileMap.set_cellv(pos, tileSet.find_tile_by_name("LS_Code_" + String(letterSymbol.ord_at(0))))
	timer.stop() # stop the timer
	
	#play the dialogue sound
	dialogueSound.play()
	
	# if last, make our down arrow visible
	if (last):
		showArrowDown()
	
func letters_symbols_init():
	tileSet = tileMap.get_tileset()
	
	# position arrow down sprite
	arrowDownSprite.position = Vector2(SCREEN_WIDTH - (DIA_TILE_WIDTH*3), SCREEN_HEIGHT - (DIA_TILE_HEIGHT*2))
	
func showArrowDown():
	arrowDownSprite.visible = true
	
func hideArrowDown():
	arrowDownSprite.visible = false
func generateLetterSymbol(letterSymbol, pos, last):
	# generate text, using a timer
	var textTimer = Timer.new()
	textTimer.wait_time = currentTime + MESSAGE_SPEED
	currentTime = currentTime + MESSAGE_SPEED
	
	textTimer.connect("timeout", self, "setTextCell", [letterSymbol, pos, textTimer, last])
	add_child(textTimer)
	
	textTimer.start()

# Called when the node enters the scene tree for the first time.
func _ready():
	letters_symbols_init()

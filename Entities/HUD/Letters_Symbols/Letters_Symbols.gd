extends CanvasLayer

const MESSAGE_SPEED = .05

onready var tileMap = get_node("TileMap")
var tileSet
var currentTime = 0

func setTextCell(letterSymbol, pos):
	tileMap.set_cellv(pos, tileSet.find_tile_by_name(letterSymbol))
	
func letters_symbols_init():
	tileSet = tileMap.get_tileset()
	
func generateLetterSymbol(letterSymbol, pos):
	# generate text, using a timer
	var textTimer = Timer.new()
	textTimer.wait_time = currentTime + MESSAGE_SPEED
	currentTime = currentTime + MESSAGE_SPEED
	
	textTimer.connect("timeout", self, "setTextCell", [letterSymbol, pos])
	add_child(textTimer)
	
	textTimer.start()

# Called when the node enters the scene tree for the first time.
func _ready():
	letters_symbols_init()

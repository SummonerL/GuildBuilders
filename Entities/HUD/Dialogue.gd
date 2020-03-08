extends CanvasLayer

const SCREEN_HEIGHT = 144
const SCREEN_WIDTH = 160
const TILE_HEIGHT = 16
const TILE_WIDTH = 16
const DIA_TILE_WIDTH = 8
const DIA_TILE_HEIGHT = 8
const DIALOGUE_HEIGHT = 48
const DIALOGUE_WIDTH = 160

onready var letters_symbols_obj = preload("res://Entities/HUD/Letters_Symbols/Letters_Symbols.tscn")
onready var dialogue_sprite = get_node("Dialogue_Sprite")

var letters_symbols


func dialogue_init():
	# position the dialogue box to the bottom of the viewport
	dialogue_sprite.position = Vector2(0, SCREEN_HEIGHT - DIALOGUE_HEIGHT)
	
	# add the Tilemap as a child of dialogue
	letters_symbols = letters_symbols_obj.instance()
	add_child(letters_symbols)
	
	writeText("Sound is workingHow is it?")

func writeText(text):
	var textToOutput = str(text)
	var startPos = (dialogue_sprite.position / 8.0)
	startPos.x+=2
	startPos.y+=1
	
	var currentPos = startPos
	var index = 0 # need this to determine final iteration
	
	for letter in textToOutput:
		index+=1
		letters_symbols.generateLetterSymbol(letter, currentPos, (index >= textToOutput.length()))
		currentPos.x+=1
		
			# check bounds
		if (currentPos.x > (SCREEN_WIDTH / float(DIA_TILE_WIDTH)) - 3):
			currentPos.x = startPos.x
			currentPos.y += 2
	
# Called when the node enters the scene tree for the first time.
func _ready():
	dialogue_init()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

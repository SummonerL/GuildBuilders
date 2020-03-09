extends CanvasLayer

const SCREEN_HEIGHT = 144
const SCREEN_WIDTH = 160
const TILE_HEIGHT = 16
const TILE_WIDTH = 16
const DIA_TILE_WIDTH = 8
const DIA_TILE_HEIGHT = 8
const DIALOGUE_HEIGHT = 48
const DIALOGUE_WIDTH = 160
const MAX_CHARS_PER_ROW = 16

onready var letters_symbols_obj = preload("res://Entities/HUD/Letters_Symbols/Letters_Symbols.tscn")
onready var dialogue_sprite = get_node("Dialogue_Sprite")

var letters_symbols
var dialogueState
var dialogueBuffer = []

enum STATES {
	TYPING,
	AWAITING_CONFIRMATION
}

func dialogue_init():
	# position the dialogue box to the bottom of the viewport
	dialogue_sprite.position = Vector2(0, SCREEN_HEIGHT - DIALOGUE_HEIGHT)
	
	# initial state
	dialogueState = STATES.TYPING
	
	# add the Tilemap as a child of dialogue
	letters_symbols = letters_symbols_obj.instance()
	add_child(letters_symbols)
	
	writeText("Well, I finally got the dialogue working! " + 
		"I'm stoked because I can write anything I want now. " +
		"This is the first step in creating a MASTERPIECE!"
	)

func changeState(state):
	dialogueState = state
	
func stopTimer(timer):
	timer.stop()
	remove_child(timer)
	
func timeoutTimer(timer):
	timer.start(.0001)
	
func clearText():
	letters_symbols.clearText()

func writeText(text):
	var textToOutput = str(text)
	var startPos = (dialogue_sprite.position / 8.0)
	
	var availableSpace = MAX_CHARS_PER_ROW # wrap if we don't have enough space for a word
	
	startPos.x+=2
	startPos.y+=1
	
	var currentPos = startPos
	var _letterIndex = 0 # need this to determine final iteration
	var wordIndex = 0 # index of the outer loop (because gdscript won't do this for me...')
	
	# split the dialogue into words
	var words = textToOutput.split(" ")
	
	# get starting size 
	var wordCount = words.size()
	
	var finishedPrinting = false # finished printing the current block
	
	for word in words:
		wordIndex+=1
		
		word += " " # add a space to the end of the word
		
		if (word.length() > availableSpace): # wrap if not enough space
			currentPos.x = startPos.x
			currentPos.y += 2
			availableSpace = MAX_CHARS_PER_ROW # reset available space (for the row)
			
			if currentPos.y >= ((SCREEN_HEIGHT / float(DIA_TILE_HEIGHT)) - 2):
				var timer = Timer.new()
				timer.wait_time = letters_symbols.currentTime
				timer.connect("timeout", self, "changeState", [STATES.AWAITING_CONFIRMATION])
				timer.connect("timeout", self, "stopTimer", [timer])
				add_child(timer)
				timer.start()
	
				finishedPrinting = true # finished printing this block
				dialogueBuffer = words
			
		if (!finishedPrinting):
			for letter in word:
				_letterIndex+=1
				letters_symbols.generateLetterSymbol(letter, currentPos)
				availableSpace-=1
				currentPos.x+=1
		
		if (wordIndex >= wordCount):
			letters_symbols.startArrowDownTimer()
			
		if (finishedPrinting): # we can break out of the loop if finished typing
			letters_symbols.startArrowDownTimer()
			break
			
		# now that we've printed that word, remove it
		words.remove(0)

# if something is pressed
func _input(event):
	if (event.is_action_pressed("ui_accept")):
		match dialogueState:
			STATES.AWAITING_CONFIRMATION:
				clearText()
				dialogueState = STATES.TYPING
				writeText(dialogueBuffer.join(" "))
			STATES.TYPING: # fast print!
				for node in letters_symbols.get_children():
					if node is Timer:
						letters_symbols.timeoutTimer(node)
				for node in self.get_children():
					if node is Timer:
						timeoutTimer(node)
						
	
# Called when the node enters the scene tree for the first time.
func _ready():
	dialogue_init()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

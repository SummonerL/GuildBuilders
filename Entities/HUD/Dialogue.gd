extends CanvasLayer

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in our signals
onready var signals = get_node("/root/Signal_Manager")

const DIALOGUE_HEIGHT = 48
const DIALOGUE_WIDTH = 160
const MAX_CHARS_PER_ROW = 16

onready var letters_symbols_obj = preload("res://Entities/HUD/Letters_Symbols/Letters_Symbols.tscn")
onready var dialogue_sprite = get_node("Dialogue_Sprite")

var letters_symbols
var dialogueState
var dialogueBuffer = []
var dialogue_sig # keep track of the signal that we need to emit upon completion

enum STATES {
	INACTIVE
	TYPING,
	AWAITING_CONFIRMATION
}

# boolean for whether or not the text should stay on screen upon completion
var keep_text_on_screen = false

func dialogue_init():
	# position the dialogue box to the bottom of the viewport
	dialogue_sprite.position = Vector2(0, constants.SCREEN_HEIGHT - DIALOGUE_HEIGHT)
	
	# initial state
	dialogueState = STATES.INACTIVE
	
	# add the Tilemap as a child of dialogue
	letters_symbols = letters_symbols_obj.instance()
	add_child(letters_symbols)
	letters_symbols.layer = self.layer + 1

func changeState(state):
	dialogueState = state
	
func stopTimer(timer):
	timer.stop()
	remove_child(timer)
	
func timeoutTimer(timer):
	timer.start(.0001)
	
func clearText():
	letters_symbols.clearText()
	
func kill_timers():
	for node in letters_symbols.get_children():
		if node is Timer:
			letters_symbols.remove_child(node)
	for node in self.get_children():
		if node is Timer:
			remove_child(node)

func completeText(used_for_resetting = true):
	dialogueState = STATES.INACTIVE
	dialogue_sprite.visible = false

	# if we have a dialogue_sig, emit it upon completion (callback)
	if (dialogue_sig && !used_for_resetting):
		signals.emit_signal(dialogue_sig)

# used to provide a small time buffer before typing the text. This is useful for the selection menu,
# when an _input gets triggered for the select list as well as the dialogue window
func typeTextWithBuffer(text, keep = false, sig = null):
	var timer_for_buffer = Timer.new()
	timer_for_buffer.connect("timeout", self, "typeText", [text, keep, sig, timer_for_buffer])
	timer_for_buffer.wait_time = .01
	add_child(timer_for_buffer)
	timer_for_buffer.start()

func typeText(text, keep = false, sig = null, timer_for_buffer = null):
	# kill the timer, if there is one
	if (timer_for_buffer):
		timer_for_buffer.stop()
		remove_child(timer_for_buffer)
		
	# set the dialogue_sig, if there is one
	dialogue_sig = sig	
	
	keep_text_on_screen = keep
	# turn on the dialogue box, if it isn't turned on
	if (dialogueState == STATES.INACTIVE):
		dialogueState = STATES.TYPING
		dialogue_sprite.visible = true
	
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
	
	var finishedPrintingBlock = false # finished printing the current block
	
	for word in words:
		wordIndex+=1
		
		word += " " # add a space to the end of the word
		
		if (word.length() > availableSpace): # wrap if not enough space
			currentPos.x = startPos.x
			currentPos.y += 2
			availableSpace = MAX_CHARS_PER_ROW # reset available space (for the row)
			
			if currentPos.y >= ((constants.SCREEN_HEIGHT / float(constants.DIA_TILE_HEIGHT)) - 2):
				finishedPrintingBlock = true # finished printing this block
				dialogueBuffer = words
				wordIndex -= 1
			
		if (!finishedPrintingBlock):
			for letter in word:
				_letterIndex+=1
				letters_symbols.generateLetterSymbol(letter, currentPos)
				availableSpace-=1
				currentPos.x+=1
		
		# if we've finished printing all of the text (not just the block)
		if (wordIndex >= wordCount):
			dialogueBuffer = []
			finishedPrintingBlock = true
			
			
		
		if (finishedPrintingBlock): # we can break out of the loop if finished typing
			if (!keep_text_on_screen || dialogueBuffer.size()  > 0):
				var timer = Timer.new()
				timer.wait_time = letters_symbols.currentTime
				timer.connect("timeout", self, "changeState", [STATES.AWAITING_CONFIRMATION])
				timer.connect("timeout", self, "stopTimer", [timer])
				add_child(timer)
				timer.start()
				letters_symbols.startArrowDownTimer()
				break
			
		# now that we've printed that word, remove it
		words.remove(0)

# if something is pressed
func _input(event):
	if (event.is_action_pressed("ui_accept")):
		match dialogueState:
			STATES.AWAITING_CONFIRMATION:
				if (dialogueBuffer.size() > 0):
					clearText()
					dialogueState = STATES.TYPING
					typeText(dialogueBuffer.join(" "), keep_text_on_screen, dialogue_sig)
				else:
					if (!keep_text_on_screen): # for instances when we want to leave the text on screen
						clearText()
						dialogueState = STATES.TYPING
						completeText(false) # finished printing everything!
	
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

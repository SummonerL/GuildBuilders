extends Node2D

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# A Test of Artistry...
# ... a game by
# Arid Bard (Elliot Simpson)

# Overworld Scene (Main)

# preload our game objects
onready var cursor_scn = preload("res://Entities/Player/Cursor.tscn")
onready var camera_scn = preload("res://Entities/Camera/Camera.tscn")
onready var hud_scn = preload("res://Entities/HUD/Dialogue.tscn")

# game instances
var cursor
var camera
var hud

func gameInit():
	cursor = cursor_scn.instance()
	camera = camera_scn.instance()
	hud = hud_scn.instance()
	
	add_child(camera)
	add_child(cursor)
	camera.add_child(hud) # make the hud a child of the camera
	
	# lights, camera, action!
	camera.turnOn()

# Called when the node enters the scene tree for the first time.
func _ready():
	gameInit()
	pass # Replace with function body.

# temporarily use to text dialogue system
func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		match hud.dialogueState:
			hud.STATES.INACTIVE:
				hud.writeText("Well... I think we officially got the " +
							"dialogue system working to perfection. " +
							"Hopefully this will be the first step " + 
							"in creating the game of my dreams. " + 
							"As a matter of fact, I think I'll write " + 
							"a novel in here... JK!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
#	pass

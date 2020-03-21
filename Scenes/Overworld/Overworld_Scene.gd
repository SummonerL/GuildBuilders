extends Node2D

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in our global player variables
onready var player = get_node("/root/Player_Globals")

# A Test of Artistry...
# ... a game by
# Arid Bard (Elliot Simpson)

# Overworld Scene (Main)

# preload our game objects
onready var cursor_scn = preload("res://Entities/Player/Cursor.tscn")
onready var camera_scn = preload("res://Entities/Camera/Camera.tscn")
onready var hud_scn = preload("res://Entities/HUD/Dialogue.tscn")
onready var hud_tile_info_scn = preload("res://Entities/HUD/Tile_Info.tscn")


# game music
onready var twelve_pm_loop = get_node("12PM_Loop")

# game instances
var cursor
var camera
var hud
var hud_tile_info

func gameInit():
	cursor = cursor_scn.instance()
	camera = camera_scn.instance()
	hud = hud_scn.instance()
	hud_tile_info = hud_tile_info_scn.instance()
	
	# add units to the player's party
	player.party.add_unit(constants.UNIT_TYPES.ANGLER_MALE)
	player.party.add_unit(constants.UNIT_TYPES.ANGLER_FEMALE)
	
	add_child(camera)
	camera.add_child(hud_tile_info) # make the hud a child of the camera
	add_child(cursor)
	camera.add_child(hud)
	
	# lights, camera, action!
	camera.turnOn()
	
	# start looping our '12PM' track
	#twelve_pm_loop.connect("finished", self, "loop_audio", [twelve_pm_loop])
	twelve_pm_loop.play()

# Called when the node enters the scene tree for the first time.
func _ready():
	gameInit()
	
# used to loop the current background music
func loop_audio(track):
	track.play()

# temporarily use to text dialogue system
func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		match hud.dialogueState:
			hud.STATES.INACTIVE:
				hud.typeText("Well... I think we officially got the " +
							"dialogue system working to perfection. " +
							"Hopefully this will be the first step " + 
							"in creating the game of my dreams. " + 
							"As a matter of fact, I think I'll write " + 
							"a novel in here... JK!")


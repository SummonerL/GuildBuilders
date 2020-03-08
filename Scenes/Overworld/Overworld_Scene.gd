extends Node2D

# A Test of Artistry...
# ... a game by
# Arid Bard (Elliot Simpson)

# Overworld Scene (Main)

# preload our game objects
onready var cursor_scn = preload("res://Entities/Player/Cursor.tscn")
onready var camera_scn = preload("res://Entities/Camera/Camera.tscn")

# game instances
var cursor
var camera

func gameInit():
	cursor = cursor_scn.instance()
	camera = camera_scn.instance()
	
	add_child(camera)
	add_child(cursor)
	
	# lights, camera, action!
	camera.turnOn()
	
	pass


# Called when the node enters the scene tree for the first time.
func _ready():
	gameInit()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
#	pass

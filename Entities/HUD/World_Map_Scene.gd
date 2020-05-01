extends CanvasLayer

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

func world_map_init():
	# hide all of the regions that should be hidden
	pass	

func _ready():
	world_map_init()
	
func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		get_parent().kill_world_map_screen()

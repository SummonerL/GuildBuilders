extends Node

# autoloaded script for guild variables / functions

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# keep track of the global player variables
onready var player = get_node("/root/Player_Globals")

# bring in our items
onready var global_items_list = get_node("/root/Items")

# bring in our global action list
onready var global_action_list = get_node("/root/Actions")

# various hud scenes
onready var hud_selection_list_scn = preload("res://Entities/HUD/Selection_List.tscn")
onready var hud_depot_screen_scn = preload("res://Entities/HUD/Depot_Screen.tscn")

# keep track of the camera
var camera

# keep track of all the items currently in the depot
var current_items = []

# keep track of the depot screen (if it exists)
var hud_depot_screen_node

func populate_depot_screen(active_unit):
	camera = get_tree().get_nodes_in_group("Camera")[0]
	
	hud_depot_screen_node = hud_depot_screen_scn.instance()
	camera.add_child(hud_depot_screen_node)
	hud_depot_screen_node.set_unit(active_unit)
	
func transition_items_at_depot():
	if (hud_depot_screen_node):
		hud_depot_screen_node.transfer_item()

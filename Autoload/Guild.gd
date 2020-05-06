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
onready var hud_depot_screen_scn = preload("res://Entities/HUD/Guild Actions/Depot_Screen.tscn")
onready var hud_dining_screen_scn = preload("res://Entities/HUD/Guild Actions/Dining_Screen.tscn")
onready var hud_guild_info_screen_scn = preload("res://Entities/HUD/Info Screens/Guild_Info_Screen.tscn")

# keep track of the camera
var camera

# keep track of all the items currently in the depot
var current_items = []

# keep track of the depot screen (if it exists)
var hud_depot_screen_node

# keep track of the dining screen (if it exists)
var hud_dining_screen_node

# keep track of the guild info screen (if it exists)
var hud_guild_info_screen_node

# ------------ QUESTS -----------------
# keep track of the quests that are in progress and completed
var main_in_progress = []
var side_in_progress = []
var main_completed = []

var side_completed = []

onready var quest_friend_wanted = {
	"name": "Friend Wanted",
	"start_prompt": "Hear Brother Samuel out?",
	"statuses": [
		"A former member of the guild named Brother Samuel has asked you to bring him a wooden pipe."
	],
	"current_progress": 0,
	"current_status": 0,
	"reward": null
}

onready var main_quests = []
onready var side_quests = [quest_friend_wanted]

func already_has_quest(quest_to_check):
	# make sure the player has not already initiated completed this quest
	var all_quests = []
	all_quests += side_in_progress + side_completed + main_in_progress + main_completed
	
	var has_quest = false
	
	for quest in all_quests:
		if (quest_to_check.name == quest.name):
			has_quest = true
			
	return has_quest

func start_quest(quest_to_start, npc = null):
	# first, make sure the player hasn't already started this quest
	if (!already_has_quest(quest_to_start)):
		# determine if this is a main quest or side quest
		var is_main_quest = false
		for quest in main_quests:
			if (quest.name == quest_to_start.name):
				is_main_quest = true
				
		# add the quest to our in-progress quests
		if (is_main_quest):
			main_in_progress.append(quest_to_start)
		else:
			side_in_progress.append(quest_to_start)
			
		# start the npcs quest dialogue
		get_tree().get_current_scene().npcs.talk_to_npc(npc, 1, 1)


# --------------------------------------

func populate_depot_screen(active_unit):
	camera = get_tree().get_nodes_in_group("Camera")[0]
	
	hud_depot_screen_node = hud_depot_screen_scn.instance()
	camera.add_child(hud_depot_screen_node)
	hud_depot_screen_node.set_unit(active_unit)
	
func populate_dining_screen(active_unit):
	camera = get_tree().get_nodes_in_group("Camera")[0]
	
	# add the dine screen to the camera
	hud_dining_screen_node = hud_dining_screen_scn.instance()
	camera.add_child(hud_dining_screen_node)
	
	hud_dining_screen_node.set_unit(active_unit)
	
func populate_guild_info_screen():
	camera = get_tree().get_nodes_in_group("Camera")[0]
	
	# add the guild info screen to the camera
	hud_guild_info_screen_node = hud_guild_info_screen_scn.instance()
	camera.add_child(hud_guild_info_screen_node)
	
func transition_items_at_depot():
	if (hud_depot_screen_node):
		hud_depot_screen_node.transfer_item()
		
func show_item_info_at_depot():
	if (hud_depot_screen_node):
		hud_depot_screen_node.show_item_info()
		
func trash_item_at_depot():
	if (hud_depot_screen_node):
		hud_depot_screen_node.trash_item()
		
func eat_food_at_dining_hall():
	if (hud_dining_screen_node):
		hud_dining_screen_node.eat_food()
func show_item_info_at_dining_hall():
	if (hud_dining_screen_node):
		hud_dining_screen_node.show_item_info()

extends Node2D

# This scene keeps track of all of the npcs in the overworld

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in our player globals
onready var player = get_node("/root/Player_Globals")

# bring in our guild variables/functions
onready var guild = get_node("/root/Guild")

# bring in our signals
onready var signals = get_node("/root/Signal_Manager")

# various hud scenes
onready var hud_selection_list_scn = preload("res://Entities/HUD/Selection_List.tscn")

# keep track of the camera
var camera

# quick multiline helper
func ml(str_array):
	var return_str = ""
	for string in str_array:
		return_str += string
	return return_str

onready var npc_lonely_man_samuel = 	{
	"name": "Samuel",
	"region": 0, # guild region
	"quests_initiated": [
		guild.quest_friend_wanted
	],
	"initiates_quest_immediately": true,
	"dialogue": [
		"I could sure use a friend...",
		
		ml(["Thank you for taking the time to speak with me. The truth is, I don\'t get visitors very often. ",
		"However, being near the guild gives me a sense of comfort. Reminds me of the good old days... ",
		"Say, why don't you bring over a couple of pipes and we can have a smoke while I tell my story?"]),
		
		"If you want to bring over a couple of pipes, we can have a smoke while I tell my story."
	],
	"current_dialogue": 0, # initial dialogue
	"current_quest": 0, # quest that is active with this npc
	"overworld_sprite": get_node("Lonely_Man_Samuel_Sprite"),
	"pos_x": 16,
	"pos_y": 25
}

# keep track of all the npcs
onready var npcs = [
	npc_lonely_man_samuel
]

# keep track of the npc that is currently being interacted with
var active_npc = null

func talk_to_npc(npc = null, dialogue_before_changer = 0, dialogue_after_changer = 0, dialogue_setter = null):
	if (npc):
		active_npc = npc
		
	# an argument for explicitly setting the current dialogue
	if (dialogue_setter):
		active_npc.current_dialogue = dialogue_setter
		
	active_npc.current_dialogue += dialogue_before_changer # this param will change the unit's current dialogue
		
	print(active_npc.dialogue[active_npc.current_dialogue])
	player.hud.typeTextWithBuffer(active_npc.dialogue[active_npc.current_dialogue], false, "finished_viewing_text_generic")
	
	yield(signals, "finished_viewing_text_generic")
	
	active_npc.current_dialogue += dialogue_after_changer # this param will change the unit's current dialogue
	
	# if this unit initiates a quest, and we haven't already started it
	if (active_npc.initiates_quest_immediately && active_npc.quests_initiated.size() > 0 &&
		!guild.already_has_quest(active_npc.quests_initiated[active_npc.current_quest])):
			
		# pause the node
		set_process_input(false)
		
		# the quest that is getting initiated
		var quest = active_npc.quests_initiated[active_npc.current_quest]
		
		# prompt the user to begin this quest
		var hud_selection_list_node = hud_selection_list_scn.instance()
		camera = get_tree().get_nodes_in_group("Camera")[0]
		camera.add_hud_item(hud_selection_list_node)

		# connect signals for confirming whether or not to craft an item
		signals.connect("confirm_generic_yes", self, "_on_quest_confirmation", [true, quest], CONNECT_ONESHOT)
		signals.connect("confirm_generic_no", self, "_on_quest_confirmation", [false], CONNECT_ONESHOT)
		
		# populate the selection list with a yes/no confirmation
		hud_selection_list_node.populate_selection_list([], self, true, false, true, false, true, quest.start_prompt, 
														'confirm_generic_yes', 'confirm_generic_no')
	else:	
		# once it's all over, set the player state back
		player.player_state = player.PLAYER_STATE.SELECTING_TILE


# once the player confirms whether or not they would like to initiate a quest
func _on_quest_confirmation(yes, quest = null):
	# unpause the node
	set_process_input(true)
	if (yes):
		signals.disconnect("confirm_generic_no", self, "_on_quest_confirmation")
		
		# initiate the quest
		guild.start_quest(quest, active_npc)
	else:
		signals.disconnect("confirm_generic_yes", self, "_on_quest_confirmation")
		# once it's all over, set the player state back
		player.player_state = player.PLAYER_STATE.SELECTING_TILE

func set_active_npc(npc):
	active_npc = npc

func clear_active_npc():
	active_npc = null

func find_npc_at_tile(tile):
	# iterate over the npcs, and find one that matches these coordinates
	for npc in npcs:
		if (npc.pos_x == tile.x && npc.pos_y == tile.y):
			return npc

func initialize_npcs():
	# position each npc onto the map
	for npc in npcs:
		npc.overworld_sprite.position = Vector2(npc.pos_x*constants.TILE_WIDTH, npc.pos_y*constants.TILE_HEIGHT)

func _ready():
	initialize_npcs()

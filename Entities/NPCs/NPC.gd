extends Node2D

# This scene keeps track of all of the npcs in the overworld

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in our player globals
onready var player = get_node("/root/Player_Globals")

# bring in our global action list
onready var global_action_list = get_node("/root/Actions")

# bring in our guild variables/functions
onready var guild = get_node("/root/Guild")

# bring in our signals
onready var signals = get_node("/root/Signal_Manager")

# various hud scenes
onready var hud_selection_list_scn = preload("res://Entities/HUD/Selection_List.tscn")

# keep track of the camera
var camera

# keep track of the unit that is interacting with this npc
var active_unit

const STAY_AT_INN_PROMPT = "Stay at the inn?"

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
	"quests_involved_in": [
		guild.quest_friend_wanted # should at least contain the quests that this npc initiates
	],
	"initiates_quest_immediately": true,
	"dialogue": [
		"I could sure use a friend...",
		
		ml(["Thank you for taking the time to speak with me. The truth is, I don\'t get visitors very often. ",
		"However, being near the guild gives me a sense of comfort. Reminds me of the good old days... ",
		"Say, why don't you bring over a couple of pipes and we can have a smoke while I tell my story?"]),
		
		"If you want to bring over a couple of pipes, we can have a smoke while I tell my story.",
		
		ml(["Excellent! I see you brought some pipes. Why don't you take a seat? It gets lonely around here... ",
			"and with all this talk of war, it's hard to stay positive. One thing that keeps my spirits up is thinking back ",
			"on my memories in the guild. I was actually a founding member. That was back in the guild's glory days. It was my ",
			"job to make sure the depot was always stocked with food. ",
			"No Brother or Sister ever went hungry with me around. Unfortunately, I got a bit gutsy one day ",
			"and went looking for lavafish near Mount Kaluda. I had one on the hook. A big one... and then... it pulled me in. ",
			"Fortunately, a Sister was there with me and helped pull me out before I got too burnt. But after that, I knew it was ",
			"time to retire. Now I watch from afar as the new generation of guildmembers go about their day. I like to think of myself ",
			"as the guild guardian. Anyway, I've talked long enough. Here, let me give you a gift for putting up with my rambling."]),
			
		"Ah... it warms my heart to have a visitor."
	],
	"current_dialogue": 0, # initial dialogue
	"current_quest": 0, # quest that is active with this npc
	"overworld_sprite": get_node("Lonely_Man_Samuel_Sprite"),
	"pos_x": 16,
	"pos_y": 25
}

onready var npc_young_girl_rika = {
	"name": "Rika",
	"region": 0, # guild region
	"dialogue": [
		ml(["This region is known to have a lot of jumbofish. The last time I ate one, I wasn't hungry ",
		"for a week!"])
	],
	"initiates_quest_immediately": false,
	"current_dialogue": 0, # initial dialogue
	"overworld_sprite": get_node("Young_Girl_Rika"),
	"pos_x": 7,
	"pos_y": 17
}

onready var npc_rikas_father_bjorn = {
	"name": "Bjorn",
	"region": 0, # guild region
	"dialogue": [
		ml(["My daughter loves to go exploring. As a single father, I worry about her. Please keep an eye on her if you see ",
			"her near the guild."])
	],
	"initiates_quest_immediately": false,
	"current_dialogue": 0, # initial dialogue
	"overworld_sprite": get_node("Rikas_Father_Bjorn"),
	"pos_x": 5,
	"pos_y": 20
}

onready var npc_guild_admirer_harrison = {
	"name": "Harrison",
	"region": 0, # guild region
	"dialogue": [
		ml(["Hey! You're from the guild right? Thank you for all that you do. By the way, see that tower over there? ",
		"Apparently, one was built at the edge of each region. I hear the view from the top is incredible."])
	],
	"initiates_quest_immediately": false,
	"current_dialogue": 0, # initial dialogue
	"overworld_sprite": get_node("Guild_Admirer_Harrison"),
	"pos_x": 26,
	"pos_y": 8
}

onready var npc_innkeeper_henry = {
	"name": "Henry",
	"region": 2, # Bellmare
	"dialogue": [
		"Hi there! Would you like to stay a night at the inn? It's free for guild members!",
		"Fantastic. Just return here when you are ready for bed.",
		"I'm sorry, there's no vacancy at the inn...",
		"Have a great stay!"
	],
	"initiates_quest_immediately": false,
	"current_dialogue": 0, # initial dialogue
	"innkeeper": constants.inn_list[0], # owns the Bellmare Inn
	"overworld_sprite": get_node("Innkeeper_Henry"),
	"pos_x": 54,
	"pos_y": 10
}

onready var npc_bellmare_woman_ema = {
	"name": "Ema",
	"region": 2, # Bellmare
	"dialogue": [
		ml(["I've lived in Bellmare since I was a little girl. I've considered venturing out, but being near the castle makes me feel safe. That's all ",
			"anyone can ask for these days."])
	],
	"initiates_quest_immediately": false,
	"current_dialogue": 0, # initial dialogue
	"overworld_sprite": get_node("Bellmare_Woman_Ema"),
	"pos_x": 55,
	"pos_y": 15
}

onready var npc_farmer_fred = {
	"name": "Fred",
	"region": 2, # Bellmare
	"dialogue": [
		""
	],
	"initiates_quest_immediately": false,
	"current_dialogue": 0, # initial dialogue
	"overworld_sprite": get_node("Farmer_Fred"),
	"pos_x": 39,
	"pos_y": 8
}

onready var npc_bellmare_cat = {
	"name": "Bellmare Cat",
	"region": 2, # Bellmare
	"dialogue": [
		""
	],
	"no_talk": true,
	"initiates_quest_immediately": false,
	"current_dialogue": 0, # initial dialogue
	"overworld_sprite": get_node("Bellmare_Cat"),
	"pos_x": 53,
	"pos_y": 14
}

# keep track of all the npcs
onready var npcs = [
	npc_lonely_man_samuel,
	npc_young_girl_rika,
	npc_guild_admirer_harrison,
	npc_rikas_father_bjorn,
	npc_innkeeper_henry,
	npc_bellmare_woman_ema,
	npc_farmer_fred,
	npc_bellmare_cat
]

# keep track of the npc that is currently being interacted with
var active_npc = null

func talk_to_npc(unit, npc = null, dialogue_before_changer = 0, dialogue_after_changer = 0, dialogue_setter = null, quest_condition_bypass = false):
	if (unit):
		active_unit = unit
	
	if (npc):
		active_npc = npc
		
	# first, check any quest conditions (this can sometimes change the npcs dialogue manually)
	if (!quest_condition_bypass):
		guild.check_quest_conditions_npc(active_npc, active_unit)
		return
		
	# then, check misc npc conditions (text can be updated as a result of conditions being true)
	var one_time_dialogue = check_npc_conditions(active_npc, active_unit)
		
	# an argument for explicitly setting the current dialogue
	if (dialogue_setter):
		active_npc.current_dialogue = dialogue_setter
		
	active_npc.current_dialogue += dialogue_before_changer # this param will change the unit's current dialogue
	
	if (one_time_dialogue != null):
		player.hud.typeTextWithBuffer(active_npc.dialogue[one_time_dialogue], false, "finished_viewing_text_generic")
	else:
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

		# connect signals for confirming whether or not the player initiates the quest
		signals.connect("confirm_generic_yes", self, "_on_quest_confirmation", [true, quest], CONNECT_ONESHOT)
		signals.connect("confirm_generic_no", self, "_on_quest_confirmation", [false], CONNECT_ONESHOT)
		
		# populate the selection list with a yes/no confirmation
		hud_selection_list_node.populate_selection_list([], self, true, false, true, false, true, quest.start_prompt, 
														'confirm_generic_yes', 'confirm_generic_no')
	elif (active_npc.has("innkeeper")): # if the npc is an innkeeper
		# determine if the inn is vacant
		var inn = active_npc.innkeeper
		if (inn.occupants.size() < inn.max_occupancy):
			# vacant!
			# prompt the user to stay at the inn
			var hud_selection_list_node = hud_selection_list_scn.instance()
			camera = get_tree().get_nodes_in_group("Camera")[0]
			camera.add_hud_item(hud_selection_list_node)
			# connect signals for confirming whether or not the player stays at the inn
			signals.connect("confirm_generic_yes", self, "_on_inn_confirmation", [true, inn], CONNECT_ONESHOT)
			signals.connect("confirm_generic_no", self, "_on_inn_confirmation", [false], CONNECT_ONESHOT)
			
			# populate the selection list with a yes/no confirmation
			hud_selection_list_node.populate_selection_list([], self, true, false, true, false, true, STAY_AT_INN_PROMPT,
															'confirm_generic_yes', 'confirm_generic_no')
		else:
			# not vacant... do nothing (the npc should have already read the correct text)
			player.player_state = player.PLAYER_STATE.SELECTING_TILE
	else:	
		# once it's all over, set the player state back
		player.player_state = player.PLAYER_STATE.SELECTING_TILE

func check_npc_conditions(active_npc, active_unit):
	# if the unit is an innkeeper, and the npc is already staying here
	if (active_npc.has("innkeeper") && active_unit.active_inn != null && 
			active_unit.active_inn.name == active_npc.innkeeper.name):
		return 3
	else:
		return null

# if the player decides to stay at the inn
func _on_inn_confirmation(staying, inn = null):
	# unpause the node
	set_process_input(true)
	if (staying):
		signals.disconnect("confirm_generic_no", self, "_on_inn_confirmation")
		
		# add the active unit as to the list of occupants
		inn.occupants.append(active_unit)
		
		# add INN to the list of places to return to (at night)
		active_unit.shelter_locations.append(global_action_list.COMPLETE_ACTION_LIST.RETURN_TO_INN)
		
		# and make this inn the active inn for the unit
		active_unit.active_inn = inn
		
		# read the follow up text
		player.hud.typeTextWithBuffer(active_npc.dialogue[1], false, "finished_viewing_text_generic")
	
		yield(signals, "finished_viewing_text_generic")
		
		# and change the active dialogue for this npc
		active_npc.current_dialogue = 2
	else:
		signals.disconnect("confirm_generic_yes", self, "_on_inn_confirmation")
		
	# once it's all over, set the player state back
	player.player_state = player.PLAYER_STATE.SELECTING_TILE
		

# once the player confirms whether or not they would like to initiate a quest
func _on_quest_confirmation(yes, quest = null):
	# unpause the node
	set_process_input(true)
	if (yes):
		signals.disconnect("confirm_generic_no", self, "_on_quest_confirmation")
		
		# initiate the quest
		guild.start_quest(active_unit, quest, active_npc)
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

# every morning, the innkeepers dialogue should reset
func reset_innkeeper_dialogue():
	for npc in npcs:
		if (npc.has("innkeeper")):
			npc.current_dialogue = 0

func _ready():
	initialize_npcs()

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

enum RACES {
	HUMAN,
	GOBLIN,
	ANIMAL,
	GHOST,
}

onready var race_diplomacy_requirements = {
	RACES.GOBLIN: 5
}

onready var npc_lonely_man_samuel = 	{
	"name": "Samuel",
	"race": RACES.HUMAN,
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
	"race": RACES.HUMAN,
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
	"race": RACES.HUMAN,
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
	"race": RACES.HUMAN,
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
	"race": RACES.HUMAN,
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
	"race": RACES.HUMAN,
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
	"race": RACES.HUMAN,
	"region": 2, # Bellmare
	"quests_initiated": [
		guild.quest_horse_rescue
	],
	"quests_involved_in": [
		guild.quest_horse_rescue # should at least contain the quests that this npc initiates
	],
	"initiates_quest_immediately": true,
	"dialogue": [
		"I can't believe my best friend was taken from me...",
		
		ml(["Skyheart... that was her name. A beautiful white horse that lived here on the farm with me. I awoke yesterday morning to find that she was gone. ",
			"The fence was open, and I saw several tracks in the ground. I have a suspicion that she was taken by goblins. There is a goblin camp just ",
			"Southwest of here. Nasty bunch. They're always giving the folks of Bellare trouble. I don't expect her",
			" to still be alive, but could you please go investigate? If there's any possibility of getting her back, I'll do whatever it takes."]),
		
		"Please let me know if you find Skyheart!",
		
		"Ya finished! Yay!",
		
		"pizza?"
	],
	"current_dialogue": 0, # initial dialogue
	"current_quest": 0, # quest that is active with this npc
	"overworld_sprite": get_node("Farmer_Fred"),
	"pos_x": 39,
	"pos_y": 8
}

onready var npc_bellmare_cat = {
	"name": "Bellmare Cat",
	"race": RACES.ANIMAL,
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

onready var npc_guild_beaver = { # can turn into an actual 'animal' unit when tamed
	"name": "Guild Beaver",
	"race": RACES.ANIMAL,
	"region": 1, # Guild
	"dialogue": [
		""
	],
	"no_talk": true,
	"initiates_quest_immediately": false,
	"current_dialogue": 0, # initial dialogue
	"overworld_sprite": get_node("Guild_Beaver"),
	"pos_x": 18,
	"pos_y": 18
}

onready var npc_bellmare_knight_girault = {
	"name": "Girault",
	"race": RACES.HUMAN,
	"region": 2, # Bellmare
	"dialogue": [
		ml(["I've been serving King Raolet for over 20 years now, but I've yet to see him this distressed... For the past ",
			"few months, he's spent most of his time contemplating in the castle courtyard. He acts as if he bears the weight of the world. ",
			"I guess he does, in a way."])
	],
	"initiates_quest_immediately": false,
	"current_dialogue": 0, # initial dialogue
	"overworld_sprite": get_node("Bellmare_Knight_Girault"),
	"pos_x": 48,
	"pos_y": 24
}

onready var npc_king_raolet = {
	"name": "King Raolet",
	"race": RACES.HUMAN,
	"region": 2, # Bellmare
	"dialogue": [
		ml([""])
	],
	"initiates_quest_immediately": false,
	"current_dialogue": 0, # initial dialogue
	"overworld_sprite": get_node("King_Raolet"),
	"diplomatic_leader": constants.faction_list[0], # king of Bellmare
	"faction_relation": guild.bellmare_relation, # the actual relationship between the guild and bellmare
	"met_with_unit_today": false, # keep track of whether or not this unit has met with a guildmember today
	"pos_x": 43,
	"pos_y": 22
}

onready var npc_goblin_villager_drig = {
	"name": "Drig",
	"race": RACES.GOBLIN,
	"region": 2, # Bellmare
	"dialogue": [
		"RHAL KAAKHAKHEC DAAN HAAR.",
		ml(["Goblins get a bad rep. We're not all that bad, we just really like horse flesh."])
	],
	"initiates_quest_immediately": false,
	"current_dialogue": 1, # initial dialogue
	"overworld_sprite": get_node("Goblin_Villager_Drig"),
	"pos_x": 36,
	"pos_y": 26
}

onready var npc_goblin_villager_fafza = {
	"name": "Fafza",
	"race": RACES.GOBLIN,
	"region": 2, # Bellmare
	"dialogue": [
		"HUUKEC DUULKAAC HAAKHEC.",
		ml(["Goblin women are known throughout the world for their beauty. At least, that's ",
			 "what my mom tells me."])
	],
	"initiates_quest_immediately": false,
	"current_dialogue": 1, # initial dialogue
	"overworld_sprite": get_node("Goblin_Villager_Fafza"),
	"pos_x": 33,
	"pos_y": 24
}

onready var npc_goblin_king_rul = {
	"name": "King Rul",
	"race": RACES.GOBLIN,
	"region": 2, # Bellmare
	"quests_involved_in": [
		guild.quest_horse_rescue
	],
	"dialogue": [
		"HOCH HUUL DUUN HUUKEC. MOLKAC MAKHAAN AN.",
		
		ml(["I really appreciate that the guild is taking time to talk with us goblins. Most humans ",
			 "despise us."]),
			
		ml(["Look at this beauty that we managed to get our hands on! She's going to make this year's Alag Banquet ",
			 "the best ever."]),
			
		ml(["Every year the Goblin Clan holds a feast in honor of the great goblin King Alag. It was many centuries ago ",
		"that Alag rode across the kingdom on his faithful companion, Anziyan, in a diplomatic mission. The charasmatic king ",
		"dreamt of a world where goblin tribes would no longer be divided. With his affable nature, he managed to win the hearts ",
		"of all the goblin chieftans. To this day, we all stand united."]),
		
		ml(["I see that old farmer has sent you for this horse. I can sympathize with the fact that the farmer thinks of this ",
		"horse as his companion. We goblins also view horses as companions. However, it is customary for goblins to dine on horse. ",
		"We view it as a horse's final sacrifice to us. I would be willing to make an exception for this year's feast. However, ",
		"I would require a food just as delicious as horse. Additionally, we will need enough for each villager."]),
		
		"Please return with a food just as delicious as horse. We will require enough for each villager.",
		
		"Catfish! Delicious! I see you've brought enough for everyone. As promised, I'll return Skyheart to that old farmer."
	],
	"initiates_quest_immediately": false,
	"current_dialogue": 1, # initial dialogue
	"overworld_sprite": get_node("Goblin_King_Rul"),
	"diplomatic_leader": constants.faction_list[1], # king of the Goblin clan
	"faction_relation": guild.goblin_clan_relation, # the actual relationship between the guild and the goblins
	"met_with_unit_today": false, # keep track of whether or not this unit has met with a guildmember today
	"pos_x": 35,
	"pos_y": 21
}

onready var npc_horse_skyheart = {
	"name": "Skyheart",
	"race": RACES.ANIMAL,
	"region": 2, # Bellmare
	"dialogue": [
		""
	],
	"no_talk": true,
	"initiates_quest_immediately": false,
	"current_dialogue": 0, # initial dialogue
	"overworld_sprite": get_node("Horse_Skyheart"),
	"pos_x": 34,
	"pos_y": 21
}

onready var npc_court_mage_ashan = {
	"name": "Ashan",
	"race": RACES.HUMAN,
	"region": 2, # Bellmare
	"dialogue": [
		ml(["I am a magician in service to King Raolet. Lately I've been working on a spell to transport ",
		"items instantly over long distances."])
	],
	"initiates_quest_immediately": false,
	"current_dialogue": 0, # initial dialogue
	"overworld_sprite": get_node("Court_Mage_Ashan"),
	"pos_x": 50,
	"pos_y": 17
}

onready var npc_bellmare_head_chef_frederik = {
	"name": "Frederik",
	"race": RACES.HUMAN,
	"region": 2, # Bellmare
	"dialogue": [
		ml(["I'm the head chef here at the inn. If you have some fish on you, I might be able to ",
			"prepare it for you."])
	],
	"initiates_quest_immediately": false,
	"current_dialogue": 0, # initial dialogue
	"overworld_sprite": get_node("Head_Chef_Frederik"),
	"pos_x": 56,
	"pos_y": 10
}

onready var npc_swamp_traveller_bryna = {
	"name": "Bryna",
	"race": RACES.HUMAN,
	"region": 4, # Sedgelin Swamplands
	"dialogue": [
		ml(["I tried to cross the Sedgelin Swamplands, but the water was up to my knees. ",
		"If only I had some rubber boots."])
	],
	"initiates_quest_immediately": false,
	"current_dialogue": 0, # initial dialogue
	"overworld_sprite": get_node("Swamp_Traveller_Bryna"),
	"pos_x": -3,
	"pos_y": 12
}

onready var npc_swamp_shortcut_goblin_nexi = {
	"name": "Nexi",
	"race": RACES.GOBLIN,
	"region": 4, # Sedgelin Swamplands
	"dialogue": [
		"SHAC DALAAN O DUUN OKHAAR TERTHAAN OR TAL.",
		ml(["My brother and I used to play in the swamlands growing up. I know this area ",
		"very well. I even know a shortcut to the Western side."])
	],
	"initiates_quest_immediately": false,
	"current_dialogue": 1, # initial dialogue
	"action_relation": guild.goblin_clan_relation, # for the FOLLOW action
	"action_favor_requirement": 7, # the favor required for FOLLOW action
	"overworld_sprite": get_node("Swamp_Shortcut_Goblin_Nexi"),
	"pos_x": -7,
	"pos_y": 20
}

onready var npc_sedgelin_ghost_rubin = {
	"name": "Rubin",
	"race": RACES.GHOST,
	"scary": true, # requires the unit to have some courage
	"region": 4, # Sedgelin Swamplands
	"dialogue": [
		ml(["This spot is cute and all, but I wish I had been buried with some company."])
	],
	"initiates_quest_immediately": false,
	"current_dialogue": 0, # initial dialogue
	"overworld_sprite": get_node("Sedgelin_Ghost_Rubin"),
	"pos_x": -14,
	"pos_y": 4
}

onready var npc_sedgelin_gator = {
	"name": "Sedgelin Gator",
	"race": RACES.ANIMAL,
	"region": 4, # Sedgelin Swamplands
	"dialogue": [
		""
	],
	"initiates_quest_immediately": false,
	"current_dialogue": 0, # initial dialogue
	"overworld_sprite": get_node("Sedgelin_Gator"),
	"pos_x": -11,
	"pos_y": 23
}

onready var npc_sedgelin_gator2 = {
	"name": "Sedgelin Gator 2",
	"race": RACES.ANIMAL,
	"region": 4, # Sedgelin Swamplands
	"dialogue": [
		""
	],
	"initiates_quest_immediately": false,
	"current_dialogue": 0, # initial dialogue
	"overworld_sprite": get_node("Sedgelin_Gator2"),
	"pos_x": -22,
	"pos_y": 8
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
	npc_bellmare_cat,
	npc_bellmare_knight_girault,
	npc_king_raolet,
	npc_goblin_villager_drig,
	npc_goblin_villager_fafza,
	npc_goblin_king_rul,
	npc_horse_skyheart,
	npc_guild_beaver,
	npc_court_mage_ashan,
	npc_bellmare_head_chef_frederik,
	npc_swamp_traveller_bryna,
	npc_swamp_shortcut_goblin_nexi,
	npc_sedgelin_ghost_rubin,
	npc_sedgelin_gator,
	npc_sedgelin_gator2
]

# keep track of the npc that is currently being interacted with
var active_npc = null

func talk_to_npc(unit, npc = null, dialogue_before_changer = 0, dialogue_after_changer = 0, dialogue_setter = null, quest_condition_bypass = false):
	if (unit):
		active_unit = unit
	
	if (npc):
		active_npc = npc
		
	# some npcs are scary, and the unit must have some courage to speak with them
	if (npc && npc.has("scary") && npc.scary && unit.courage == 0):
		# the unit is too spooked to talk to the npc...
		player.hud.typeTextWithBuffer(active_unit.unit_name + constants.TOO_SPOOKED, false, "finished_viewing_text_generic")
		yield(signals, "finished_viewing_text_generic")
		player.player_state = player.PLAYER_STATE.SELECTING_TILE
		return
		
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

func get_npc_by_name(name):
	# return the corresponding NPC
	for npc in npcs:
		if (name == npc.name):
			return npc
			
	return null
	
func get_npc_by_pos(pos):
	# return the corresponding NPC
	for npc in npcs:
		if (pos.x == npc.pos_x && pos.y == npc.pos_y):
			return npc
			
	return null

func check_npc_conditions(active_npc, active_unit):
	# if the unit is an innkeeper, and the npc is already staying here
	if (active_npc.has("innkeeper") && active_unit.active_inn != null && 
			active_unit.active_inn.name == active_npc.innkeeper.name):
		return 3
	# check if the npc speaks a different language, and the active_unit doesn't have high enough diplomacy
	elif (race_diplomacy_requirements.has(active_npc.race) && active_unit.skill_levels[constants.DIPLOMACY] < race_diplomacy_requirements[active_npc.race]):
		return 0 # return the dialogue for when the unit can't understand
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

func reset_npcs():
	for npc in npcs:
		# every morning, the innkeepers dialogue should reset
		if (npc.has("innkeeper")):
			npc.current_dialogue = 0
			
		# reset any diplomatoc leaders
		if (npc.has("diplomatic_leader")):
			npc.met_with_unit_today = false
			
		# make all npcs visible
		npc.overworld_sprite.visible = true

func _ready():
	initialize_npcs()

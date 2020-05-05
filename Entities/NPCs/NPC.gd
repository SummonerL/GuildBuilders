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

onready var npc_lonely_man_samuel = 	{
	"name": "Samuel",
	"region": 0, # guild region
	"quests_initiated": [
		guild.quest_friend_wanted
	],
	"initial_dialogue": "I could sure use a friend...",
	"random_dialogue": [],
	"current_dialogue": 0, # initial dialogue
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

func talk_to_npc(npc = null):
	if (npc):
		active_npc = npc
		
	player.hud.typeTextWithBuffer(active_npc.initial_dialogue, false, "finished_viewing_text_generic")
	yield(signals, "finished_viewing_text_generic")
	
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

extends Node2D

# This scene keeps track of all of the npcs in the overworld

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in our player globals
onready var player_globals = get_node("/root/Player_Globals")

# bring in our guild variables/functions
onready var guild = get_node("/root/Guild")

onready var npc_lonely_man_samuel = 	{
	"name": "Samuel",
	"region": 0, # guild region
	"quests_initiated": [
		guild.quest_friend_wanted
	],
	"overworld_sprite": get_node("Lonely_Man_Samuel_Sprite"),
	"pos_x": 16,
	"pos_y": 25
}

# keep track of all the npcs
onready var npcs = [
	npc_lonely_man_samuel
]

func initialize_npcs():
	# position each npc onto the map
	for npc in npcs:
		npc.overworld_sprite.position = Vector2(npc.pos_x*constants.TILE_WIDTH, npc.pos_y*constants.TILE_HEIGHT)

func _ready():
	initialize_npcs()

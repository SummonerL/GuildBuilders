extends CanvasLayer

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in our guild variables/functions
onready var guild = get_node("/root/Guild")

# bring in the global player variables
onready var player = get_node("/root/Player_Globals")

# bring in our signals
onready var signals = get_node("/root/Signal_Manager")

# the letters and symbol scene
onready var letters_symbols_obj = preload("res://Entities/HUD/Letters_Symbols/Letters_Symbols.tscn")
var letters_symbols_node

# the quest window sprite
onready var window_sprite = get_node("Quest_Completion_Window_Sprite")

onready var quest_icon_sprite = get_node("Quest_Icon_Sprite")

# the item received sound
onready var item_get_sound = get_node("Item_Get_Sound")

# the quest completed fanfare
onready var quest_completion_fanfare = get_node("Quest_Completion_Fanfare")

# constants
const GOT_TEXT = 'Received'
const QUEST_TEXT = 'Quest '
const COMPLETED_TEXT = 'Completed!'

const YOU_COMPLETED_QUEST_TEXT = 'You completed a quest!'

const SENT_TO_DEPOT_TEXT = 'Quest reward sent to depot...'

const WINDOW_WIDTH = 8
const WINDOW_HEIGHT = 4

const WINDOW_WIDTH_IN_DIA = 16
const WINDOW_HEIGHT_IN_DIA = 8

var pos_x
var pos_y

func window_init():
	# middle	
	
	pos_x = ((constants.DIA_TILES_PER_ROW * constants.DIA_TILE_WIDTH) / 2 ) - (WINDOW_WIDTH * constants.DIA_TILE_WIDTH)
	pos_y = 4 * constants.DIA_TILE_WIDTH
	window_sprite.position = Vector2(pos_x, pos_y)

	letters_symbols_node = letters_symbols_obj.instance()
	add_child(letters_symbols_node)
	
	# set icon positions
	quest_icon_sprite.position.x = pos_x + constants.DIA_TILE_WIDTH
	quest_icon_sprite.position.y = pos_y + constants.DIA_TILE_HEIGHT
	
	letters_symbols_node.print_immediately(QUEST_TEXT, Vector2((WINDOW_WIDTH + 3) - floor(len(QUEST_TEXT) / 2.0),
		(pos_y / constants.DIA_TILE_HEIGHT) + 1))
	
	letters_symbols_node.print_immediately(COMPLETED_TEXT, Vector2((WINDOW_WIDTH + 3) - floor(len(COMPLETED_TEXT) / 2.0),
		(pos_y / constants.DIA_TILE_HEIGHT) + 2))
		

func set_quest_name(quest, unit):
	var quest_name =  quest.name
	
	# print the quest name
	letters_symbols_node.print_immediately(quest_name, Vector2((WINDOW_WIDTH + 2) - floor(len(quest_name) / 2.0),
		(pos_y / constants.DIA_TILE_HEIGHT) + 5))
		
	# wait 1 second
	yield(get_tree().create_timer(1), "timeout")
		
	# temporarily pause the background music to play the fanfare
	get_tree().get_current_scene().pause_background_music()
		
	# play quest completion fanfare
	quest_completion_fanfare.play()
	
	yield(quest_completion_fanfare, "finished")
	
	# resume the background music
	get_tree().get_current_scene().resume_background_music()
	
	# now read the follow-up text
	player.hud.typeTextWithBuffer(YOU_COMPLETED_QUEST_TEXT, false, "finished_viewing_text_generic")
	
	yield(signals, "finished_viewing_text_generic")
	
	player.hud.typeTextWithBuffer(quest.completion_text, false, "finished_viewing_text_generic")
	
	yield(signals, "finished_viewing_text_generic")
	
	# determine if there is a reward and, if so, whether or not the unit can receive it
	if (quest.has("reward") && quest.reward != null):
		# we have an item reward
		var reward = quest.reward
		
		# determine whether or not the unit can receive this reward
		if (!unit.is_inventory_full()):
			get_parent().global_items_list.add_item_to_unit(unit, reward)
		else:
			# send the item to the depot
			get_parent().add_item_to_depot(reward)
			
			# read sent to depot text
			player.hud.typeTextWithBuffer(SENT_TO_DEPOT_TEXT, false, "finished_viewing_text_generic")
			
			yield(signals, "finished_viewing_text_generic")
			
	# check for any quest specific actions/rewards
	match(quest.name):
		guild.QUEST_HORSE_RESCUE_NAME:
			# the Skyheart horse npc needs to be moved 
			var npc = get_tree().get_current_scene().npcs.npc_horse_skyheart
			var farmer_fred = get_tree().get_current_scene().npcs.npc_farmer_fred

			# and the l2 tile
			var horse_id = get_tree().get_current_scene().l2_tiles.get_cellv(Vector2(npc.pos_x, npc.pos_y))
			get_tree().get_current_scene().l2_tiles.set_cellv(Vector2(npc.pos_x, npc.pos_y), -1) # clear the tile
			get_tree().get_current_scene().l2_tiles.set_cellv(Vector2(38, 8), horse_id) # set the horse l2 tile
			
			npc.pos_x = 38
			npc.pos_y = 8
			
			# update farmer fred's dialogue
			farmer_fred.current_dialogue = 3
			
			# reposition all the npcs
			get_tree().get_current_scene().npcs.initialize_npcs()
			
			# set the BM wm icon + Beast Mastery 5 action spot
			var map_actions = get_tree().get_nodes_in_group(constants.MAP_ACTIONS_GROUP)[0]
			var animal_action_id = map_actions.tile_set.find_tile_by_name("Beast_Mastery_Spot_5") # tame horse action spot
			map_actions.set_cellv(Vector2(38, 8), animal_action_id)
			
			# bm icon
			var map_icons = get_tree().get_nodes_in_group(constants.MAP_ICONS_GROUP)[0]
			var tileset = map_icons.get_tileset()
			
			map_icons.set_cellv(Vector2(38, 8), tileset.find_tile_by_name("beast_mastery_spot_icon")) # the bm icon
			
	
	# turn the music back up
	get_tree().get_current_scene().heighten_background_music()
	
	# set the state back
	player.player_state = player.PLAYER_STATE.SELECTING_TILE
	
	# kill ourself :(
	get_parent().remove_child(self)

func _ready():
	window_init()

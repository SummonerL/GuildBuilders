extends CanvasLayer

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# our hidden_region tilemap
onready var hidden_tm = get_node("hidden_regions")

# 20 map regions (5 x 4)
onready var map_regions = [
	{
		"name": '1',
		"hidden": true,
		"pos": Vector2(0, 0)
	},
	{
		"name": '2',
		"hidden": true,
		"pos": Vector2(1, 0)
	},
	{
		"name": '3',
		"hidden": true,
		"pos": Vector2(2, 0)
	},
	{
		"name": '4',
		"hidden": true,
		"pos": Vector2(3, 0)
	},
	{
		"name": '5',
		"hidden": true,
		"pos": Vector2(4, 0)
	},
	{
		"name": '6',
		"hidden": true,
		"pos": Vector2(0, 1)
	},
	{
		"name": '7',
		"hidden": true,
		"pos": Vector2(1, 1)
	},
	{
		"name": '8',
		"hidden": true,
		"pos": Vector2(2, 1)
	},
	{
		"name": '9',
		"hidden": true,
		"pos": Vector2(3, 1)
	},
	{
		"name": '10',
		"hidden": true,
		"pos": Vector2(4, 1)
	},
	{
		"name": '11',
		"hidden": true,
		"pos": Vector2(0, 2)
	},
	{
		"name": 'Sedgelin Swamplands',
		"hidden": true,
		"pos": Vector2(1, 2)
	},
	{
		"name": 'Guild Region',
		"hidden": false,
		"pos": Vector2(2, 2)
	},
	{
		"name": 'Bellmare Region',
		"hidden": true,
		"pos": Vector2(3, 2)
	},
	{
		"name": '15',
		"hidden": true,
		"pos": Vector2(4, 2)
	},
	{
		"name": '16',
		"hidden": true,
		"pos": Vector2(0, 3)
	},
	{
		"name": '17',
		"hidden": true,
		"pos": Vector2(1, 3)
	},
	{
		"name": '18',
		"hidden": true,
		"pos": Vector2(2, 3)
	},
	{
		"name": '19',
		"hidden": true,
		"pos": Vector2(3, 3)
	},
	{
		"name": '20',
		"hidden": true,
		"pos": Vector2(4, 3)
	},
]

func world_map_init():
	# hide all of the regions that should be hidden
	var hidden_tile_id = hidden_tm.tile_set.find_tile_by_name("hidden_tile")
	for region in map_regions:
		# determine if the regions should be hidden or not (this should be shortened once all the regions are created in constants)
		for const_region in constants.regions:
			if (const_region.name == region.name):
				region.hidden = const_region.hidden
	
		if (region.hidden):
			hidden_tm.set_cellv(Vector2(region.pos.x * 4, (region.pos.y) * 4 + 1), hidden_tile_id)

func _ready():
	world_map_init()
	
func _input(event):
	if (event.is_action_pressed("ui_cancel")):
		get_parent().kill_world_map_screen()

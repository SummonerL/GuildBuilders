extends Node2D

const TILE_HEIGHT = 16
const TILE_WIDTH = 16
const TILES_PER_ROW = 10
const DIA_TILE_WIDTH = 8
const DIA_TILE_HEIGHT = 8
const DIA_TILES_PER_ROW = 20
const DIA_TILES_PER_COL = 18
const TILES_PER_COL = 9
const SCREEN_HEIGHT = 144
const SCREEN_WIDTH = 160

const MAP_TILES_GROUP = 'map_tiles'
const GRID_SQUARE_GROUP = 'grid_square'
const TILE_INFO_GROUP = 'tile_info'
const TIME_OF_DAY_INFO_GROUP = 'time_of_day_info'
const MAP_ICONS_GROUP = 'map_icons'
const MAP_ACTIONS_GROUP = 'map_actions'
const HIDDEN_TILES_GROUP = 'hidden_tiles'

const ABILITY_TEXT = "ABILITIES"

const CHECK_SYMBOL = '¤' #164
const X_SYMBOL = 'µ' #181
const EAST_SYMBOL = '→'
const WEST_SYMBOL = '←'

const EXCLAMATION = '!'

const CANT_MOVE = 999999

const SHORT_DELAY = .5

const MOVE_ANIM_SPEED = .015 # how fast the player moves to the target tile

const GAME_VOLUME = -2

const ASLEEP_X = -1500
const ASLEEP_Y = -1500

enum DIRECTIONS {
	UP,
	RIGHT,
	DOWN,
	LEFT
}

enum SIDES {
	LEFT,
	RIGHT
}

enum TOP_BOTTOM {
	TOP,
	BOTTOM
}

enum SPECIAL_SYMBOLS {
	RIGHT_ARROW,
	LEFT_ARROW,
	DOWN_ARROW,
	UP_ARROW
}

enum UNIT_TYPES {
	ANGLER_MALE,
	ANGLER_FEMALE,
	WOODCUTTER_MALE,
	WOODCUTTER_FEMALE,
	WOODWORKER_MALE,
	WOODWORKER_FEMALE,
	MINER_MALE,
	MINER_FEMALE
}

# times of day
const TIMES_OF_DAY = [
	"12AM",
	"1AM",
	"2AM",
	"3AM",
	"4AM",
	"5AM",
	"6AM",
	"7AM",
	"8AM",
	"9AM",
	"10AM",
	"11AM",
	"12PM",
	"1PM",
	"2PM",
	"3PM",
	"4PM",
	"5PM",
	"6PM",
	"7PM",
	"8PM",
	"9PM",
	"10PM",
	"11PM"
]

# keep track of all the regions / zones in the game (they are all 30x30, so add that to x/y when considering boundaries)
var regions = [
	{
		'name': 'Guild Region',
		'x': 0,
		'y': 0,
		'hidden': false # whether or not this region is visible to the player
	},
	{
		'name': 'Region North 1', # will change
		'x': 0,
		'y': -30,
		'hidden': true
	},
	{
		'name': 'Region East 1', # will change
		'x': 30,
		'y': 0,
		'hidden': false
	},
	{
		'name': 'Region South 1', # will change
		'x': 0,
		'y': 30,
		'hidden': true
	},
	{
		'name': 'Region West 1', # will change
		'x': -30,
		'y': 0,
		'hidden': true
	},
	{
		'name': 'Region Northeast 1', # will change
		'x': 30,
		'y': -30,
		'hidden': true
	},
	{
		'name': 'Region Southeast 1', # will change
		'x': 30,
		'y': 30,
		'hidden': true
	},
	{
		'name': 'Region Southwest 1', # will change
		'x': -30,
		'y': 30,
		'hidden': true
	},
	{
		'name': 'Region Northwest 1', # will change
		'x': -30,
		'y': -30,
		'hidden': true
	},
]

# map boundaries
const NORTH_BOUNDARY = -30
const EAST_BOUNDARY = 59
const SOUTH_BOUNDARY = 59
const WEST_BOUNDARY = -30

# keep track of all the signs in the game world
var sign_list = [
	{
		'pos': Vector2(29, 8),
		'text': WEST_SYMBOL + ' Guild         ' + EAST_SYMBOL + ' Bellmare'
	},
	{
		'pos': Vector2(36, 8),
		'text': 'Bellmare Ranch'
	},
	{
		'pos': Vector2(50, 6),
		'text': 'Welcome to Bellmare!'
	},
]

# useful function for returning the sign text at given coordinates
func get_sign_text(pos):
	for the_sign in sign_list:
		if (the_sign.pos == pos):
			return the_sign.text
	return ''

# experience required for each level
var experience_required = [
	0,
	4,
	6,
	8,
	10,
	12,
	14,
	16,
	17,
	18,
	20,
	22,
	24,
	26,
	28,
	30,
	32,
	34,
	36,
	38,
	40
]

# skill names
const FISHING = 'fishing'
const MINING = 'mining'
const WOODCUTTING = 'woodcutting'
const WOODWORKING = 'woodworking'
const SMITHING = 'smithing'

# skill pretty names
const FISHING_PRETTY = 'Fishing'
const MINING_PRETTY = 'Mining'
const WOODCUTTING_PRETTY = 'Woodcutting'
const WOODWORKING_PRETTY = 'Woodworking'
const SMITHING_PRETTY = 'Smithing'

# text commonly used across different screens
const LVL_TEXT = "Lv."
const NEXT_LEVEL_TEXT = "Nxt."

# misc text
const WHERE_SHOULD_I_RETURN_TEXT = 'Where should I return?'

# helper function for chance tests, based on a passed percentage
func chance_test(percent):
	var rng = RandomNumberGenerator.new()
	rng.randomize() # seed the generator based on time
	var num = rng.randi_range(1, 100)
	
	if (num <= percent):
		return true
	else:
		return false

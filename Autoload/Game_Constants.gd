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

const CANT_MOVE = 999999

const MOVE_ANIM_SPEED = .015 # how fast the player moves to the target tile

const GAME_VOLUME = -2

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
	WOODCUTTER_FEMALE
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

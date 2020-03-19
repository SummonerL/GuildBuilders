extends Node2D

const TILE_HEIGHT = 16
const TILE_WIDTH = 16
const TILES_PER_ROW = 10
const DIA_TILES_PER_ROW = 20
const DIA_TILES_PER_COL = 32
const TILES_PER_COL = 9
const SCREEN_HEIGHT = 144
const SCREEN_WIDTH = 160

const MAP_TILES_GROUP = 'map_tiles'
const GRID_SQUARE_GROUP = 'grid_square'
const TILE_INFO_GROUP = 'tile_info'

const CANT_MOVE = 999999

const MOVE_ANIM_SPEED = .015 # how fast the player moves to the target tile

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

enum UNIT_TYPES {
	ANGLER_MALE,
	ANGLER_FEMALE
}

extends Node

onready var movement_grid_square = preload("res://Entities/Player/Movement_Grid_Square.tscn")
# units can inherit from this class to access common variables

# the unit's position on the map
var unit_pos_x = 0
var unit_pos_y = 0

# the unit's base movement (can be modified)
var base_move = 0

# the unit's name
var unit_name = ""

# functions global to all unit types
func show_movement_grid_square(pos_x, pos_y):
	var square = movement_grid_square.instance()
	add_child(square)
	square.set_square_position(pos_x, pos_y)

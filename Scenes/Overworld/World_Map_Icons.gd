extends TileMap


const ICONS = {
	14: 'FISH',
	15: 'MINE',
	16: 'CHOP'
}

# list of icons in which still apply when adjacent
const adjacent_applicable = [
	'FISH'
]

func get_icon_at_coordinates(vec2):
	var tile = get_cellv(vec2)
	if (tile >= 0):
		return ICONS[get_cellv(vec2)]
	else:
		return null

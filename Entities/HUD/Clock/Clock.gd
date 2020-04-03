extends CanvasLayer

# bring in our global constants
onready var constants = get_node("/root/Game_Constants")

# bring in the global player variables
onready var player = get_node("/root/Player_Globals")

const CLOCK_WIDTH = 6 # 6 8px sprites wide
const CLOCK_HEIGHT = 6 # 6 8px sprites high

onready var one = get_node("Clock_1_Sprite")
onready var two = get_node("Clock_2_Sprite")
onready var three = get_node("Clock_3_Sprite")
onready var four = get_node("Clock_4_Sprite")
onready var five = get_node("Clock_5_Sprite")
onready var six = get_node("Clock_6_Sprite")
onready var seven = get_node("Clock_7_Sprite")
onready var eight = get_node("Clock_8_Sprite")
onready var nine = get_node("Clock_9_Sprite")
onready var ten = get_node("Clock_10_Sprite")
onready var eleven = get_node("Clock_11_Sprite")
onready var twelve = get_node("Clock_12_Sprite")

onready var clocks = [
	twelve,
	one,
	two,
	three,
	four,
	five,
	six,
	seven,
	eight,
	nine,
	ten,
	eleven
]

const CLOCK_ANIM_TIME = 1

func clock_init():
	var middle_screen = Vector2(((constants.DIA_TILES_PER_ROW - CLOCK_WIDTH) / 2) * constants.DIA_TILE_WIDTH, 
								((constants.DIA_TILES_PER_COL - CLOCK_HEIGHT) / 2) * constants.DIA_TILE_HEIGHT)
	one.position = middle_screen
	two.position = middle_screen
	three.position = middle_screen
	four.position = middle_screen
	five.position = middle_screen
	six.position = middle_screen
	seven.position = middle_screen
	eight.position = middle_screen
	nine.position = middle_screen
	ten.position = middle_screen
	eleven.position = middle_screen
	twelve.position = middle_screen
	
	var time_now = player.current_time_of_day
	var time_before = player.current_time_of_day - 1
	if time_before < 0:
		time_before = 23
	
	if time_now >= 12:
		time_now -= 12
		
	if time_before >= 12:
		time_before -= 12
	
	clocks[time_before].visible = true
	
	var timer = Timer.new()
	timer.wait_time = CLOCK_ANIM_TIME
	timer.connect("timeout", self, "show_time_now", [time_before, time_now, timer])
	add_child(timer)
	timer.start()

func show_time_now(time_before, time_now, timer = null):
	if (timer):
		timer.stop()
		remove_child(timer)
		
	clocks[time_before].visible = false
	clocks[time_now].visible = true
	
	var kill_timer = Timer.new()
	kill_timer.wait_time = CLOCK_ANIM_TIME
	kill_timer.connect("timeout", self, "kill_clock", [kill_timer])
	add_child(kill_timer)
	kill_timer.start()
	
func kill_clock(timer = null):
	if (timer):
		timer.stop()
		remove_child(timer)
		
	player.party.reset_shaders()
		
	get_parent().remove_child(self)

func _ready():
	clock_init()

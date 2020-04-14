extends CanvasLayer

signal scene_faded_out()
signal scene_faded_in()

onready var animation_player = $AnimationPlayer
onready var white_in = $White_In_Control
onready var white_out = $White_Out_Control

func fade_in_scene(delay = 2):
	yield(get_tree().create_timer(delay), "timeout")
	animation_player.play("Fade_In")
	yield(animation_player, "animation_finished")
	emit_signal("scene_faded_in")
	
	
func fade_out_scene(delay = 2):
	yield(get_tree().create_timer(delay), "timeout")
	animation_player.play("Fade_Out")
	yield(animation_player, "animation_finished")
	emit_signal("scene_faded_out")

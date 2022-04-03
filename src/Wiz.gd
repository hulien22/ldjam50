extends Node2D

func update_color(face_color: Color, body_color: Color, arms_color: Color, animate: bool):
	print(face_color, body_color, arms_color, animate)
	$Face.modulate = face_color
	$Body.modulate = body_color
	$Arms.modulate = arms_color
	if (animate):
		$Body.frame = 0
		$Arms.frame = 0
		$Body.play("wiz")
		$Arms.play("wizarms")
	else:
		$Body.stop()
		$Arms.stop()
		$Body.frame = 0
		$Arms.frame = 0

func set_animation_frame(frame: int):
	$Body.stop()
	$Arms.stop()
	$Body.frame = frame
	$Arms.frame = frame

func play_once():
	$Body.play("wiz_noloop", true)
	$Arms.play("wizarms_noloop", true)

func set_animation_speed(speed: float):
	print("speed ", speed)
	$Body.speed_scale = speed
	$Arms.speed_scale = speed

func set_level(level: int):
	$Level.frame = level

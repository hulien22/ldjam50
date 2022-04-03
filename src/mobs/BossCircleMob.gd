extends Mob

func _ready():
	health_bar = $HealthBar
	hit_box = $Area2D
	.set_defaults()

func flash_color(c: Color):
	$Aninode.modulate = c
	$AnimationPlayer.stop()
	$AnimationPlayer.play("flashcolor")

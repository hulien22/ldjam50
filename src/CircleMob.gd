extends Mob

func _ready():
	max_health = 20
	speed = 100
	tower_dmg = 1
	health_bar = $HealthBar
	hit_box = $Area2D
	.set_defaults()
	
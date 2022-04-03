extends Mob

func _ready():
	max_health = 100
	speed = 100
	tower_dmg = 1
	health_bar = $HealthBar
	.set_defaults()
	

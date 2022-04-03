extends Node2D

class_name Mob
var colors = [Color.chartreuse, Color.aqua, Color.yellowgreen, Color.yellow, Color.red, Color.royalblue]
var max_health: int
var health: int
var speed: float
var cur_speed: float
var tower_dmg: int

var remote_position_node: PathFollow2D
var health_bar: TextureProgress

func set_defaults():
	health = max_health
	cur_speed = speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if remote_position_node:
		remote_position_node.offset += speed * delta

func on_hit(damage: float = 0, knockback: float = 0, dot_dmg: float = 0, dot_time: float = 0, dot_rate: float = 0):
	health -= damage
	health_bar.value = 100.0 * health / max_health
	if (health <= 0):
		on_destroy()
		return
	if (knockback):
		pass
		
func on_destroy():
	if remote_position_node:
		remote_position_node.get_parent().queue_free()
	self.queue_free()

func get_path_progress() -> float:
	if remote_position_node:
		return remote_position_node.offset
	return 0.0

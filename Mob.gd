extends Node2D

class_name Mob
var colors = [Color.chartreuse, Color.aqua, Color.yellowgreen, Color.yellow, Color.red, Color.royalblue]
var max_health: int
var health: int
var speed: float
var cur_speed: float
var tower_dmg: int
var mob_id: int = Generator.generate_mob_id()

var hit_box: Area2D
var remote_position_node: PathFollow2D
var health_bar: TextureProgress
var game

func set_defaults():
	health = max_health
	cur_speed = speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if remote_position_node:
		remote_position_node.offset += speed * delta
		if remote_position_node.unit_offset == 1.0:
			#TODO deal damage to fort
			on_destroy(tower_dmg)

func on_hit(damage: float = 0, knockback: float = 0, dot_dmg: float = 0, dot_time: float = 0, dot_rate: float = 0):
	health -= damage
	health_bar.value = 100.0 * health / max_health
	if (health <= 0):
		on_destroy()
		return
	if (knockback):
		pass
		
func on_destroy(damage_to_tower: int = 0):
	game.destroy_mob(mob_id, damage_to_tower)
	if remote_position_node:
		remote_position_node.queue_free()
		remote_position_node = null
	self.queue_free()

func get_path_progress() -> float:
	if remote_position_node:
		return remote_position_node.offset
	return 0.0

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

func set_vals(mh, s, td):
	max_health = mh
	speed = s
	tower_dmg = td

func set_defaults():
	health = max_health
	cur_speed = speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if remote_position_node:
		remote_position_node.offset += cur_speed * delta
		if remote_position_node.unit_offset == 1.0:
			#TODO deal damage to fort
			on_destroy(tower_dmg)
	

func on_hit(damage: float = 0, knockback: float = 0, slowdown: float = 0, poison: float = 0) -> bool:
	health -= damage
	health_bar.value = 100.0 * health / max_health
	if (health <= 0):
		on_destroy()
		return true
	if (knockback):
		if remote_position_node:
			remote_position_node.offset -= knockback
	if (slowdown):
		cur_speed *= slowdown
		var tmr = Timer.new()
		add_child(tmr)
		tmr.connect("timeout", self, "_speed_up", [slowdown])
		tmr.one_shot = true
		tmr.start(1)
	if (poison > 0):
		var tmr = Timer.new()
		add_child(tmr)
		tmr.connect("timeout", self, "_deal_poison", [poison])
		tmr.one_shot = true
		tmr.start(0.6)
	return false

func _deal_poison(dmg: float):
	flash_color(ColorN("hotpink"))
	on_hit(dmg, 0, 0, dmg - Global.poison_sub)

func _speed_up(v: float):
	cur_speed = min(speed, cur_speed / v)

func flash_color(c: Color):
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

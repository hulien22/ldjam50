extends Node2D

const INVALID = Vector2(-1,-1)

var shape
var damage: float
var size: float
var timer_timeout: float
var color: Color
var knockback: float
var slowdown: float
var poison: float
var tower

var target: Vector2
var source: Vector2

func set_values(twr, shp, dmg: float, sz: float, tgt: Vector2, src: Vector2, tmr_timeout: float, clr: Color, knk: float, slw: float, psn: float):
	shape = shp
	damage = dmg
	size = sz
	target = tgt
	source = src
	timer_timeout = tmr_timeout
	color = clr
	knockback = knk
	slowdown = slw
	poison = psn
	tower = twr

func _ready():
	self.modulate = color
	if color == Color(1, 0.84, 0, 1):  # nice lightning effect
		$AnimNode.modulate.a = 0.5
	elif timer_timeout >= 1:
		$AnimNode.modulate.a = 0.1
	$AnimNode.modulate.a
	match shape:
		DB.towers.Atktyp.SINGLE_TARGET:
			#TODO figure out scaling issues here
			$AnimNode/Narrow.scale.x *= abs(target.distance_to(source)) / 0.36
			$AnimNode/Narrow.look_at(target)
			global_position = (target + source) / 2.0
			$AnimNode/Narrow.show()
			# Just animate
			$AnimationPlayer.play("FadeAway")
			return
		DB.towers.Atktyp.CIRCLE:
			$AnimNode/Circle.scale *= size
			global_position = target
			$AnimNode/Circle.show()
			var detect_circle = CircleShape2D.new()
			detect_circle.radius = size * 250
			var col_shp = CollisionShape2D.new()
			col_shp.shape = detect_circle
			$DetectArea.add_child(col_shp)
		DB.towers.Atktyp.SELF_CIRCLE:
			$AnimNode/Circle.scale *= size
			global_position = source
			$AnimNode/Circle.show()
			var detect_circle = CircleShape2D.new()
			detect_circle.radius = size * 250
			var col_shp = CollisionShape2D.new()
			col_shp.shape = detect_circle
			$DetectArea.add_child(col_shp)
		DB.towers.Atktyp.SELF_SQUARE:
			$AnimNode/Square.scale *= size
			global_position = source
			$AnimNode/Square.show()
			var detect_rect = RectangleShape2D.new()
			detect_rect.extents = Vector2(1,1) * size
			var col_shp = CollisionShape2D.new()
			col_shp.shape = detect_rect
			$DetectArea.add_child(col_shp)
		DB.towers.Atktyp.LINE:
			var detect_rect = RectangleShape2D.new()
			detect_rect.extents = Vector2(1 * size, 125)
			var col_shp = CollisionShape2D.new()
			col_shp.shape = detect_rect
			col_shp.position.x = size
			$DetectArea.add_child(col_shp)
			$AnimNode/Line.scale.x *= size
			global_position = source
			look_at(target)
			$AnimNode/Line.show()
	
	yield(get_tree().create_timer(timer_timeout), "timeout")
	deal_damage()
	$AnimationPlayer.play("FadeAway")

func deal_damage():
	var nodes = $DetectArea.get_overlapping_areas()
	for n in nodes:
		if n.get_parent().on_hit(damage, knockback, slowdown, poison):
			# on kill
			tower.on_kill()
		
	$DetectArea.hide()

func _on_AnimationPlayer_animation_finished(anim_name):
	self.queue_free()

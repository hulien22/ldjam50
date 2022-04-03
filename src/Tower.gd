extends Node2D

class_name Tower

const INVALID = Vector2(-1,-1)

var name_: String
var level_: int
var row_ # : DB.Towers.TowersRow

# ctor
func set_val(name: String, level: int):
	name_ = name
	level_ = level
	row_ = DB.towers.get(name_ + "_" + str(level_))
	var detect_circle = CircleShape2D.new()
	detect_circle.radius = row_.atkrng * 250 # MAGIC NUMBERS :D
	$DetectArea/Circle.shape = detect_circle
	$FireTimer.wait_time = row_.atkspd
	update_sprite()

func update_sprite():
	#$Wiz.set_animation_speed(10.0 / row_.atkspd)
	$Wiz.update_color(ColorN(row_.facecolor), ColorN(row_.bodycolor), ColorN(row_.armcolor), true)
	$Wiz.set_level(level_ - 1)

func start_combat():
	$Wiz.set_animation_frame(0)
	# If atkspd is 0, then we only do stuff on round end.
	if row_.atkspd > 0:
		_on_FireTimer_timeout()

func stop_combat():
	update_sprite()
	$FireTimer.stop()
	if $DetectArea.is_connected("area_entered", self, "try_shoot"):
		$DetectArea.disconnect("area_entered", self, "try_shoot")
	# If atkspd is 0, then we only do stuff on round end.
	if row_.atkspd == 0:
		#TODO
		print("end of round")

func _on_FireTimer_timeout():
	if Global.game_state == Global.GAME_STATE.COMBAT:
		try_shoot()

# We ignore area, only specified so area_entered can use this.
func try_shoot(area = null):
	if $DetectArea.is_connected("area_entered", self, "try_shoot"):
		$DetectArea.disconnect("area_entered", self, "try_shoot")
	var target = has_enemy_to_shoot()
	if (target == INVALID):
		$DetectArea.connect("area_entered", self, "try_shoot")
	else:
		shoot(target)
		$Wiz.play_once()
		$FireTimer.start()

func has_enemy_to_shoot() -> Vector2:
	var nodes = $DetectArea.get_overlapping_areas()
	if nodes.empty():
		return INVALID
	var max_i: int = 0
	var max_offset: float = 0.0
	for i in nodes.size():
		print(nodes[i].get_parent().get_path_progress())
		if (nodes[i].get_parent().get_path_progress() > max_offset):
			i = max_i
			max_offset = nodes[i].get_parent().get_path_progress()
	return nodes[max_i].get_parent().global_position

func shoot(target: Vector2):
	print("shoot!", target)

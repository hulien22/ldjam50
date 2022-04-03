extends Node2D

class_name Tower

const INVALID = Vector2(-1,-1)

const aoe_scene = preload("res://src/AOE.tscn")

var name_: String
var level_: int
var row_ # : DB.Towers.TowersRow
var atkdmg: float
var atkspd: float
var atkrng: float
var atktypsz: float
var knockback: float
var slowdown: float
var poison: float

var game

# ctor
func set_val(name: String, level: int):
	name_ = name
	level_ = level
	row_ = DB.towers.get(name_ + "_" + str(level_))
	var detect_circle = CircleShape2D.new()
	detect_circle.radius = row_.atkrng * 250 # MAGIC NUMBERS :D
	$DetectArea/Circle.shape = detect_circle
	if row_.atktyp == DB.towers.Atktyp.BUFF_RNG || row_.atktyp == DB.towers.Atktyp.BUFF_SPD || row_.atktyp == DB.towers.Atktyp.BUFF_DMG:
		$DetectArea.collision_mask = 0
	else:
		$DetectArea.collision_layer = 0
	if row_.atkspd > 0:
		$FireTimer.wait_time = row_.atkspd
	update_sprite()

func update_sprite():
	#$Wiz.set_animation_speed(10.0 / row_.atkspd)
	$Wiz.update_color(ColorN(row_.facecolor), ColorN(row_.bodycolor), ColorN(row_.armcolor), true)
	$Wiz.set_level(level_ - 1)

func start_combat():
	update_stats()
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
		match row_.atktyp:
			DB.towers.Atktyp.GAIN_GOLD:
				game.update_gold(row_.atktypsz)

func _on_FireTimer_timeout():
	if Global.game_state == Global.GAME_STATE.COMBAT:
		try_shoot()

# We ignore area, only specified so area_entered can use this.
func try_shoot(area = null):
	if $DetectArea.is_connected("area_entered", self, "try_shoot"):
		$DetectArea.disconnect("area_entered", self, "try_shoot")
	var target = has_enemy_to_shoot()
	if (target == null):
		$DetectArea.connect("area_entered", self, "try_shoot")
	else:
		shoot(target, Global.gold_shots)
		$Wiz.play_once()
		$FireTimer.start()

func has_enemy_to_shoot() -> Mob:
	var nodes = $DetectArea.get_overlapping_areas()
	if nodes.empty():
		return null
	var max_i: int = 0
	var max_offset: float = 0.0
	for i in nodes.size():
		if (nodes[i].get_parent().get_path_progress() > max_offset):
			i = max_i
			max_offset = nodes[i].get_parent().get_path_progress()
	return nodes[max_i].get_parent()

func shoot(target: Mob, goldshots: int = 0):
	match row_.atktyp:
		DB.towers.Atktyp.SINGLE_TARGET:
			# Just deal damage directly for single target
			var aoe = aoe_scene.instance()
			aoe.set_values(self, row_.atktyp, atkdmg, atktypsz, target.global_position, self.global_position, 0, ColorN(row_.facecolor), knockback, slowdown, poison)
			call_deferred("add_child", aoe)
			if target.on_hit(row_.atkdmg, knockback, slowdown, poison):
				on_kill()
		_:  # else send the damage 
			if name_ == "Mercenary":
				atkdmg = game.gold
				
			if row_.facecolor == "dodgerblue" || row_.bodycolor == "dodgerblue":
				if Generator.rng.randi() % 100 < Global.crit_chance:
					atkdmg *= 3.0
			
			var aoe = aoe_scene.instance()
			aoe.set_values(self, row_.atktyp, atkdmg, atktypsz, target.global_position, self.global_position, row_.delay, ColorN(row_.facecolor), knockback, slowdown, poison)
			call_deferred("add_child", aoe)
	
	if row_.facecolor == "gold" || row_.bodycolor == "gold":
		if goldshots > 0:
			var tmr = Timer.new()
			add_child(tmr)
			tmr.connect("timeout", self, "gold_shoot", [goldshots-1])
			tmr.one_shot = true
			tmr.start(0.1)

func gold_shoot(goldshots: int = 0):
	var target = has_enemy_to_shoot()
	if (target != null):
		shoot(target, goldshots - 1)
		$Wiz.play_once()

func update_stats():
	atkdmg = row_.atkdmg * Global.global_dmg_percent
	atkspd = row_.atkspd * Global.global_spd_percent
	atkrng = row_.atkrng
	atktypsz = row_.atktypsz
	knockback = row_.knockback
	slowdown = row_.slowdown
	poison = row_.poison
	var nodes = $BuffArea.get_overlapping_areas()
	for n in nodes:
		match n.get_parent().row_.atktyp:
			DB.towers.Atktyp.BUFF_RNG:
				atkrng *= n.get_parent().row_.atkdmg
			DB.towers.Atktyp.BUFF_DMG:
				atkdmg *= n.get_parent().row_.atkdmg
			DB.towers.Atktyp.BUFF_SPD:
				atkspd *= n.get_parent().row_.atkdmg
	#TODO global buffs
	
	if row_.facecolor == "crimson" || row_.bodycolor == "crimson":
		atktypsz *= Global.red_aoe_size
	if row_.facecolor == "cyan" || row_.bodycolor == "cyan":
		slowdown *= Global.slowdown_percent
	if row_.facecolor == "rebeccapurple" || row_.bodycolor == "rebeccapurple":
		knockback *= Global.knockback_percent

	$DetectArea/Circle.shape.radius = atkrng * 250
	if atkspd > 0:
		$FireTimer.wait_time = atkspd * 0.5

func on_kill():
	match name_:
		"Thief":
			game.update_gold(1)
	pass

func _on_SelectBtn_mouse_entered():
	update_stats()
	$Whitecircle.scale = Vector2(1,1) * atkrng
	$Whitecircle.show()
	Global.tower_label.init_text(name_, str(level_))
	Global.show_tower_label(global_position.x > 612)

func _on_SelectBtn_mouse_exited():
	$Whitecircle.hide()
	Global.tower_label.hide()

extends Node2D

class_name Game

# Scenes / Children
var shop_scene = preload("res://src/Shop_DropDown.tscn")
var shop: Shop
var tower_scene = preload("res://src/Tower.tscn")

var circlemob_scene = preload("res://src/mobs/CircleMob.tscn")
var bosscirclemob_scene = preload("res://src/mobs/BossCircleMob.tscn")
var enemies_dict = {}

# Member variables
var xp: int = 0
var level: int = 0
var gold: int = 0
var health: int = 100
var wave: int = 0
var bench: Array = ["", "", "", "", "", "", "", ""]
var active_towers: Dictionary = {}
var shop_towers: Array = ["", "", ""]

var cur_carrying: String = ""
var last_location: String = ""
var need_to_dropdown: bool = false

var active_enemies: Dictionary = {}
var spawning: bool = false

func _ready():
	# Update UIs
	update_gold(4)
	increment_level()
	update_wiz_counts()
	increment_wave()
	increment_xp(0)
	update_max_xp()
	
	Global.tower_label = $TowerLabelNode/TowerLabel
	
	# Create shop
	shop = shop_scene.instance()
	shop.set_name("Shop")
#	shop.position = Vector2(580, -1134)
	shop.position = Vector2(260, -230)
	shop.scale *= 0.5
	shop.is_active()
	shop.get_node("aninode/Slot1/Slot1Btn").connect("pressed", self, "_on_shop_buy", [0])
	shop.get_node("aninode/Slot2/Slot2Btn").connect("pressed", self, "_on_shop_buy", [1])
	shop.get_node("aninode/Slot3/Slot3Btn").connect("pressed", self, "_on_shop_buy", [2])
	shop.get_node("aninode/Refresh/RefreshBtn").connect("pressed", self, "_on_refresh_btn")
	shop.get_node("aninode/Lock/LockBtn").connect("pressed", self, "_on_lock_btn")
	shop.get_node("aninode/Upgrade/UpgradeBtn").connect("pressed", self, "_on_upgrade_btn")
	add_child(shop)
	generate_shop()
	
	# Create bench
	# lil' bit of hardcoding
	$Bench/Slot1/Slot1Btn.connect("pressed", self, "_on_bench_click", [0])
	$Bench/Slot1/Slot1Btn.connect("mouse_entered", self, "_on_bench_mouse_enter", [0])
	$Bench/Slot1/Slot1Btn.connect("mouse_exited", self, "_on_bench_mouse_exit", [0])
	$Bench/Slot2/Slot2Btn.connect("pressed", self, "_on_bench_click", [1])
	$Bench/Slot2/Slot2Btn.connect("mouse_entered", self, "_on_bench_mouse_enter", [1])
	$Bench/Slot2/Slot2Btn.connect("mouse_exited", self, "_on_bench_mouse_exit", [1])
	$Bench/Slot3/Slot3Btn.connect("pressed", self, "_on_bench_click", [2])
	$Bench/Slot3/Slot3Btn.connect("mouse_entered", self, "_on_bench_mouse_enter", [2])
	$Bench/Slot3/Slot3Btn.connect("mouse_exited", self, "_on_bench_mouse_exit", [2])
	$Bench/Slot4/Slot4Btn.connect("pressed", self, "_on_bench_click", [3])
	$Bench/Slot4/Slot4Btn.connect("mouse_entered", self, "_on_bench_mouse_enter", [3])
	$Bench/Slot4/Slot4Btn.connect("mouse_exited", self, "_on_bench_mouse_exit", [3])
	$Bench/Slot5/Slot5Btn.connect("pressed", self, "_on_bench_click", [4])
	$Bench/Slot5/Slot5Btn.connect("mouse_entered", self, "_on_bench_mouse_enter", [4])
	$Bench/Slot5/Slot5Btn.connect("mouse_exited", self, "_on_bench_mouse_exit", [4])
	$Bench/Slot6/Slot6Btn.connect("pressed", self, "_on_bench_click", [5])
	$Bench/Slot6/Slot6Btn.connect("mouse_entered", self, "_on_bench_mouse_enter", [5])
	$Bench/Slot6/Slot6Btn.connect("mouse_exited", self, "_on_bench_mouse_exit", [5])
	$Bench/Slot7/Slot7Btn.connect("pressed", self, "_on_bench_click", [6])
	$Bench/Slot7/Slot7Btn.connect("mouse_entered", self, "_on_bench_mouse_enter", [6])
	$Bench/Slot7/Slot7Btn.connect("mouse_exited", self, "_on_bench_mouse_exit", [6])
	$Bench/Slot8/Slot8Btn.connect("pressed", self, "_on_bench_click", [7])
	$Bench/Slot8/Slot8Btn.connect("mouse_entered", self, "_on_bench_mouse_enter", [7])
	$Bench/Slot8/Slot8Btn.connect("mouse_exited", self, "_on_bench_mouse_exit", [7])
	$Trash/Trash/TrashBtn.connect("pressed", self, "_on_trash_click")
	
	$FollowNode/PlaceBtn.connect("gui_input", self, "_on_placement_click")
	
	
	Global.game_state = GLOBAL.GAME_STATE.PREPARING
	$Play/PlayBtn.connect("pressed", self, "_on_play_click")
	$FastForwards/FFBtn.connect("pressed", self, "_on_ff_click")

	enemies_dict["Circle"] = circlemob_scene
	enemies_dict["BossCircle"] = bosscirclemob_scene

func _on_bench_mouse_enter(i: int):
	if !bench[i].empty():
		var twr = bench[i].split("_")
		Global.tower_label.init_text(twr[0], twr[1])
		Global.show_tower_label(false)

func _on_bench_mouse_exit(i: int):
	Global.tower_label.hide()

func combine_towers(active_nodes: Array, bench_nodes: Array, level: int) -> bool:
	if active_nodes.size() + bench_nodes.size() != level:
		return false
	if !active_nodes.empty():
		var name = active_towers[active_nodes[0]].name_
		active_towers[active_nodes[0]].set_val(name, level)
		# remove other nodes
		for i in active_nodes.size():
			if i != 0:
				$EntitiesSort.remove_child(active_towers[active_nodes[i]])
				active_towers.erase(active_nodes[i])
		for i in bench_nodes.size():
			bench[bench_nodes[i]] = ""
			$Bench.update_slot(bench_nodes[i])
	else:
		var twr = bench[bench_nodes[0]].split("_")
		bench[bench_nodes[0]] = twr[0] + "_" + str(level)
		$Bench.update_slot(bench_nodes[0], twr[0], level)
		for i in bench_nodes.size():
			if i != 0:
				bench[bench_nodes[i]] = ""
				$Bench.update_slot(bench_nodes[i])
	#TODO animations?
	return true

func check_for_combines(name: String) -> bool:
	# first check for tier 1s
	var active_nodes = []
	var bench_nodes = []
	for t in active_towers:
		if active_towers[t].name_ == name && active_towers[t].level_ == 1:
			active_nodes.append(t)
	for n in bench.size():
		if bench[n] == name + "_1":
			bench_nodes.append(n)
	if !combine_towers(active_nodes, bench_nodes, 2):
		return false
	# now check for tier twos
	active_nodes.clear()
	bench_nodes.clear()
	for t in active_towers:
		if active_towers[t].name_ == name && active_towers[t].level_ == 2:
			active_nodes.append(t)
	for n in bench.size():
		if bench[n] == name + "_2":
			bench_nodes.append(n)
	combine_towers(active_nodes, bench_nodes, 3)
	# Return true regardless as we did combine something
	update_wiz_counts()
	return true

func _on_shop_buy(i: int):
	if (shop.is_active()):
		# Buy and place in bench
		if (shop_towers[i] != ""):
			var cost = DB.towers.get(shop_towers[i] + "_1").tier
			if (gold >= cost):
				# check for triples before bench
				if check_for_combines(shop_towers[i]):
					shop_towers[i] = ""
					shop.update_slot(i)
					update_gold(-cost)
					return
				
				# Check bench if space
				for n in bench.size():
					if (bench[n] == ""):
						bench[n] = shop_towers[i] + "_1"
						$Bench.update_slot(n, shop_towers[i], 1)
						shop_towers[i] = ""
						shop.update_slot(i)
						update_gold(-cost)
						return
			else:
				$GameInfo.flash_money()
	
func _on_refresh_btn():
	if (shop.is_active()):
		if gold > 0:
			update_gold(-1)
			generate_shop()
			if shop.get_node("aninode/Lock").frame == 1:
				shop.get_node("aninode/Lock").frame = 0
		else:
			$GameInfo.flash_money()

func _on_lock_btn():
	if (shop.is_active()):
		if shop.get_node("aninode/Lock").frame == 0:
			shop.get_node("aninode/Lock").frame = 1
		else:
			shop.get_node("aninode/Lock").frame = 0
		update_gold(10)

func _on_upgrade_btn():
	if (shop.is_active()):
		if gold > 0:
			update_gold(-1)
			increment_xp(1)
		else:
			$GameInfo.flash_money()

func generate_shop():
	for i in 3:
		var tier = Generator.select_tier_for_level(level)
		var tower = Generator.generate_tower_for_tier(tier)
		shop.update_slot(i, tower, tier)
		shop_towers[i] = tower

func _on_bench_click(n: int):
	if (cur_carrying.empty()):
		if (!bench[n].empty()):
			last_location = "BENCH_" + str(n)
			cur_carrying = bench[n]
			bench[n] = ""
			$Bench.update_slot(n)
			need_to_dropdown = shop.pullback()
			shop.get_node("aninode/BannerBtn").hide()
			var twr = cur_carrying.split("_")
			$FollowNode.update_entry(twr[0], int(twr[1]))
			$FollowNode.show()
	else:
		if (last_location.begins_with("BENCH_")):
			# SWAP
			var twr = cur_carrying.split("_")
			if (bench[n].empty()):
				bench[n] = cur_carrying
				$Bench.update_slot(n, twr[0], int(twr[1]))
			else:
				var old_n = int(last_location.substr(6,1))
				bench[old_n] = bench[n]
				bench[n] = cur_carrying
				$Bench.update_slot(n, twr[0], int(twr[1]))
				twr = bench[old_n].split("_")
				$Bench.update_slot(old_n, twr[0], int(twr[1]))
		elif (last_location.begins_with("ACTIVE_")):
			var twr = cur_carrying.split("_")
			if (bench[n].empty()):
				bench[n] = cur_carrying
				$Bench.update_slot(n, twr[0], int(twr[1]))
			else:
				var old_posn = str2var("Vector2" + last_location.split("_")[1]) as Vector2
				
				var temp = bench[n]
				bench[n] = cur_carrying
				$Bench.update_slot(n, twr[0], int(twr[1]))
				
				twr = temp.split("_")
				var node_name = "Tower_" + str(old_posn)
				var ntower = tower_scene.instance()
				ntower.set_name(node_name)
				ntower.set_val(twr[0], int(twr[1]))
				ntower.position = old_posn
				ntower.scale *= 0.15
				ntower.game = self
				ntower.get_node("SelectBtn").connect("pressed", self, "_on_active_click", [node_name])
				active_towers[node_name] = ntower
				$EntitiesSort.add_child(ntower)
			
			
		else:
			print("unknown last location: ", last_location)
		clear_carrying()

func _on_placement_click(event):
	var is_place: bool = true
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			BUTTON_LEFT:
				is_place = true
			BUTTON_RIGHT:
				is_place = false
			_:
				return
	else:
		return

	if (is_place):
		var posn = $FollowNode.is_valid_location()
		if (posn != $FollowNode.INVALID):
			if (active_towers.size() >= level + 2):
				$GameInfo.flash_wiz()
				return
			var twr = cur_carrying.split("_")
			var node_name = "Tower_" + str(posn)
			var ntower = tower_scene.instance()
			ntower.set_name(node_name)
			ntower.set_val(twr[0], int(twr[1]))
			ntower.position = posn
			ntower.scale *= 0.15
			ntower.game = self
			ntower.get_node("SelectBtn").connect("pressed", self, "_on_active_click", [node_name])
			active_towers[node_name] = ntower
			$EntitiesSort.add_child(ntower)
			
			clear_carrying()
	else:
		# return to last location
		if (last_location.begins_with("BENCH_")):
			# SWAP
			var twr = cur_carrying.split("_")
			var old_n = int(last_location.substr(6,1))
			bench[old_n] = cur_carrying
			$Bench.update_slot(old_n, twr[0], int(twr[1]))
		elif (last_location.begins_with("ACTIVE_")):
			var old_posn = str2var("Vector2" + last_location.split("_")[1]) as Vector2
			var twr = cur_carrying.split("_")
			var node_name = "Tower_" + str(old_posn)
			var ntower = tower_scene.instance()
			ntower.set_name(node_name)
			ntower.set_val(twr[0], int(twr[1]))
			ntower.position = old_posn
			ntower.scale *= 0.15
			ntower.game = self
			ntower.get_node("SelectBtn").connect("pressed", self, "_on_active_click", [node_name])
			active_towers[node_name] = ntower
			$EntitiesSort.add_child(ntower)
		
		clear_carrying()

func _on_active_click(node_name: String):
	if (Global.game_state == GLOBAL.GAME_STATE.PREPARING):
		Global.tower_label.hide()
		var old_posn = active_towers[node_name].position
		cur_carrying = active_towers[node_name].name_ + "_" + str(active_towers[node_name].level_)
		last_location = "ACTIVE_" + str(old_posn)
		$EntitiesSort.remove_child(active_towers[node_name])
		active_towers.erase(node_name)
		#str2var("Vector2" + cords) as Vector2
		need_to_dropdown = shop.pullback()
		shop.get_node("aninode/BannerBtn").hide()
		var twr = cur_carrying.split("_")
		$FollowNode.update_entry(twr[0], int(twr[1]))
		$FollowNode.show()
		update_wiz_counts()

func _on_trash_click():
	if (!cur_carrying.empty()):
		update_gold(DB.towers.get(cur_carrying).tier)
		clear_carrying()

func clear_carrying():
	update_wiz_counts()
	$FollowNode.hide()
	cur_carrying = ""
	last_location = ""
	if (need_to_dropdown):
		shop.dropdown()
	shop.get_node("aninode/BannerBtn").show()

func update_wiz_counts():
	$GameInfo.set_cur_wiz(active_towers.size())
	$GameInfo.set_max_wiz(level + 2)

func update_gold(add_val: int):
	gold += add_val
	$GameInfo.set_money(gold)

func increment_wave():
	wave += 1
	$LevelInfo.set_wave(wave)

func increment_level():
	level += 1
	$LevelInfo.set_level(level)

func update_max_xp():
	$LevelInfo.set_max_xp(min(Generator.MAX_LEVEL - 1, level) * 10)

func increment_xp(val: int):
	xp += val
	if level >= Generator.MAX_LEVEL:
		xp = (level - 1) * 10
	elif xp >= level * 10:
		increment_level()
		if level < Generator.MAX_LEVEL:
			xp -= (level - 1) * 10
			update_max_xp()
		else:
			xp = (level - 1) * 10
		update_wiz_counts()
	$LevelInfo.set_cur_xp(xp)

func _on_ff_click():
	if Engine.get_time_scale() == 2.0:
		Engine.set_time_scale(1.0)
		$FastForwards.modulate = Color(1,1,1,1)
	else:
		Engine.set_time_scale(2.0)
		$FastForwards.modulate = Color(0.83,0.83,0.83,1)

#func _process(delta):
#	if (Global.game_state == GLOBAL.GAME_STATE.COMBAT):
#		$Combat.show()
#	else:
#		$Combat.hide()

func get_wave(wave: int):
	if wave == 1:
		return [["Circle", 0.5, 15, 100, 1], ["Circle", 0.8, 10, 100, 1], ["Circle", 0.6, 10, 100, 1], ["Circle", 1.2, 10, 100, 1], ["Circle", 0.5, 10, 100, 1], ["Circle", 0.2, 10, 100, 1],["Circle", 0.7, 10, 100, 1], ["Circle", 0, 10, 100, 1]]
	elif wave == 2:
		return [["Circle", 0.5, 15, 100, 1], ["Circle", 0.8, 15, 90, 1], ["Circle", 0.6, 15, 100, 1], ["Circle", 1.2, 15, 120, 1], ["Circle", 0.5, 15, 100, 1], ["Circle", 0.2, 15, 100, 1],["Circle", 0.7, 15, 90, 1], ["Circle", 0, 15, 80, 1], ["Circle", 1.2, 15, 100, 1], ["Circle", 0.5, 15, 100, 1], ["Circle", 0.2, 15, 120, 1],["Circle", 0.7, 15, 100, 1], ["Circle", 0, 15, 100, 1]]
		
	var wave_list = []
	var num_batches = int(wave * 1.5) + 1
	var batch_size = int(max(wave, 5.0) * 1.2)
	
	for i in num_batches:
		var batch_diff = Generator.rng.randi() % 7 - 4
		var this_batch_size = batch_size + batch_diff
		for j in this_batch_size:
			if (j == 0 && wave % 5 == 0 && i%3 == 0):
				wave_list.append(["BossCircle", 0.5, 50 * ceil(wave / 5.0), 45, 5 * ceil(wave / 5.0)])
			elif (j + 1 == this_batch_size && i + 1 == num_batches):
				wave_list.append(["Circle", 0, 20 * ceil(wave / 5.0), 100, 1 * ceil(wave / 5.0)])
			elif (j + 1 == this_batch_size):
				wave_list.append(["Circle", 2, 20 * ceil(wave / 5.0), 100, 1 * ceil(wave / 5.0)])
			else:
				var speed_dif = Generator.rng.randi() % 50 - 25
				var wait = (Generator.rng.randi() % 100 + 20) / 100.0
				wave_list.append(["Circle", wait, 20 * ceil(wave / 5.0), 100 + speed_dif, 1 * ceil(wave / 5.0)])
	return wave_list

func spawn_wave():
	spawning = true
	var wave_list = get_wave(wave)
	for i in wave_list:
		var mob = enemies_dict[i[0]].instance()
		mob.set_vals(i[2],i[3],i[4])
		mob.game = self
		$EntitiesSort.add_child(mob)
		active_enemies[mob.mob_id] = mob
		var path_follow = PathFollow2D.new()
		path_follow.rotate = false
		path_follow.loop = false
		path_follow.scale *= 0.1 * (100.0 / i[3])
		var remote_trans = RemoteTransform2D.new()
		remote_trans.remote_path = mob.get_path()
		path_follow.add_child(remote_trans)
		$Path/Path/Path2D.add_child(path_follow)
		mob.remote_position_node = get_node(path_follow.get_path())
		if (i[1]):
			yield(get_tree().create_timer(i[1]), "timeout")
	spawning = false

func destroy_mob(mob_id: int, damage_to_tower: int):
	active_enemies.erase(mob_id)
	health -= damage_to_tower
	$Fort/HealthBar.value = health
	
	if health <= 0:
		print("DEAD")
		#TODO
	
	if active_enemies.empty() && !spawning:
		end_round()

func _on_play_click():
	start_round()

func start_round():
	Global.game_state = Global.GAME_STATE.COMBAT
	get_active_properties()
	shop.pullback()
	$Play.hide()
	$FastForwards.show()
	for t in active_towers:
		active_towers[t].start_combat()
	spawn_wave()

func end_round():
	Global.game_state = Global.GAME_STATE.PREPARING
	# gain gold
	var g_level = min(wave, 5)
	var g_interest = min(gold, Global.interest_max) / 5
	update_gold(g_level + g_interest)
	# gain xp
	increment_xp(4)
	increment_wave()
	if shop.get_node("aninode/Lock").frame == 0:
		generate_shop()
	else:
		shop.get_node("aninode/Lock").frame = 0
	shop.dropdown()
	$FastForwards.hide()
	$Play.show()
	for t in active_towers:
		active_towers[t].stop_combat()

func get_active_properties():
	var unique = {}
	for k in active_towers:
		var n = active_towers[k].name_
		unique[n] = active_towers[k].row_
	var counts = {}
	for k in unique:
		var c1 = unique[k].facecolor
		var c2 = unique[k].bodycolor
		if (counts.has(c1)):
			counts[c1] += 1
		else:
			counts[c1] += 1
		if (c1 != c2):
			if (counts.has(c2)):
				counts[c2] += 1
			else:
				counts[c2] += 1
	if (counts.has("white")):
		for k in counts:
			counts[k] += 1
	
	if (counts.has("crimson") && counts["crimson"] >= 2):
		if counts["crimson"] >= 6:
			Global.red_aoe_size = 2.0
		elif counts["crimson"] >= 4:
			Global.red_aoe_size = 1.5
		else:
			Global.red_aoe_size = 1.25
	else:
		Global.red_aoe_size = 1.0
	
	if (counts.has("gold") && counts["gold"] >= 2):
		if counts["gold"] >= 6:
			Global.gold_shots = 3
		elif counts["gold"] >= 4:
			Global.gold_shots = 2
		else:
			Global.gold_shots = 1
	else:
		Global.gold_shots = 0
		
	if (counts.has("cyan") && counts["cyan"] >= 2):
		if counts["cyan"] >= 6:
			Global.slowdown_percent = 0.6
		elif counts["cyan"] >= 4:
			Global.slowdown_percent = 0.7
		else:
			Global.slowdown_percent = 0.8
	else:
		Global.slowdown_percent = 1.0
	
	if (counts.has("rebeccapurple") && counts["rebeccapurple"] >= 2):
		if counts["rebeccapurple"] >= 6:
			Global.knockback_percent = 1.3
		elif counts["rebeccapurple"] >= 4:
			Global.knockback_percent = 1.2
		else:
			Global.knockback_percent = 1.1
	else:
		Global.knockback_percent = 1.0
		
	if (counts.has("darkorange") && counts["darkorange"] >= 2):
		if counts["darkorange"] >= 6:
			Global.global_dmg_percent = 1.5
			Global.global_spd_percent = 0.75
		elif counts["darkorange"] >= 4:
			Global.global_dmg_percent = 1.2
			Global.global_spd_percent = 0.8
		else:
			Global.global_dmg_percent = 1.0
			Global.global_spd_percent = 0.9
	else:
		Global.global_dmg_percent = 1.0
		Global.global_spd_percent = 1.0
	
	if (counts.has("limegreen") && counts["limegreen"] >= 2):
		if counts["limegreen"] >= 6:
			Global.interest_max = 1000
		elif counts["limegreen"] >= 4:
			Global.interest_max = 100
		else:
			Global.interest_max = 50
	else:
		Global.interest_max = 25

	if (counts.has("hotpink") && counts["hotpink"] >= 2):
		if counts["hotpink"] >= 6:
			Global.poison_sub = 0.4
		elif counts["hotpink"] >= 4:
			Global.poison_sub = 0.6
		else:
			Global.poison_sub = 0.8
	else:
		Global.poison_sub = 1.0
		
	if (counts.has("dodgerblue") && counts["dodgerblue"] >= 2):
		if counts["dodgerblue"] >= 6:
			Global.crit_chance = 20
		elif counts["dodgerblue"] >= 4:
			Global.crit_chance = 10
		else:
			Global.crit_chance = 5
	else:
		Global.crit_chance = 0
	
	
	

extends Node2D

class_name Game

# Scenes / Children
var shop_scene = preload("res://src/Shop_DropDown.tscn")
var shop: Shop
var tower_scene = preload("res://src/Tower.tscn")

var circlemob_scene = preload("res://src/mobs/CircleMob.tscn")
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
	
	Global.tower_label = $TowerLabel
	
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
	$Bench/Slot2/Slot2Btn.connect("pressed", self, "_on_bench_click", [1])
	$Bench/Slot3/Slot3Btn.connect("pressed", self, "_on_bench_click", [2])
	$Bench/Slot4/Slot4Btn.connect("pressed", self, "_on_bench_click", [3])
	$Bench/Slot5/Slot5Btn.connect("pressed", self, "_on_bench_click", [4])
	$Bench/Slot6/Slot6Btn.connect("pressed", self, "_on_bench_click", [5])
	$Bench/Slot7/Slot7Btn.connect("pressed", self, "_on_bench_click", [6])
	$Bench/Slot8/Slot8Btn.connect("pressed", self, "_on_bench_click", [7])
	$Trash/Trash/TrashBtn.connect("pressed", self, "_on_trash_click")
	
	$FollowNode/PlaceBtn.connect("gui_input", self, "_on_placement_click")
	
	
	Global.game_state = GLOBAL.GAME_STATE.PREPARING
	$Play/PlayBtn.connect("pressed", self, "_on_play_click")
	$FastForwards/FFBtn.connect("pressed", self, "_on_ff_click")

	enemies_dict["Circle"] = circlemob_scene

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
		print("Trying to buy ", i)
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
				print("no spots left")
			else:
				print("not enough gold")
				$GameInfo.flash_money()
	
func _on_refresh_btn():
	if (shop.is_active()):
		if gold > 0:
			update_gold(-1)
			print("refreshing")
			generate_shop()
		else:
			$GameInfo.flash_money()

func _on_lock_btn():
	if (shop.is_active()):
		print("lock")
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
				print("test",event.button_index)
				return
	else:
		return

	if (is_place):
		var posn = $FollowNode.is_valid_location()
		if (posn != $FollowNode.INVALID):
			if (active_towers.size() >= level + 2):
				$GameInfo.flash_wiz()
				return
			print("posn", posn, " | ", cur_carrying)
			var twr = cur_carrying.split("_")
			var node_name = "Tower_" + str(posn)
			var ntower = tower_scene.instance()
			ntower.set_name(node_name)
			ntower.set_val(twr[0], int(twr[1]))
			ntower.position = posn
			ntower.scale *= 0.15
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
			ntower.get_node("SelectBtn").connect("pressed", self, "_on_active_click", [node_name])
			active_towers[node_name] = ntower
			$EntitiesSort.add_child(ntower)
		
		clear_carrying()

func _on_active_click(node_name: String):
	if (Global.game_state == GLOBAL.GAME_STATE.PREPARING):
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
	print("trash", cur_carrying)
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
	$LevelInfo.set_max_xp(level * 10)

func increment_xp(val: int):
	xp += val
	if xp >= level * 10:
		xp -= level * 10
		increment_level()
		update_max_xp()
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

#TODO fix
func get_wave(lvl: int):
	return [["Circle", 0.5], ["Circle", 0.2], ["Circle", 0.5], ["Circle", 0.2], ["Circle", 0.5], ["Circle", 0.2],["Circle", 0.5], ["Circle", 0]]

func spawn_wave():
	spawning = true
	var wave = get_wave(level)
	for i in wave:
		var mob = enemies_dict[i[0]].instance()
		mob.game = self
		$EntitiesSort.add_child(mob)
		active_enemies[mob.mob_id] = mob
		var path_follow = PathFollow2D.new()
		path_follow.rotate = false
		path_follow.loop = false
		path_follow.scale *= 0.1
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
	print(health)
	
	if health <= 0:
		print("DEAD")
		#TODO
	
	if active_enemies.empty() && !spawning:
		end_round()

func _on_play_click():
	start_round()

func start_round():
	Global.game_state = Global.GAME_STATE.COMBAT
	shop.pullback()
	$Play.hide()
	$FastForwards.show()
	for t in active_towers:
		active_towers[t].start_combat()
	spawn_wave()

func end_round():
	Global.game_state = Global.GAME_STATE.PREPARING
	shop.dropdown()
	# gain gold
	var g_level = min(wave, 5)
	var g_interest = min(gold, 25) / 5
	update_gold(g_level + g_interest)
	# gain xp
	increment_xp(4)
	increment_wave()
	$FastForwards.hide()
	$Play.show()
	for t in active_towers:
		active_towers[t].stop_combat()

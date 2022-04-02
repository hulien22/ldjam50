extends Node2D

# Scenes / Children
var shop_scene = preload("res://src/Shop_DropDown.tscn")
var shop: Shop
var tower_scene = preload("res://src/Tower.tscn")

# Member variables
var tier: int = 1
var xp: int = 0
var level: int = 1
var gold: int = 4
var health: int = 100
var wave: int = 1
var bench: Array = ["", "", "", "", "", "", "", ""]
var active_towers: Dictionary = {}
var shop_towers: Array = ["", "", ""]

var cur_carrying: String = ""
var last_location: String = ""
var need_to_dropdown: bool = false

func _ready():
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
	
#	var ntower = tower_scene.instance()
#	ntower.set_name("Tower")
#	ntower.set_val("Evoker", 1)
#	ntower.position = Vector2(200,200)
#	add_child(ntower)

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
	return true

func _on_shop_buy(i: int):
	if (shop.is_active()):
		print("Trying to buy ", i)
		# Buy and place in bench
		if (shop_towers[i] != ""):
			var cost = DB.towers.get(shop_towers[i] + "_1").tier
			if (gold >= cost):
				# TODO check for triples before bench
				if check_for_combines(shop_towers[i]):
					shop_towers[i] = ""
					shop.update_slot(i)
					update_gold(-cost)
					return
				
				# Check bench if space
				for n in bench.size():
					if (bench[n] == ""):
						#TODO GOLD
						bench[n] = shop_towers[i] + "_1"
						$Bench.update_slot(n, shop_towers[i], 1)
						shop_towers[i] = ""
						shop.update_slot(i)
						update_gold(-cost)
						return
				print("no spots left")
			else:
				print("not enough gold")
	
func _on_refresh_btn():
	if (shop.is_active()):
		if gold > 0:
			update_gold(-1)
			print("refreshing")
			generate_shop()

func _on_lock_btn():
	if (shop.is_active()):
		print("lock")
		update_gold(10)

func _on_upgrade_btn():
	if (shop.is_active()):
		print("upgrading")

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

func _on_trash_click():
	print("trash", cur_carrying)
	if (!cur_carrying.empty()):
		update_gold(DB.towers.get(cur_carrying).tier)
		clear_carrying()

func clear_carrying():
	$FollowNode.hide()
	cur_carrying = ""
	last_location = ""
	if (need_to_dropdown):
		shop.dropdown()
	shop.get_node("aninode/BannerBtn").show()

func update_gold(add_val: int):
	gold += add_val
	print(gold)
	#TODO update displays

#func _process(delta):
#	if (Global.game_state == GLOBAL.GAME_STATE.COMBAT):
#		$Combat.show()
#	else:
#		$Combat.hide()

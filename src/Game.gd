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
var active_towers: Array
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
	
	
#	var ntower = tower_scene.instance()
#	ntower.set_name("Tower")
#	ntower.set_val("Evoker", 1)
#	ntower.position = Vector2(200,200)
#	add_child(ntower)

func _on_shop_buy(i: int):
	if (shop.is_active()):
		print("Trying to buy ", i)
		# Buy and place in bench
		if (shop_towers[i] != ""):
			# TODO check for triples before bench
			for n in bench.size():
				if (bench[n] == ""):
					#TODO GOLD
					bench[n] = shop_towers[i] + "_1"
					$Bench.update_slot(n, shop_towers[i], 1)
					shop_towers[i] = ""
					shop.update_slot(i)
					return
			print("no spots left")
	
func _on_refresh_btn():
	if (shop.is_active()):
		print("refreshing")
		generate_shop()

func _on_lock_btn():
	if (shop.is_active()):
		print("lock")

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
		else:
			#TODO FROM ACTIVE
			pass
		$FollowNode.hide()
		cur_carrying = ""
		last_location = ""
		if (need_to_dropdown):
			shop.dropdown()
		shop.get_node("aninode/BannerBtn").show()

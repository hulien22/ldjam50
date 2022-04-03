extends Node2D

var rng = RandomNumberGenerator.new()
var towers_by_tier: Dictionary = {}
const NUM_TIERS = 5
var chances_by_tier = [
	[100,0,0,0,0],
	[66,34,0,0,0],
	[33,50,17,0,0],
	[20,35,35,10,0],
	[10,20,50,15,5],
	[5,15,30,30,20],
	[0,5,20,50,25],
	[0,0,10,40,50]]

func _ready():
	rng.randomize()
	for i in DB.towers.all.size():
		var tower = DB.towers.get_index(i)
		if tower.name.ends_with("_1"):
			if !towers_by_tier.has(tower.tier):
				towers_by_tier[tower.tier] = []
			towers_by_tier[tower.tier].append(tower.name.trim_suffix("_1"))

func generate_tower_for_tier(tier: int) -> String :
	return towers_by_tier[tier][rng.randi() % towers_by_tier[tier].size()]

func select_tier_for_level(level: int) -> int :
	var n = rng.randi() % 100
	for i in NUM_TIERS:
		n -= chances_by_tier[level - 1][i]
		if (n < 0):
			return i + 1
	print("n still non-negative", n, level)
	return 1

var mob_id: int = 0
func generate_mob_id() -> int:
	mob_id += 1
	return mob_id
	

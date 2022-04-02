extends Node2D

var value: String
var level: int
var cost: int

func _ready():
	update_entry("")

func update_entry(name: String, lvl: int = 1, cost: int = 0):
	value = name
	level = lvl
	if (name.empty()):
		$Wiz.hide()
		$Cost.frame = 0
	else:
		var row = DB.towers.get(name + "_" + str(lvl))
		$Wiz.update_color(ColorN(row.facecolor), ColorN(row.bodycolor), ColorN(row.armcolor), true)
		$Wiz.set_level(level - 1)
		$Wiz.show()
		$Cost.frame = cost

func get_value() -> String:
	return value

func get_level() -> int:
	return level

func get_cost() -> int:
	return cost

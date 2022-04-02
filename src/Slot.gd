extends Node2D

var value: String
var level: int

func _ready():
	update_entry("")

func update_entry(name: String, lvl: int = 1):
	value = name
	level = lvl
	if (name.empty()):
		$Wiz.hide()
	else:
		var row = DB.towers.get(name + "_" + str(lvl))
		$Wiz.update_color(ColorN(row.facecolor), ColorN(row.bodycolor), ColorN(row.armcolor), false)
		$Wiz.set_level(level - 1)
		$Wiz.show()

func get_value() -> String:
	return value

func get_level() -> int:
	return level


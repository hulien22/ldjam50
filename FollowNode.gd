extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	position = get_global_mouse_position()

func update_entry(name: String, lvl: int = 1):
	if (name.empty()):
		$Wiz.hide()
	else:
		var row = DB.towers.get(name + "_" + str(lvl))
		$Wiz.update_color(ColorN(row.facecolor), ColorN(row.bodycolor), ColorN(row.armcolor), false)
		$Wiz.set_level(lvl - 1)
		$Wiz.show()

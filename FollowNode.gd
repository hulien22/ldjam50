extends Node2D

const INVALID = Vector2(-1,-1)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	position = get_global_mouse_position()
	if (is_valid_location() != INVALID):
		$Area2D/ValidBox.color = Color8(0,255,0,100)
	else:
		$Area2D/ValidBox.color = Color8(0,0,0,0)#Color8(255,0,0,100)
		

func update_entry(name: String, lvl: int = 1):
	if (name.empty()):
		$Wiz.hide()
	else:
		var row = DB.towers.get(name + "_" + str(lvl))
		$Wiz.update_color(ColorN(row.facecolor), ColorN(row.bodycolor), ColorN(row.armcolor), true)
		$Wiz.set_level(lvl - 1)
		$Wiz.show()

func is_valid_location() -> Vector2:
	if (Global.game_state == GLOBAL.GAME_STATE.PREPARING && $Area2D.get_overlapping_areas().empty()):
		return position
	else:
		return INVALID

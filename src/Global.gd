extends Node
class_name GLOBAL

enum GAME_STATE {PREPARING, COMBAT, COMPLETE}

var game_state = GAME_STATE.PREPARING

#func update_game_state(state):
#	game_state = state
#	emit_signal()

var tower_label: Control = null

func show_tower_label(left:bool):
	if left:
		tower_label.margin_left = 5
	else:
		tower_label.margin_left = 779
	tower_label.show()

func hide_tower_label():
	tower_label.hide()

enum BUFF {DMG, SPEED, RANGE}

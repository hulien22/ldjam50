extends Node
class_name GLOBAL

enum GAME_STATE {PREPARING, COMBAT, COMPLETE}

var game_state = GAME_STATE.PREPARING

#func update_game_state(state):
#	game_state = state
#	emit_signal()

var tower_label: Control = null

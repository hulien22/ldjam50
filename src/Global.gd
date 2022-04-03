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

var red_aoe_size = 1.0
var gold_shots = 0
var slowdown_percent = 1.0
var knockback_percent = 1.0
var global_dmg_percent = 1.0
var global_spd_percent = 1.0
var interest_max = 25
var poison_sub = 1.0
var crit_chance = 0

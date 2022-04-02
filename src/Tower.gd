extends Node2D

class_name Tower

var name_: String
var level_: int
var row_ # : DB.Towers.TowersRow

# ctor
func set_val(name: String, level: int):
	name_ = name
	level_ = level
	row_ = DB.towers.get(name_ + "_" + str(level_))
	update_sprite()

func update_sprite():
	#$Wiz.set_animation_speed(10.0 / row_.atkspd)
	$Wiz.update_color(ColorN(row_.facecolor), ColorN(row_.bodycolor), ColorN(row_.armcolor), true)




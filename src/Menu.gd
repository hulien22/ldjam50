extends Node2D

func _ready():
	$wiz.update_color(Color(1,1,1),Color(1,1,1),Color(1,1,1),true)
func _on_Button_pressed():
	get_tree().change_scene("res://src/Map.tscn")

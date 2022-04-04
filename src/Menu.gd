extends Node2D

func _ready():
	$wiz.update_color(Color(1,1,1),Color(1,1,1),Color(1,1,1),true)
	$Fort2.get_node("HealthBar").hide()
func _on_Button_pressed():
	get_tree().change_scene("res://src/Map.tscn")

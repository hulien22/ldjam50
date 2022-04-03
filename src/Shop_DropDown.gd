extends Node2D

class_name Shop

var down: bool
var animating: bool
var bounce: bool
var active: bool
var target: Vector2
var slots: Array

func _ready():
	down = false
	animating = false
	active = false
	slots = [$aninode/Slot1, $aninode/Slot2, $aninode/Slot3]

func _on_BannerBtn_pressed():
	print(animating)
	if (!animating):
		animating = true
		active = false
		if (!down):
			$AnimationPlayer.play("ShopDropdownFast")
		else:
			$AnimationPlayer.play("ShopReturn")

func _on_AnimationPlayer_animation_finished(anim_name):
	animating = false
	if (anim_name == "ShopDropdownFast" || anim_name == "ShopDropdown"):
		active = true
		down = true
	else:
		# active is already false
		active = false
		down = false

func is_active():
	return active

func pullback() -> bool:
	if ((animating && !down) || (!animating && down)):
		$AnimationPlayer.clear_queue()
		$AnimationPlayer.queue("ShopReturn")
		return true
	return false

func dropdown():
	$AnimationPlayer.clear_queue()
	$AnimationPlayer.queue("ShopDropdownFast")


func update_slot(i: int, name: String = "", tier: int = 0):
	slots[i].update_entry(name, 1, tier)
	#TODO add tier to value here


func _on_btn_mouse_entered(i: int):
	if !slots[i].get_value().empty():
		Global.tower_label.init_text(slots[i].get_value(), str(slots[i].get_level()))
		Global.tower_label.show()


func _on_btn_mouse_exited():
	Global.tower_label.hide()

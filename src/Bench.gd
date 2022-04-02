extends Node2D


var slots: Array

func _ready():
	slots = [$Slot1, $Slot2, $Slot3, $Slot4, $Slot5, $Slot6, $Slot7, $Slot8]

func update_slot(i: int, name: String = "", level: int = 1):
	slots[i].update_entry(name, level)
	#TODO add tier to value here

extends Node2D

func set_wave(val:int):
	$WaveLbl.text = "Wave " + str(val)

func set_level(val:int):
	$LevelLbl.text = "Level " + str(val)

func set_cur_xp(val:int):
	$XpLbl.text = str(val)
	
func set_max_xp(val:int):
	$XpLbl2.text = str(val)

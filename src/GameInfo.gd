extends Node2D

func set_money(val: int):
	$BillNode/MoneyLbl.text = str(val)

func set_cur_wiz(val: int):
	$WizNode/CurWizLbl.text = str(val)

func set_max_wiz(val: int):
	$WizNode/MaxWizLbl.text = str(val)

func flash_money():
	$BillNode/AnimationPlayer.stop()
	$BillNode/AnimationPlayer.play("BillFlashRed")

func flash_wiz():
	$WizNode/AnimationPlayer.stop()
	$WizNode/AnimationPlayer.play("WizFlashRed")

extends Control
class_name TowerLabel

func init_text(name: String, level: String):
	var row = DB.towers.get(name + "_" + level)
	$RichTextLabel.bbcode_text = ""

	$RichTextLabel.push_bold_italics()
	$RichTextLabel.push_align(RichTextLabel.ALIGN_CENTER)
	$RichTextLabel.push_color("eaeaea")
	$RichTextLabel.add_text(name)
	$RichTextLabel.pop()
	$RichTextLabel.pop()
	$RichTextLabel.pop()
	
	$RichTextLabel.newline()
	
	$RichTextLabel.push_italics()
	$RichTextLabel.push_align(RichTextLabel.ALIGN_CENTER)
	$RichTextLabel.push_color("e7e7e7")
	$RichTextLabel.add_text("Level " + level + "   " + "Tier " + str(row.tier))
	$RichTextLabel.pop()
	$RichTextLabel.pop()
	$RichTextLabel.pop()
	
	$RichTextLabel.newline()
	
	$RichTextLabel.push_italics()
	$RichTextLabel.push_align(RichTextLabel.ALIGN_CENTER)
	$RichTextLabel.push_color("d7d7d7")
	$RichTextLabel.add_text(row.description)
	$RichTextLabel.pop()
	$RichTextLabel.pop()
	$RichTextLabel.pop()

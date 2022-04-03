extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var colors = [Color.chartreuse, Color.aqua, Color.yellowgreen, Color.yellow, Color.red, Color.royalblue]
var health: int
var speed: float = 1
var path: Path2D

var remote_position_node: PathFollow2D

# Called when the node enters the scene tree for the first time.
func _ready():
	print(scale)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if remote_position_node:
		remote_position_node.offset += speed * 100 * delta

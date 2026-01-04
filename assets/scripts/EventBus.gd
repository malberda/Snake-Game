extends Node

signal snake_spotted(snake)
signal snake_killed(snake)

var current_scene: Node = null

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

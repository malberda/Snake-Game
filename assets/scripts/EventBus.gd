extends Node

signal player_spotted(snake)
signal player_killed(snake)

signal player_update_stamina(stamina: int)
signal player_update_health(health: int)

var current_scene: Node = null

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

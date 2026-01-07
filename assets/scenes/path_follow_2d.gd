# Script on PathFollow2D (GDScript)
extends PathFollow2D

@export var speed: float = 20.0  # Pixels per second

var stop_following = false

func _ready():
	EventBus.connect("player_spotted", _on_snake_spotted)
	self.rotates = false
	
func _on_snake_spotted():
	set_process(false)
	
func _process(delta: float) -> void:
	progress += speed * delta  # Moves forward; use -= for backward

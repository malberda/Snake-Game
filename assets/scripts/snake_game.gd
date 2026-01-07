extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HUD.hide_game_over()
	EventBus.connect("snake_killed", _on_snake_killed);
	pass # Replace with function body.

func _on_snake_killed():
	game_over();
	
func game_over():
	$HUD.show_game_over()
	Global.paused = true
	get_tree().paused = true
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit();

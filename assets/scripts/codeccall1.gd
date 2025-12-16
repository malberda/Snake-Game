extends Area2D

@onready var found: AudioStreamPlayer2D = $"../Found"
@onready var game_over: AudioStreamPlayer2D = $"../GameOver"
@onready var codec_call_1_img: Sprite2D = $"../CodecCall1Img"
@onready var codec_call_background: Sprite2D = $"../CodecCallBackground"
@onready var game_over_screen: Sprite2D = $"../GameOverScreen"
@onready var timer: Timer = $"../Timer"
@onready var game_over_timer: Timer = $"../GameOverTimer"
var snake: Node2D #assigned at runtime

func _on_area_entered(area: Area2D) -> void:
	if Global.codec1Seen:
		pass
	else:
		found.play();
		Global.paused = true;
		codec_call_1_img.show()
		codec_call_background.show()
		timer.wait_time = 3.0;
		timer.timeout.connect(_on_timer_timeout)
		timer.start();
		Global.codec1Seen = true

func _ready() -> void:
	snake = get_tree().get_current_scene().get_node("Snake") as Node2D;
	
func _process(delta: float) -> void:
	if Global.caught:
		timer.stop()
		game_over_screen.position = snake.position
		codec_call_background.position = snake.position
		game_over_screen.show()
		codec_call_background.show()
		game_over.play()
		Global.paused = true
		game_over_timer.wait_time = 5.0
		game_over_timer.timeout.connect(_on_restart_timer)
		game_over_timer.start()
		Global.caught = false
		
func _on_restart_timer():
	get_tree().reload_current_scene()
	Global.paused = false

func _on_timer_timeout():
	timer.stop()
	codec_call_1_img.hide()
	codec_call_background.hide()
	Global.paused = false;
		
		

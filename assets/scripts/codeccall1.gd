extends Area2D

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $"../AudioStreamPlayer2D"
@onready var codec_call_1_img: Sprite2D = $"../CodecCall1Img"
@onready var codec_call_background: Sprite2D = $"../CodecCallBackground"
@onready var timer: Timer = $"../Timer"

func _on_area_entered(area: Area2D) -> void:
	audio_stream_player_2d.play();
	Global.paused = true;
	codec_call_1_img.show()
	codec_call_background.show()
	timer.wait_time = 3.0;
	timer.timeout.connect(_on_timer_timeout)
	timer.start();

func _on_timer_timeout():
	timer.stop()
	codec_call_1_img.hide()
	codec_call_background.hide()
	Global.paused = false;

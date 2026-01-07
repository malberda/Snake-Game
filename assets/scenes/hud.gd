extends CanvasLayer

# Store the original width of the stamina bar so we can scale it
@onready var stamina_bar_init_width = $StaminaBar.size.x
@onready var health_bar_init_width = $HealthBar.size.x

func _ready() -> void:	
	EventBus.connect("player_update_stamina", _on_player_update_stamina)
	EventBus.connect("player_update_health", _on_player_update_health)
	EventBus.connect("player_killed", _on_player_killed)

func _process(_delta: float) -> void:
	pass

func hide_game_over():
	$GameOver.hide()
	
func show_game_over():
	$GameOver.show()
	
func _on_player_killed():
	show_game_over()

func _on_player_update_stamina(stamina_value: int):
	$StaminaBar.size.x = stamina_bar_init_width * (stamina_value / 100.0)
	
func _on_player_update_health(health_value: int):
	$HealthBar.size.x = health_bar_init_width * (health_value / 100.0)

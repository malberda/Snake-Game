extends CharacterBody2D

@export var movement_speed = 20.0

var snake: Node2D #assigned at runtime

var snake_spotted = false

func _ready() -> void:
	$Alert.hide()
	snake = get_tree().get_current_scene().get_node("Snake") as Node2D;
	EventBus.connect("snake_spotted", _on_snake_spotted);
	
func _process(_delta):
	check_line_of_sight();

func _on_snake_spotted():
	# If this is the first time spotting snake
	if !snake_spotted:
		# Start navigating towards snake
		$NavigationAgent2D.target_position = snake.global_position
		$Alert.show()
		$Alert/AnimationPlayer.play("alert_pop");
		$FoundAudio.play();
		# Start the timer for recalculating the path targeting snake
		$Timer.start()
		self.reparent(self)
		
		snake_spotted = true

func _physics_process(delta: float) -> void:
	if $NavigationAgent2D.is_navigation_finished():
		return;
		
	var next_pos: Vector2 = $NavigationAgent2D.get_next_path_position();
	var direction: Vector2 = global_position.direction_to(next_pos);
	velocity = direction * movement_speed
	if velocity.length() > 0.1:
		rotation = velocity.angle() - 90.0
	
	move_and_slide()

func _on_timer_timeout():
	if !snake_spotted:
		return
	
	# Periodically update the target position since snake will be moving around
	if $NavigationAgent2D.target_position != snake.global_position:
		$NavigationAgent2D.target_position = snake.global_position
	$Timer.start()
	
func check_line_of_sight():
	for ray in $FrontFacingRays.get_children():
		ray.force_raycast_update()
		if ray.is_colliding() && ray.get_collider() == snake && !snake.is_in_box():
			EventBus.emit_signal("snake_spotted")

func _on_area_2d_body_entered(body: Node2D) -> void:
	pass
	#if !snake.is_in_box() && body == snake:
		#EventBus.emit_signal("snake_killed")

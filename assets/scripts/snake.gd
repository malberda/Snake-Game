extends CharacterBody2D

@export var speed = 200;
var box = false;


func _physics_process(delta: float) -> void:
	var input_direction = Input.get_vector("left", "right", "up", "down")
	if Input.is_action_just_pressed("Space") && !box:
		box = true;
		$AnimatedSprite2D.play("boxWalk");
	elif Input.is_action_just_pressed("Space"):
		box = false;
	
	if Input.is_action_pressed("Shift"):
		speed = 100
		$AnimatedSprite2D.speed_scale = 0.5
	else:
		speed = 200
		$AnimatedSprite2D.speed_scale = 1
		
	if Input.is_action_pressed("right"):
		if (box):
			$AnimatedSprite2D.play("boxWalk");
			$AnimatedSprite2D.rotation_degrees = 90
		else:
			$AnimatedSprite2D.play("walkRight")
		input_direction.y = 0
	elif Input.is_action_pressed("left"):
		if (box):
			$AnimatedSprite2D.play("boxWalk");
			$AnimatedSprite2D.rotation_degrees = 270
		else:
			$AnimatedSprite2D.play("walkLeft")
		input_direction.y = 0
	elif Input.is_action_pressed("up"):
		if (box):
			$AnimatedSprite2D.play("boxWalk");
			$AnimatedSprite2D.rotation_degrees = 0
		else:
			$AnimatedSprite2D.play("walkUp")
		input_direction.x = 0
	elif Input.is_action_pressed("down"):
		if (box):
			$AnimatedSprite2D.play("boxWalk");
			$AnimatedSprite2D.rotation_degrees = 180
		else:
			$AnimatedSprite2D.play("walkDown")
		input_direction.x = 0
	else:
		$AnimatedSprite2D.pause()
		input_direction = Vector2.ZERO
		
		
	input_direction = input_direction.normalized()
	velocity = input_direction*speed;
	move_and_slide();

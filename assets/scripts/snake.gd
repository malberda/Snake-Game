extends CharacterBody2D

const base_speed = 100
var speed;
var box = false;
var last_camera_position: Vector2;
var sneaking: bool;

@onready var snake: CharacterBody2D = $"."
@onready var snake_collision_area: Area2D = $snakeCollisionArea
@onready var snowfall: GPUParticles2D = $Camera2D/GPUParticles2D
@onready var camera: Camera2D = $Camera2D

func _ready():
	last_camera_position = camera.global_position;
	
func _physics_process(_delta: float) -> void:
	if !Global.paused:
		var cam_delta = camera.global_position - last_camera_position 
		last_camera_position = camera.global_position;
		var mat := snowfall.process_material as ParticleProcessMaterial
		process_movement();
		if mat:
			mat.gravity.x = - cam_delta.x / max(_delta, 0.001)*0.15;
	else:
		$AnimatedSprite2D.play("defaultUp");
	
func process_movement():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	if Input.is_action_just_pressed("Space") && !box:
		box = true;
		$AnimatedSprite2D.play("walkBox");
	elif Input.is_action_just_pressed("Space"):
		box = false;
	
	if Input.is_action_pressed("Shift"):
		speed = floor(base_speed/2)
		$AnimatedSprite2D.speed_scale = 0.5
	else:
		speed = base_speed
		$AnimatedSprite2D.speed_scale = 1
		
	if Input.is_action_pressed("right"):
		if (box):
			$AnimatedSprite2D.play("walkBox");
			$AnimatedSprite2D.rotation_degrees = 90
		else:
			$AnimatedSprite2D.rotation_degrees = 0
			$AnimatedSprite2D.play("walkRight")
		input_direction.y = 0
	elif Input.is_action_pressed("left"):
		if (box):
			$AnimatedSprite2D.play("walkBox");
			$AnimatedSprite2D.rotation_degrees = 270
		else:
			$AnimatedSprite2D.rotation_degrees = 0
			$AnimatedSprite2D.play("walkLeft")
		input_direction.y = 0
	elif Input.is_action_pressed("up"):
		if (box):
			$AnimatedSprite2D.play("walkBox");
			$AnimatedSprite2D.rotation_degrees = 0
		else:
			$AnimatedSprite2D.rotation_degrees = 0
			$AnimatedSprite2D.play("walkUp")
		input_direction.x = 0
	elif Input.is_action_pressed("down"):
		if (box):
			$AnimatedSprite2D.play("walkBox");
			$AnimatedSprite2D.rotation_degrees = 180
		else:
			$AnimatedSprite2D.rotation_degrees = 0
			$AnimatedSprite2D.play("walkDown")
		input_direction.x = 0
	else:
		if (box):
			$AnimatedSprite2D.frame = 0
		$AnimatedSprite2D.pause()
		input_direction = Vector2.ZERO
		
	input_direction = input_direction.normalized()
	velocity = input_direction*speed;
	move_and_slide();

extends CharacterBody2D

const base_speed = 70
const sprint_speed = 140
var speed;
var box = false;
var last_camera_position: Vector2;
var sneaking: bool;
var stamina = 100;
var health = 100;

@onready var snake: CharacterBody2D = $"."
@onready var snake_collision_area: Area2D = $snakeCollisionArea
@onready var camera: Camera2D = $Camera2D

@export var radius: float = 800.0
@export var num_rays: int = 72  # 5° steps (360/5)
@export var rays_collision_mask: int = 1

@export var sword_scene: PackedScene  # Assign your SwordHitbox.tscn in editor
@export var attack_range: float = 48.0
@export var attack_duration: float = 0.15
@export var damage: int = 10
@onready var cooldown_timer: Timer = $AttackCooldownTimer

var facing_dir: Vector2 = Vector2.RIGHT:  # Updated e.g. in _input() for mouse facing
	set(value):
		facing_dir = value.normalized()

var stamina_regen_rate = 5
var sprinting = false
var stamina_spend_rate = 10

var detected_colliders: Array[Node2D] = []  # Track unique colliders to avoid duplicates

var detection_groups: Array[String] = ["enemy", "torch"]

func _ready():
	last_camera_position = camera.global_position;
	
	$StaminaTimer.start()
	
func _physics_process(_delta: float) -> void:
	
	# Scan around snake to reveal anything that is in eyesight
	radial_visibility_scan()
	
	if Input.is_action_just_pressed('left_click'):
		attack()
	
	if !Global.paused:
		last_camera_position = camera.global_position;
		process_movement();
	else:
		$AnimatedSprite2D.play("defaultUp");
	
func process_movement():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	if Input.is_action_just_pressed("Space") && !box:
		box = true;
		$AnimatedSprite2D.play("walkBox");
	elif Input.is_action_just_pressed("Space"):
		box = false;
	
	if Input.is_action_pressed("Shift") and stamina > 0:
		speed = sprint_speed
		sprinting = true
		$AnimatedSprite2D.speed_scale = 0.5
	else:
		sprinting = false
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
	velocity = input_direction * speed;
	move_and_slide();
	
func is_in_box():
	return $AnimatedSprite2D.animation == 'walkBox' && $AnimatedSprite2D.frame == 0

func radial_visibility_scan() -> void:
	var space_state = get_world_2d().direct_space_state
	
	detected_colliders = []
	
	for i in range(num_rays):
		var angle = i * TAU / num_rays
		var direction = Vector2(cos(angle), sin(angle))
		var query = PhysicsRayQueryParameters2D.create(
			global_position,
			global_position + direction * radius
		)
		query.collision_mask = rays_collision_mask
		query.exclude = [self]
		
		var result = space_state.intersect_ray(query)
		if result:
			var collider = result.collider as Node2D
			if collider and collider not in detected_colliders:
				# Check if it matches any detection group
				for group in detection_groups:
					if collider.is_in_group(group):
						collider.visible = true
						detected_colliders.append(collider)
						break  # One group match is enough
	

func _on_stamina_timer_timeout() -> void:
	if sprinting:
		if stamina - stamina_spend_rate > 0:
			stamina -= stamina_spend_rate
		else:
			stamina = 0
	else:
		if stamina + stamina_regen_rate < 100:
			stamina += stamina_regen_rate
		else:
			stamina = 100
	EventBus.emit_signal("player_update_stamina", stamina)
	
			
func attack() -> void:
	pass
	#if cooldown_timer.is_stopped():
		#cooldown_timer.start()
		#_spawn_sword()


func _on_snake_collision_area_body_entered(body: Node2D) -> void:
	if body.is_in_group('enemy'):
		health -= 25
		EventBus.emit_signal("player_update_health", health)
		if health <= 0:
			EventBus.emit_signal("player_killed")

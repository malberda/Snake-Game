extends CharacterBody2D

const directionArray = ['up', 'down', 'left', 'right']

var rays : Array
var AIPathing
var rng = RandomNumberGenerator.new()
var index = 0
var snake: Node2D #assigned at runtime
var player_detected = 0; #0 is undetected, 1 is suspicious, 2 is found and killed.

@onready var ray_container: Node2D = $rayContainer
@onready var foundWav: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer

func _ready() -> void:
	snake = get_tree().get_current_scene().get_node("Snake") as Node2D;
	
	if snake:
		print("found snake");
	else:
		print("aint found anything")
	rays = ray_container.get_children()
	var amountOfMoves = rng.randf_range(4, 8)
	AIPathing = []
	AIPathing.resize(amountOfMoves)
	for i in range(amountOfMoves):
		AIPathing[i] = [
			rng.randf_range(1, 5), 
			directionArray[randi() % directionArray.size()]
		]
	timer.wait_time = AIPathing[0][0];
	timer.timeout.connect(_on_timer_timeout)
	timer.start();

func _on_timer_timeout():
	var currentPath = AIPathing[index % AIPathing.size()]
	var wait_time = currentPath[0]
	$AnimatedSprite2D.play(currentPath[1]);
	if (currentPath[1] == 'left'):
		ray_container.rotation_degrees = 90
	elif (currentPath[1] == 'right'):
		ray_container.rotation_degrees = 270
	elif (currentPath[1] == 'up'):
		ray_container.rotation_degrees = 180
	elif (currentPath[1] == 'down'):
		ray_container.rotation_degrees = 0
	index+=1;
	timer.wait_time = wait_time;
	timer.start();

func _process(_delta):
	if player_detected == 0:
		check_line_of_sight();
	
func check_line_of_sight():
	for ray in rays:
		ray.force_raycast_update()
		if ray.is_colliding():
			var collider = ray.get_collider();
			if collider == snake:
				player_detected = 1;
				break;
	if player_detected:
		foundWav.play();
		print("player found");
	else:
		print("snake not found")
		player_detected = 0;
		pass

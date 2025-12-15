extends CharacterBody2D


const directionArray = ['up', 'down', 'left', 'right']

var movingForward := true
var rays : Array
var AIPathing
var rng = RandomNumberGenerator.new()
var index = 0
var extraStep = false;
const speed = 25
var snake: Node2D #assigned at runtime
var player_detected = 0; #0 is undetected, 1 is suspicious, 2 is found and killed.
var amountOfMoves

@onready var ray_container: Node2D = $rayContainer
@onready var foundWav: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer

func _ready() -> void:
	$Alert.hide()
	snake = get_tree().get_current_scene().get_node("Snake") as Node2D;
	
	rays = ray_container.get_children()
	amountOfMoves = 3#rng.randf_range(4, 8)
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
	if(index == AIPathing.size() && movingForward):
		movingForward = false
		index -= 1
		extraStep = true;
	elif (index == 0 && !movingForward):
		movingForward = true;
	var currentPath = AIPathing[index % AIPathing.size()]
	var wait_time = currentPath[0]
	if !movingForward || extraStep:
		if currentPath[1] == 'left':
			currentPath[1] = 'right'
		elif currentPath[1] == 'right':
			currentPath[1] = 'left'
		elif currentPath[1] == 'up':
			currentPath[1] = 'down'
		elif currentPath[1] == 'down':
			currentPath[1] = 'up'
	$AnimatedSprite2D.play(currentPath[1]);
	if (currentPath[1] == 'left'):
		ray_container.rotation_degrees = 90
	elif (currentPath[1] == 'right'):
		ray_container.rotation_degrees = 270
	elif (currentPath[1] == 'up'):
		ray_container.rotation_degrees = 180
	elif (currentPath[1] == 'down'):
		ray_container.rotation_degrees = 0
	
	if movingForward:
		index += 1
	else:
		index -= 1
	if extraStep && index == 1 && movingForward:
		index -= 1
		extraStep = false;
	var direction = getDirection(currentPath[1])
	
	velocity = direction*speed;
	move_and_slide();
	timer.wait_time = wait_time;
	timer.start();

func _process(_delta):
	if Global.paused:
		timer.stop()
	else:
		if timer.paused:
			timer.start()
		move_and_slide();
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
		$Alert.show()
		$Alert/AnimationPlayer.play("alert_pop");
		foundWav.play();
	else:
		player_detected = 0;
		pass
		
func getDirection(direction):
	if (direction == 'left'):
		return Vector2.LEFT;
	elif (direction == 'right'):
		return Vector2.RIGHT;
	elif (direction == 'up'):
		return Vector2.UP;
	elif (direction == 'down'):
		return Vector2.DOWN;

extends CharacterBody2D

@export var movement_speed = 40.0

var snake: Node2D #assigned at runtime

var player_targeted = false
var prev_global_position: Vector2

var starting_position_targeted = false
var starting_position: Vector2
var patrol_path: Node2D
var direction: Vector2

func _ready() -> void:
	$Alert.hide()
	snake = get_tree().get_current_scene().get_node("Snake") as Node2D;
	self.visible = false
	prev_global_position = self.global_position
	starting_position = self.global_position
	
func _process(_delta):
	if self not in snake.detected_colliders:
		self.visible = false
		
	# Need to recalculate the velocity because the Path2Ds do
	# not use the velocity on this node
	var vel = prev_global_position - self.global_position
	prev_global_position = self.global_position
	var cardinal_direction = get_cardinal_direction(vel)
	forward_visibility_scan(cardinal_direction)
	#print(cardinal_direction
	$AnimatedSprite2D.play(cardinal_direction)

func _physics_process(_delta: float) -> void:
	# If the player is targeted currently and the nav path hasn't been completed
	if player_targeted && !$NavigationAgent2D.is_navigation_finished():
		var next_pos: Vector2 = $NavigationAgent2D.get_next_path_position();
		direction = global_position.direction_to(next_pos);
		velocity = direction * movement_speed
		move_and_slide()
		

func target_player():
	# If this is the first time spotting snake
	if !player_targeted:
		# Start navigating towards snake
		$NavigationAgent2D.target_position = snake.global_position
		$Alert.show()
		$Alert/AnimationPlayer.play("alert_pop");
		$FoundAudio.play();
		# Start the timer for recalculating the path targeting snake
		$NavigationAgent2D/TargetingRefreshTimer.start()
		# Reparent to self so we aren't back to the Path2D
		# patrol path
		patrol_path = get_parent()
		self.reparent(self)
		
		player_targeted = true
		
func target_starting_position():
	if !starting_position_targeted:
		# Start navigating towards snake
		$NavigationAgent2D.target_position = starting_position
		# Start the timer for recalculating the path targeting snake
		$NavigationAgent2D/TargetingRefreshTimer.start()
		starting_position_targeted = true
	
## Returns the cardinal direction (up/down/left/right) from velocity,
## snapping diagonals to the dominant axis (horizontal priority on ties).
## Returns Vector2i.ZERO if nearly stopped.
## Perfect for 2D movement/animations in CharacterBody2D or RigidBody2D.
func get_cardinal_direction(velocity: Vector2, threshold: float = 0.1) -> String:
	if velocity.length() < threshold:
		return "standingStill"
	
	var abs_x: float = absf(velocity.x)
	var abs_y: float = absf(velocity.y)
	
	if abs_x >= abs_y:
		return "right" if velocity.x < 0.0 else "left"
	else:
		return "down" if velocity.y < 0.0 else "up"


# Periodically update the target position since the player  will be moving around
func _on_targeting_refresh_timer_timeout() -> void:
	if !player_targeted:
		return
	
	if $NavigationAgent2D.target_position != snake.global_position:
		$NavigationAgent2D.target_position = snake.global_position
	$NavigationAgent2D/TargetingRefreshTimer.start()

var num_rays = 4
var radius = 300
var debug_rays = []
# if set to true will add a RayCast2D to the raycastquery so they are shown with the debugger
var debug_forward_visibility_scan = false
func forward_visibility_scan(direction: String = "down") -> void:
	var player_found = false
	var space_state = get_world_2d().direct_space_state
	
	var directions_map = {
		"right": Vector2.RIGHT,   # 0 degrees (right)
		"up": Vector2.UP,      # 90 degrees (up)
		"left": Vector2.LEFT,    # 180 degrees (left)
		"down": Vector2.DOWN,      # 270 degrees (down)
		"standingStill": Vector2.DOWN
	}
	
	var direction_vector = directions_map[direction]
	
	if debug_forward_visibility_scan:
		for r in debug_rays:
			remove_child(r)
	
	for i in range(num_rays):
		var offset_size = i * 0.2;		
		var offset_vector = Vector2(0.0, 0.0);
		match direction:
			"left":
				offset_vector = Vector2(0.0, 0.0  + offset_size)
			"up":
				offset_vector = Vector2(0.0 + offset_size, 0.0)
			"right":
				offset_vector = Vector2(0.0, 0.0 + offset_size)
			"down":
				offset_vector = Vector2(0.0 + offset_size, 0.0)
			"standingStill":
				offset_vector = Vector2(0.0 + offset_size, 0.0)
		
		for j in range(2):
			var to_vector = global_position + (direction_vector + offset_vector) * radius
			if j == 1:
				to_vector = global_position + (direction_vector - offset_vector) * radius
			
			var query = PhysicsRayQueryParameters2D.create(
				global_position,
				to_vector
			)
			
			# for debugging with show collision shapes
			if debug_forward_visibility_scan:
				var raycast_visual = RayCast2D.new();
				raycast_visual.position = self.position
				raycast_visual.set_target_position(to_local(query.to))
				query.collision_mask = 0b10
				add_child(raycast_visual)
				debug_rays.append(raycast_visual)
			
			query.exclude = [self]
			
			var result = space_state.intersect_ray(query)
			if result:
				var collider = result.collider as Node2D
				if collider.is_in_group("player"):
					target_player()
					player_found = true
					break
					
	if !player_found:
		player_targeted = false
		target_starting_position()
		

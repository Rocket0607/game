extends Actor

const MAX_VEL_X: = 550.0
const ACCEL_X: = 2500
const DECCEL_X: = 4000
const JUMP_HEIGHT: = 250
const JUMP_TIME: = 0.35
const JUMP_FALL_TIME = 0.3

var previous_direction: = Vector2.ZERO


var jump_vel: float = (2*JUMP_HEIGHT)/JUMP_TIME
var jump_gravity: float = ((-2*JUMP_HEIGHT)/(JUMP_TIME*JUMP_TIME)) * -1
var jump_fall_gravity: float = ((-2*JUMP_HEIGHT)/(JUMP_FALL_TIME*JUMP_FALL_TIME)) * -1


var dash_velocity = 2000.0
var dash_dur = 0.2 

@onready var dash = $Dash
	

func get_gravity(current_velocity_y: float) -> float:
	return jump_gravity if current_velocity_y > 0 else jump_fall_gravity

func get_jump() -> bool:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		return true
	else:
		return false

func get_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		get_jump()
	)
	
func get_dash(): 
	if Input.is_action_just_pressed("dash"): 
		dash.start_dash(dash_dur)	
		
	if dash.is_dashing():
		return true 
	else: 
		return false
		
func add_player_dash(direction: int): 
	if get_dash(): 
		velocity.x = dash_velocity * direction
		velocity.y = 0
		
	return velocity 

func add_player_x_movement(
	current_velocity: Vector2,
	current_direction: int, # 1 if right, -1 if left, 0 if neither
	#previous_direction: int, # 1 if right, -1 if left, 0 if neither
	) -> Vector2:
	var new_velocity: = current_velocity
	if current_direction == -previous_direction.x:
		new_velocity.x = 0
	if current_direction:
		new_velocity.x = abs(new_velocity.x) + ACCEL_X * get_physics_process_delta_time()
		new_velocity.x = clamp(new_velocity.x, 0, MAX_VEL_X)
		new_velocity.x = new_velocity.x * current_direction
		# MUTATION
		previous_direction.x = current_direction
	else:
		new_velocity.x = abs(new_velocity.x) - DECCEL_X * get_physics_process_delta_time()
		new_velocity.x = clamp(new_velocity.x, 0, MAX_VEL_X)
		new_velocity.x = new_velocity.x * previous_direction.x
	return new_velocity
	
func add_player_y_movement(
	current_velocity: Vector2,
	just_jumped: bool,
	jump_vel: float,
) -> Vector2:
	var new_velocity = current_velocity
	if just_jumped:
		new_velocity.y = -jump_vel
	return new_velocity
	
func add_player_gravity(
	current_velocity: Vector2,
	gravity: float,
) -> Vector2:
	var new_velocity: = current_velocity
	if !is_on_floor():
		new_velocity.y += gravity * get_physics_process_delta_time();
	return new_velocity

func calculate_final_velocity(
	velocities: PackedVector2Array
	) -> Vector2:
	var new_velocity: = Vector2.ZERO
	for v in velocities:
		new_velocity.x += v.x
		new_velocity.y += v.y
	return new_velocity


	
func _physics_process(delta):
	velocity = add_player_x_movement(velocity, get_direction().x)
	velocity = add_player_y_movement(velocity, get_jump(), jump_vel)
	velocity = add_player_gravity(velocity, get_gravity(velocity.y))
	add_player_dash(get_direction().x)
	move_and_slide()

@onready var _animated_sprite = $AnimatedSprite2D
func _process(delta):
	pass
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		_animated_sprite.play()
	else:
		_animated_sprite.stop()

extends KinematicBody

var ground_acceleration = 15
var air_acceleration = 2
var acceleration = ground_acceleration
var jump = 5
var gravity = 9.8
var mouse_sensitivity = 1
var turn_speed = 10 * ground_acceleration
var friction = 0.1

var direction = Vector3()
var velocity = Vector3()

var velocity_no_y = Vector3()

var oldx = 0;
var oldz = 0;
var jumped = false;
var dist = 0
var pre = 0;

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_degrees.y -= event.relative.x * mouse_sensitivity / 10
		$Camera.rotation_degrees.x = clamp($Camera.rotation_degrees.x - event.relative.y * mouse_sensitivity / 10, -90, 90)

	direction = Vector3()
	direction.z = -Input.get_action_strength("move_forward") + Input.get_action_strength("move_backward")
	direction.x = -Input.get_action_strength("move_left") + Input.get_action_strength("move_right")
	direction = direction.normalized().rotated(Vector3.UP, rotation.y)
	
	if Input.is_action_just_pressed("ui_cancel"):
			if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	
	velocity_no_y = velocity
	velocity_no_y.y = 0
	
	if is_on_ceiling():
		velocity.y = 0
	
	if is_on_floor():
		#velocity.y = -0.001
		acceleration = ground_acceleration
		velocity.x *= (1 - friction)
		velocity.z *= (1 - friction)
		if(jumped):
			dist = sqrt(pow(translation.x - oldx, 2) + pow(translation.z - oldz, 2))
		#oldx = translation.x
		#oldz = translation.z
		jumped = false
	else:
		acceleration = air_acceleration
		velocity.y -= gravity * delta
		#jumped = true
	
	if Input.is_action_pressed("jump") and is_on_floor():
		jumped = true;
		velocity.y = jump
		oldx = translation.x
		oldz = translation.z
		pre = velocity_no_y.length()
	
	velocity = accelerate(direction, velocity, acceleration, delta)
	
	velocity = move_and_slide(velocity, Vector3.UP)
	
	$Camera/VBoxContainer/Velocity.text = str(stepify(velocity_no_y.length(), 0.01))
	$Camera/VBoxContainer/Distance.text = str(stepify(dist, 0.01))
	$Camera/VBoxContainer/Pre.text = str(stepify(pre, 0.01))
	
func accelerate(wish_dir: Vector3, velocity: Vector3, max_speed: float, delta: float):
	var current_speed = velocity.dot(wish_dir)
	var add_speed = max_speed - current_speed
	add_speed = max(min(add_speed, turn_speed * delta), 0)
	return velocity + wish_dir * add_speed

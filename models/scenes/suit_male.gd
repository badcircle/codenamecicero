extends CharacterBody3D

const SPEED = 5.0
const JOG_SPEED = 7.5
const RUN_SPEED = 9.0
const DRIVE_SPEED = 15.0
const JUMP_VELOCITY = 4.5

var current_speed_cap : Array = [SPEED/2, SPEED, SPEED + (JOG_SPEED - SPEED) / 2, JOG_SPEED, JOG_SPEED + (RUN_SPEED - JOG_SPEED) / 2, RUN_SPEED]
var ani_current_speed_cap : Array = [0.25, 0.4, 0.55, 0.75, 0.85, 1]
var speed_cap_max = current_speed_cap.size() - 1
var current_speed_selected = 1
var current_speed : float = current_speed_cap[current_speed_selected]
var ani_current_speed : float = ani_current_speed_cap[current_speed_selected]

@export_node_path(Resource) var ani
@export_node_path(Resource) var ca

var input_dir
var going_backward = 0

func _ready():
	ani = get_node("AnimationTree")
	ca = get_node("CharacterArmature")

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	# Add gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		ani["parameters/roll/active"] = 1
	
	# Initial velocity calculation.
	velocity = _calc_velocity(delta)
	
	# Move.
	_set_move_speed(delta)
	_turn_player(delta)
	move_and_slide()

func _calc_velocity(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed * .1)
		velocity.z = move_toward(velocity.z, 0, current_speed * .1)
	
	return velocity

func _set_move_speed(delta):
	if Input.is_action_just_pressed("faster"):
		if current_speed_selected < speed_cap_max:
			current_speed_selected += 1
	if Input.is_action_just_pressed("slower"):
		if current_speed_selected > 0:
			current_speed_selected -= 1
	ani_current_speed = clamp(ani_current_speed_cap[current_speed_selected], 0, 1)
	current_speed = current_speed_cap[current_speed_selected]
	if abs(input_dir.x) + abs(input_dir.y) > 0:
		ani["parameters/walk/blend_amount"] = move_toward(ani["parameters/walk/blend_amount"], ani_current_speed, delta)
	else:
		ani["parameters/walk/blend_amount"] = move_toward(ani["parameters/walk/blend_amount"], 0, delta * 3)

func _turn_player(delta):
	if input_dir.y <= 0:
		going_backward = 180
	else:
		going_backward = 0
	ca.rotation.y = lerp_angle(ca.rotation.y, deg2rad(going_backward), delta * 3)
	if abs(input_dir.x) > 0:
		if abs(input_dir.x) < 0:
			ca.rotation.y = lerp_angle(ca.rotation.y, deg2rad(going_backward - input_dir.x * 45), delta * 3)
		else:
			ca.rotation.y = lerp_angle(ca.rotation.y, deg2rad(going_backward - input_dir.x * 90), delta * 3)


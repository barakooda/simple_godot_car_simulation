extends VehicleBody3D

@export var drive_force_max: float = 6500.0
@export var reverse_drive_force: float = 2800.0
@export var brake_force_max: float = 9000.0
@export var max_speed_mps: float = 22.2
@export var steer_rate: float = 2.2
@export var max_steer_angle: float = 0.38
@export var steer_assist_multiplier: float = 1.2
@export var engine_force_rise_rate: float = 7000.0
@export var engine_force_fall_rate: float = 12000.0
@export var lateral_grip: float = 8.5
@export var angular_stability: float = 4.2
@export var linear_drag: float = 0.0015
@export var reset_height_threshold: float = -6.0

var _input: VehicleInput = VehicleInput.new()
var _state: VehicleState = VehicleState.new()
var _steering: float = 0.0
var _engine_force_current: float = 0.0

func _ready() -> void:
	add_to_group("player_car")

func _physics_process(delta: float) -> void:
	_input.sample()

	var forward_speed: float = linear_velocity.dot(global_transform.basis.z)
	_state.speed_mps = linear_velocity.length()

	# Steering (speed-sensitive)
	var steer_scale: float = clampf(1.0 - (_state.speed_mps / max_speed_mps) * 0.72, 0.12, 1.0)
	var effective_max_steer: float = max_steer_angle * maxf(steer_assist_multiplier, 0.0)
	_steering = move_toward(_steering, _input.steer * effective_max_steer * steer_scale, steer_rate * delta)
	steering = -_steering

	# Drivetrain + braking using VehicleBody3D built-ins
	var target_engine_force: float = 0.0
	brake = 0.0

	if _input.throttle > 0.0:
		target_engine_force = drive_force_max * _input.throttle
	elif _input.throttle < 0.0:
		target_engine_force = reverse_drive_force * _input.throttle

	var engine_slew_rate: float = engine_force_fall_rate
	if absf(target_engine_force) > absf(_engine_force_current):
		engine_slew_rate = engine_force_rise_rate
	_engine_force_current = move_toward(_engine_force_current, target_engine_force, engine_slew_rate * delta)
	engine_force = _engine_force_current

	if _input.brake > 0.0:
		brake = brake_force_max * _input.brake

	# Optional extra braking when changing direction
	if _input.throttle > 0.0 and forward_speed < -0.2:
		brake = maxf(brake, brake_force_max * _input.throttle)
	elif _input.throttle < 0.0 and forward_speed > 0.2:
		brake = maxf(brake, brake_force_max * absf(_input.throttle))

	# Keep top speed cap from your old controller
	if linear_velocity.length() > max_speed_mps:
		linear_velocity = linear_velocity.normalized() * max_speed_mps

	if global_position.y < reset_height_threshold or Input.is_action_just_pressed("reset_vehicle"):
		reset_to_spawn()

	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func reset_to_spawn() -> void:
	var anchor := get_node_or_null("RespawnAnchor") as Marker3D
	if anchor:
		global_transform = anchor.global_transform
	else:
		global_position = Vector3(0.0, 1.0, 0.0)
		rotation = Vector3.ZERO
	_engine_force_current = 0.0
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

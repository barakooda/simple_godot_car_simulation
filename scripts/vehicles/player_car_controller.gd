extends RigidBody3D

@export var engine_force: float = 22000.0
@export var reverse_force: float = 9000.0
@export var brake_force: float = 17000.0
@export var max_speed: float = 22.2
@export var steer_rate: float = 2.0
@export var max_steer_angle: float = 0.38
@export var steer_assist_multiplier: float = 1.2
@export var lateral_grip: float = 8.5
@export var angular_stability: float = 4.2
@export var linear_drag: float = 0.0015
@export var reset_height_threshold: float = -6.0

var _input: VehicleInput = VehicleInput.new()
var _state: VehicleState = VehicleState.new()
var _steering: float = 0.0

func _ready() -> void:
	add_to_group("player_car")

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	_input.sample()
	var dt: float = state.step
	var forward: Vector3 = global_transform.basis.z
	var speed: float = state.linear_velocity.dot(forward)
	_state.speed_mps = state.linear_velocity.length()
	
	# ── Throttle / brake ──────────────────────────────────
	if _input.throttle > 0.0:
		if speed < -0.2:
			var forward_brake_delta: float = brake_force / mass * _input.throttle * dt
			state.linear_velocity = state.linear_velocity.move_toward(Vector3.ZERO, forward_brake_delta)
		else:
			var accel_vec: Vector3 = forward * (_input.throttle * engine_force / mass * dt)
			state.linear_velocity += accel_vec
	elif _input.throttle < 0.0:
		if speed > 0.2:
			var reverse_brake_delta: float = brake_force / mass * absf(_input.throttle) * dt
			state.linear_velocity = state.linear_velocity.move_toward(Vector3.ZERO, reverse_brake_delta)
		else:
			var accel_vec: Vector3 = forward * (_input.throttle * reverse_force / mass * dt)
			state.linear_velocity += accel_vec

	if _input.brake > 0.0:
		var brake_delta: float = brake_force / mass * _input.brake * dt
		state.linear_velocity = state.linear_velocity.move_toward(Vector3.ZERO, brake_delta)

	if absf(speed) > max_speed:
		state.linear_velocity -= forward * (speed - signf(speed) * max_speed)

	# ── Drag ──────────────────────────────────────────────
	state.linear_velocity *= (1.0 - linear_drag)

	# ── Steering ──────────────────────────────────────────
	var steer_scale: float = clampf(1.0 - (_state.speed_mps / max_speed) * 0.72, 0.12, 1.0)
	var effective_max_steer: float = max_steer_angle * maxf(steer_assist_multiplier, 0.0)
	_steering = move_toward(_steering, _input.steer * effective_max_steer * steer_scale, steer_rate * dt)
	var speed_factor: float = clampf(speed / 6.0, -1.0, 1.0)
	var target_yaw: float = -_steering * 2.2 * speed_factor
	state.angular_velocity.y = lerpf(state.angular_velocity.y, target_yaw, clampf(5.0 * dt, 0.0, 1.0))

	# ── Lateral grip ──────────────────────────────────────
	var local_vel: Vector3 = global_transform.basis.inverse() * state.linear_velocity
	local_vel.x = lerpf(local_vel.x, 0.0, clampf(lateral_grip * dt, 0.0, 1.0))
	state.linear_velocity = global_transform.basis * local_vel

	# ── Absolute speed cap (m/s) ─────────────────────────
	var velocity_len: float = state.linear_velocity.length()
	if velocity_len > max_speed:
		state.linear_velocity = state.linear_velocity / velocity_len * max_speed

	# ── Angular stability (damp roll/pitch only) ──────────
	state.angular_velocity.x = lerpf(state.angular_velocity.x, 0.0, clampf(angular_stability * dt, 0.0, 1.0))
	state.angular_velocity.z = lerpf(state.angular_velocity.z, 0.0, clampf(angular_stability * dt, 0.0, 1.0))

	# ── Reset ─────────────────────────────────────────────
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
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

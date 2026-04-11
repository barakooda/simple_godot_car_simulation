extends Node3D

@export var target_speed: float = 9.0
@export var acceleration_rate: float = 4.0
@export var brake_rate: float = 8.0
@export var look_ahead_distance: float = 4.0
@export var safe_follow_distance: float = 8.0
@export var hard_stop_distance: float = 3.0
@export var turn_speed_factor: float = 6.0
@export var spline_bake_interval: float = 1.5
@export var lane_offset: float = 0.0

var _current_speed: float = 0.0
var _waypoints: PackedVector3Array = []
var _route_curve: Curve3D = null
var _route_length: float = 0.0
var _path_progress: float = 0.0
var _route_initialized: bool = false

func set_lane_offset(offset: float) -> void:
	lane_offset = offset

func set_waypoints(points: PackedVector3Array) -> void:
	_waypoints = points
	_build_route_curve()

func _build_route_curve() -> void:
	_route_curve = null
	_route_length = 0.0
	_path_progress = 0.0
	_route_initialized = false
	if _waypoints.size() < 2:
		return

	var curve := Curve3D.new()
	curve.closed = true
	curve.bake_interval = maxf(0.2, spline_bake_interval)

	for i in range(_waypoints.size()):
		var current: Vector3 = _waypoints[i]
		curve.add_point(current)

	_route_curve = curve
	_route_length = _route_curve.get_baked_length()

func _physics_process(delta: float) -> void:
	if _route_curve == null or _route_length <= 0.001:
		return
	if not _route_initialized:
		_path_progress = _route_curve.get_closest_offset(global_position)
		_route_initialized = true

	var lookahead_offset: float = fposmod(_path_progress + maxf(look_ahead_distance, 0.1), _route_length)
	var target_center: Vector3 = _route_curve.sample_baked(lookahead_offset, true)

	var desired_speed: float = target_speed
	var front_sensor := get_node_or_null("FrontSensor") as RayCast3D
	if front_sensor and front_sensor.is_colliding():
		var hit_distance: float = front_sensor.get_collision_point().distance_to(front_sensor.global_position)
		if hit_distance < hard_stop_distance:
			desired_speed = 0.0
		elif hit_distance < safe_follow_distance:
			desired_speed = target_speed * 0.35

	if _current_speed < desired_speed:
		_current_speed = min(desired_speed, _current_speed + acceleration_rate * delta)
	else:
		_current_speed = max(desired_speed, _current_speed - brake_rate * delta)

	var move_distance: float = _current_speed * delta
	_path_progress = fposmod(_path_progress + move_distance, _route_length)

	var path_position: Vector3 = _route_curve.sample_baked(_path_progress, true)
	var tangent_offset: float = fposmod(_path_progress + maxf(look_ahead_distance * 0.3, 0.5), _route_length)
	var tangent_target: Vector3 = _route_curve.sample_baked(tangent_offset, true)
	var travel_dir: Vector3 = tangent_target - path_position
	travel_dir.y = 0.0
	if travel_dir.length_squared() <= 0.00001:
		travel_dir = target_center - path_position
		travel_dir.y = 0.0
	var lane_target: Vector3 = target_center
	if travel_dir.length_squared() > 0.00001:
		travel_dir = travel_dir.normalized()
		# Car local axes: forward +Z, right -X, so use the mirrored lateral vector.
		var right_local: Vector3 = Vector3(-travel_dir.z, 0.0, travel_dir.x)
		path_position += right_local * lane_offset
		lane_target += right_local * lane_offset
	global_position = Vector3(path_position.x, global_position.y, path_position.z)

	var facing_delta: Vector3 = lane_target - global_position
	facing_delta.y = 0.0
	rotation.x = 0.0
	rotation.z = 0.0
	if facing_delta.length_squared() > 0.00001:
		var target_yaw: float = atan2(facing_delta.x, facing_delta.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, clampf(turn_speed_factor * delta, 0.0, 1.0))

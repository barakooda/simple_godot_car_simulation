extends Node3D

@export var target_speed: float = 9.0
@export var acceleration_rate: float = 4.0
@export var brake_rate: float = 8.0
@export var look_ahead_distance: float = 4.0
@export var safe_follow_distance: float = 8.0
@export var hard_stop_distance: float = 3.0
@export var turn_speed_factor: float = 2.5

var _current_speed: float = 0.0
var _waypoints: PackedVector3Array = []
var _waypoint_index: int = 0

func set_waypoints(points: PackedVector3Array) -> void:
_waypoints = points
_waypoint_index = 0

func _physics_process(delta: float) -> void:
if _waypoints.is_empty():
return

var target := _waypoints[_waypoint_index]
var to_target := target - global_position
if to_target.length() < 1.5:
_waypoint_index = (_waypoint_index + 1) % _waypoints.size()
target = _waypoints[_waypoint_index]
to_target = target - global_position

var desired_dir := to_target.normalized()
var forward := -global_transform.basis.z
var angle := forward.signed_angle_to(desired_dir, Vector3.UP)
rotate_y(clamp(angle, -turn_speed_factor * delta, turn_speed_factor * delta))

var desired_speed := target_speed
var front_sensor := get_node_or_null("FrontSensor") as RayCast3D
if front_sensor and front_sensor.is_colliding():
var hit_distance := front_sensor.get_collision_point().distance_to(front_sensor.global_position)
if hit_distance < hard_stop_distance:
desired_speed = 0.0
elif hit_distance < safe_follow_distance:
desired_speed = target_speed * 0.35

if _current_speed < desired_speed:
_current_speed = min(desired_speed, _current_speed + acceleration_rate * delta)
else:
_current_speed = max(desired_speed, _current_speed - brake_rate * delta)

translate(-transform.basis.z * _current_speed * delta)

extends RefCounted
class_name PathFollower

var waypoints: PackedVector3Array = []
var current_index: int = 0

func set_points(points: PackedVector3Array) -> void:
	waypoints = points
	current_index = 0

func get_current_target() -> Vector3:
	if waypoints.is_empty():
		return Vector3.ZERO
	return waypoints[current_index]

func advance_if_close(position: Vector3, threshold: float = 1.5) -> void:
	if waypoints.is_empty():
		return
	if position.distance_to(waypoints[current_index]) <= threshold:
		current_index = (current_index + 1) % waypoints.size()

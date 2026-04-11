extends Node3D

@export var wheel_nodes: Array[NodePath] = []
@export var steer_wheels: Array[NodePath] = []
@export var steer_angle_max: float = 25.0

func sync_visuals(speed_mps: float, steer_norm: float, delta: float) -> void:
	for wheel_path in wheel_nodes:
		var wheel := get_node_or_null(wheel_path) as Node3D
		if wheel:
			wheel.rotate_x(-speed_mps * delta)
	for steer_path in steer_wheels:
		var steer_node := get_node_or_null(steer_path) as Node3D
		if steer_node:
			var r := steer_node.rotation_degrees
			r.y = steer_norm * steer_angle_max
			steer_node.rotation_degrees = r

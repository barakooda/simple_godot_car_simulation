extends Node3D

@export var npc_scene: PackedScene
@export var npc_count: int = 3
@export var spawn_radius: float = 25.0

var _route_points: PackedVector3Array = PackedVector3Array()
var _spawn_points: PackedVector3Array = PackedVector3Array()

func _ready() -> void:
	if npc_scene == null:
		npc_scene = preload("res://scenes/vehicles/npc_car.tscn")
	_collect_route_data()
	_spawn_default_traffic()

func _collect_route_data() -> void:
	var waypoint_nodes: Array[Node] = get_tree().get_nodes_in_group("npc_waypoint")
	waypoint_nodes.sort_custom(func(a: Node, b: Node) -> bool:
		return a.name.naturalnocasecmp_to(b.name) < 0
	)

	for node in waypoint_nodes:
		if node is Marker3D:
			_route_points.append((node as Marker3D).global_position)

	var spawn_nodes: Array[Node] = get_tree().get_nodes_in_group("npc_spawn")
	spawn_nodes.sort_custom(func(a: Node, b: Node) -> bool:
		return a.name.naturalnocasecmp_to(b.name) < 0
	)

	for node in spawn_nodes:
		if node is Marker3D:
			_spawn_points.append((node as Marker3D).global_position)

	if _route_points.is_empty():
		_route_points = PackedVector3Array([
			Vector3(-25, 0.6, -25),
			Vector3(25, 0.6, -25),
			Vector3(25, 0.6, 25),
			Vector3(-25, 0.6, 25)
		])

func _spawn_default_traffic() -> void:
	for i in range(npc_count):
		var npc := npc_scene.instantiate()
		if npc is Node3D:
			add_child(npc)
			if i < _spawn_points.size():
				npc.global_position = _spawn_points[i]
			else:
				var angle: float = TAU * float(i) / max(1.0, float(npc_count))
				npc.global_position = Vector3(cos(angle) * spawn_radius, 0.6, sin(angle) * spawn_radius)
			if npc.has_method("set_waypoints"):
				npc.set_waypoints(_route_points)

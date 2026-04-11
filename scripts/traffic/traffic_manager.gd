extends Node3D

@export var npc_scene: PackedScene
@export var npc_count: int = 15
@export var lane_offset_base: float = 1.1
@export var lane_offset_step: float = 0.2
@export var lane_offset_extra: float = 0.3
@export var road_bounds_margin: float = 0.35
@export var max_road_link_distance: float = 70.0

var _route_points: PackedVector3Array = PackedVector3Array()
var _road_nodes: Array[Node3D] = []
var _road_half_extents: Array[Vector2] = []
var _waypoint_graph: AStar3D = AStar3D.new()

func _ready() -> void:
	if npc_scene == null:
		npc_scene = preload("res://scenes/vehicles/npc_car.tscn")
	# Defer route collection until the full main scene tree is initialized.
	call_deferred("_initialize_traffic")

func _initialize_traffic() -> void:
	_collect_route_data()
	_spawn_default_traffic()

func _get_scene_root() -> Node:
	var scene_root: Node = get_tree().current_scene
	if scene_root != null:
		return scene_root
	# Fallback for tooling/headless launches where current_scene may not be set.
	var main_node: Node = get_tree().root.find_child("Main", true, false)
	if main_node != null:
		return main_node
	return get_tree().root

func _collect_route_data() -> void:
	_route_points = PackedVector3Array()
	_collect_road_footprints()
	_collect_waypoints_from_city_block()

	if _route_points.is_empty():
		# Backward-compatible fallback to group-based waypoints.
		var waypoint_nodes: Array[Node] = get_tree().get_nodes_in_group("npc_waypoint")
		waypoint_nodes.sort_custom(func(a: Node, b: Node) -> bool:
			return a.name.naturalnocasecmp_to(b.name) < 0
		)
		for node in waypoint_nodes:
			if node is Marker3D:
				_route_points.append((node as Marker3D).global_position)

	if _route_points.is_empty():
		_route_points = PackedVector3Array([
			Vector3(-25, 0.6, -25),
			Vector3(25, 0.6, -25),
			Vector3(25, 0.6, 25),
			Vector3(-25, 0.6, 25),
			Vector3(-25, 0.6, 0)
		])

	_build_waypoint_graph()

func _build_waypoint_graph() -> void:
	_waypoint_graph.clear()
	if _route_points.size() < 2:
		return
	for i in range(_route_points.size()):
		_waypoint_graph.add_point(i, _route_points[i])
	for i in range(_route_points.size()):
		for j in range(i + 1, _route_points.size()):
			var dist: float = _route_points[i].distance_to(_route_points[j])
			if dist <= max_road_link_distance:
				_waypoint_graph.connect_points(i, j, true)

func _collect_road_footprints() -> void:
	_road_nodes.clear()
	_road_half_extents.clear()
	var scene_root: Node = _get_scene_root()
	if scene_root == null:
		return
	var roads_root: Node3D = scene_root.find_child("Roads", true, false) as Node3D
	if roads_root == null:
		return
	for child in roads_root.get_children():
		var road_node: Node3D = child as Node3D
		if road_node == null:
			continue
		if not road_node.name.begins_with("Road"):
			continue
		var mesh_node: MeshInstance3D = road_node.find_child("MeshInstance3D", true, false) as MeshInstance3D
		if mesh_node == null or mesh_node.mesh == null:
			continue
		var mesh_aabb: AABB = mesh_node.mesh.get_aabb()
		var half_extents: Vector2 = Vector2(mesh_aabb.size.x * 0.5, mesh_aabb.size.z * 0.5)
		_road_nodes.append(road_node)
		_road_half_extents.append(half_extents)

func _collect_waypoints_from_city_block() -> void:
	var scene_root: Node = _get_scene_root()
	if scene_root == null:
		return
	var waypoints_root: Node3D = scene_root.find_child("WayPoints", true, false) as Node3D
	if waypoints_root == null:
		return
	var waypoint_nodes: Array[Node] = waypoints_root.find_children("WayPoint*", "Marker3D", true, false)
	waypoint_nodes.sort_custom(func(a: Node, b: Node) -> bool:
		return a.name.naturalnocasecmp_to(b.name) < 0
	)
	for node in waypoint_nodes:
		if node is Marker3D:
			_route_points.append((node as Marker3D).global_position)

func _spawn_default_traffic() -> void:
	if _route_points.size() < 2:
		return

	var spawn_count: int = _route_points.size()
	if spawn_count == 0:
		return
	npc_count = spawn_count

	for i in range(spawn_count):
		var npc_instance: Node = npc_scene.instantiate()
		if npc_instance is Node3D:
			var npc: Node3D = npc_instance as Node3D
			add_child(npc)
			var start_index: int = i
			var lane_offset: float = clampf(lane_offset_base + float(i % 3) * lane_offset_step + lane_offset_extra, 0.0, 2.0)
			var route: PackedVector3Array = _build_lane_route(start_index, i)
			npc.global_position = _compute_spawn_position(route)
			_align_npc_forward(npc, route)
			if npc.has_method("set_waypoints"):
				npc.set_waypoints(route)
			if npc.has_method("set_lane_offset"):
				npc.set_lane_offset(lane_offset)

func _build_lane_route(start_index: int, car_index: int) -> PackedVector3Array:
	var index_route: Array[int] = []
	var route_size: int = _route_points.size()
	var step: int = _select_route_step(car_index, route_size)
	for i in range(route_size):
		var idx: int = posmod(start_index + i * step, route_size)
		index_route.append(idx)

	var route: PackedVector3Array = _expand_route_with_graph(index_route)
	if route.is_empty():
		for idx in index_route:
			route.append(_route_points[idx])
	return _constrain_route_to_roads(route)

func _select_route_step(car_index: int, route_size: int) -> int:
	if route_size <= 2:
		return 1
	var coprime_steps: Array[int] = []
	for step in range(1, route_size):
		if _gcd(step, route_size) == 1:
			coprime_steps.append(step)
	if coprime_steps.is_empty():
		return 1
	return coprime_steps[car_index % coprime_steps.size()]

func _gcd(a: int, b: int) -> int:
	var x: int = absi(a)
	var y: int = absi(b)
	while y != 0:
		var t: int = x % y
		x = y
		y = t
	return x

func _expand_route_with_graph(index_route: Array[int]) -> PackedVector3Array:
	var expanded: PackedVector3Array = PackedVector3Array()
	if index_route.size() < 2:
		return expanded
	for i in range(index_route.size()):
		var from_idx: int = index_route[i]
		var to_idx: int = index_route[(i + 1) % index_route.size()]
		var segment: PackedVector3Array = _waypoint_graph.get_point_path(from_idx, to_idx, true)
		if segment.is_empty():
			if expanded.is_empty():
				expanded.append(_route_points[from_idx])
			expanded.append(_route_points[to_idx])
			continue
		for j in range(segment.size()):
			if i > 0 and j == 0:
				continue
			expanded.append(segment[j])
	return expanded

func _constrain_route_to_roads(route: PackedVector3Array) -> PackedVector3Array:
	if route.is_empty() or _road_nodes.is_empty():
		return route
	var constrained: PackedVector3Array = PackedVector3Array()
	for i in range(route.size()):
		constrained.append(_project_point_to_roads(route[i]))
	return constrained

func _project_point_to_roads(point: Vector3) -> Vector3:
	if _road_nodes.is_empty():
		return point

	var best_point: Vector3 = point
	var best_dist_sq: float = INF

	for i in range(_road_nodes.size()):
		var road_node: Node3D = _road_nodes[i]
		var half_extents: Vector2 = _road_half_extents[i]
		var local: Vector3 = road_node.to_local(point)
		var clamped_x: float = clampf(local.x, -half_extents.x - road_bounds_margin, half_extents.x + road_bounds_margin)
		var clamped_z: float = clampf(local.z, -half_extents.y - road_bounds_margin, half_extents.y + road_bounds_margin)
		var candidate_local: Vector3 = Vector3(clamped_x, local.y, clamped_z)
		var candidate_world: Vector3 = road_node.to_global(candidate_local)
		var delta: Vector3 = candidate_world - point
		delta.y = 0.0
		var dist_sq: float = delta.length_squared()
		if dist_sq < best_dist_sq:
			best_dist_sq = dist_sq
			best_point = candidate_world

	best_point.y = point.y
	return best_point

func _compute_spawn_position(route: PackedVector3Array) -> Vector3:
	if route.is_empty():
		return Vector3.ZERO
	return route[0]

func _align_npc_forward(npc: Node3D, route: PackedVector3Array) -> void:
	if route.size() < 2:
		return
	var heading: Vector3 = route[1] - route[0]
	heading.y = 0.0
	if heading.length_squared() <= 0.00001:
		return
	npc.rotation.y = atan2(heading.x, heading.z)

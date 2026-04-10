extends Node3D

@export var npc_scene: PackedScene
@export var npc_count: int = 3
@export var spawn_radius: float = 25.0

var _route_points := PackedVector3Array([
	Vector3(-25, 0.6, -25),
	Vector3(25, 0.6, -25),
	Vector3(25, 0.6, 25),
	Vector3(-25, 0.6, 25)
])

func _ready() -> void:
	if npc_scene == null:
		npc_scene = preload("res://scenes/vehicles/npc_car.tscn")
	_spawn_default_traffic()

func _spawn_default_traffic() -> void:
	for i in range(npc_count):
		var npc := npc_scene.instantiate()
		if npc is Node3D:
			var angle: float = TAU * float(i) / max(1.0, float(npc_count))
			npc.global_position = Vector3(cos(angle) * spawn_radius, 0.6, sin(angle) * spawn_radius)
			add_child(npc)
			if npc.has_method("set_waypoints"):
				npc.set_waypoints(_route_points)

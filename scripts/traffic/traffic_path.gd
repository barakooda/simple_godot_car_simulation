extends Resource
class_name TrafficPath

@export var name: String = "route"
@export var points: PackedVector3Array = PackedVector3Array([
Vector3(-30, 0.6, -30),
Vector3(30, 0.6, -30),
Vector3(30, 0.6, 30),
Vector3(-30, 0.6, 30)
])

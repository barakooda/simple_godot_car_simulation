extends Node

@export var fallback_transform: Transform3D = Transform3D.IDENTITY

func reset_body(body: RigidBody3D, spawn_transform: Transform3D) -> void:
	body.global_transform = spawn_transform if spawn_transform != Transform3D.IDENTITY else fallback_transform
	body.linear_velocity = Vector3.ZERO
	body.angular_velocity = Vector3.ZERO

extends RefCounted
class_name VehicleInput

var throttle: float = 0.0
var brake: float = 0.0
var steer: float = 0.0
var handbrake: bool = false

func sample() -> void:
throttle = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
brake = Input.get_action_strength("brake")
steer = Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left")
handbrake = Input.is_action_pressed("handbrake")

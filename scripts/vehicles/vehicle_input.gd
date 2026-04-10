extends RefCounted
class_name VehicleInput

var throttle: float = 0.0
var brake: float = 0.0
var steer: float = 0.0
var handbrake: bool = false

func sample() -> void:
	var forward_strength: float = Input.get_action_strength("move_forward")
	var backward_strength: float = Input.get_action_strength("move_backward")
	if Input.is_action_pressed("move_forward"):
		forward_strength = maxf(forward_strength, 1.0)
	if Input.is_action_pressed("move_backward"):
		backward_strength = maxf(backward_strength, 1.0)
	throttle = forward_strength - backward_strength
	brake = Input.get_action_strength("brake")
	steer = Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left")
	handbrake = Input.is_action_pressed("handbrake")

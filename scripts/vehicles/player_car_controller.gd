extends RigidBody3D

@export var engine_force: float = 9000.0
@export var reverse_force: float = 4200.0
@export var brake_force: float = 13000.0
@export var max_speed: float = 28.0
@export var steer_rate: float = 2.5
@export var max_steer_angle: float = 0.5
@export var lateral_grip: float = 6.0
@export var angular_stability: float = 3.0
@export var linear_drag: float = 0.04
@export var reset_height_threshold: float = -6.0

var _input := VehicleInput.new()
var _state := VehicleState.new()

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
_input.sample()
_apply_drive_forces(state)
_apply_grip_and_stability(state)
if global_position.y < reset_height_threshold or Input.is_action_just_pressed("reset_vehicle"):
reset_to_spawn()
if Input.is_action_just_pressed("quit"):
get_tree().quit()

func _apply_drive_forces(state: PhysicsDirectBodyState3D) -> void:
var forward := -global_transform.basis.z
var speed := linear_velocity.dot(forward)
_state.speed_mps = linear_velocity.length()

var throttle := _input.throttle
if throttle > 0.0:
apply_central_force(forward * throttle * engine_force)
elif throttle < 0.0:
apply_central_force(forward * throttle * reverse_force)

if _input.brake > 0.0:
var braking := linear_velocity.normalized() * min(linear_velocity.length(), brake_force * _input.brake * state.step)
linear_velocity -= braking

if speed > max_speed:
linear_velocity -= forward * (speed - max_speed)

var steer_scale := clamp(1.0 - (_state.speed_mps / max_speed) * 0.65, 0.25, 1.0)
_state.steering_amount = move_toward(_state.steering_amount, _input.steer * max_steer_angle * steer_scale, steer_rate * state.step)
apply_torque(Vector3.UP * -_state.steering_amount * 1800.0)

linear_velocity *= (1.0 - linear_drag)

func _apply_grip_and_stability(state: PhysicsDirectBodyState3D) -> void:
var local_velocity := global_transform.basis.inverse() * linear_velocity
local_velocity.x = lerp(local_velocity.x, 0.0, clamp(lateral_grip * state.step, 0.0, 1.0))
linear_velocity = global_transform.basis * local_velocity
angular_velocity = angular_velocity.lerp(Vector3.ZERO, clamp(angular_stability * state.step, 0.0, 1.0))

func reset_to_spawn() -> void:
var respawn_anchor := get_node_or_null("RespawnAnchor") as Marker3D
if respawn_anchor:
global_transform = respawn_anchor.global_transform
else:
global_position = Vector3(0.0, 1.0, 0.0)
rotation = Vector3.ZERO
linear_velocity = Vector3.ZERO
angular_velocity = Vector3.ZERO

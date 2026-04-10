extends Node3D

@export var front_fov: float = 70.0
@export var rear_fov: float = 70.0
@export var side_fov: float = 70.0
@export var aerial_fov: float = 55.0
@export var driver_fov: float = 72.0
@export var driver_look_limit_deg: float = 80.0
@export var driver_pitch_limit_deg: float = 55.0
@export var driver_mouse_sensitivity: float = 0.12
@export var aerial_height: float = 35.0
@export var aerial_min_height: float = 10.0
@export var aerial_max_height: float = 80.0

var _feeds: Dictionary = {}
var _cameras: Dictionary = {}
var _source_cameras: Dictionary = {}
var _feed_cameras: Dictionary = {}
var _driver_source_camera: Camera3D = null
var _driver_base_transform: Transform3D = Transform3D.IDENTITY
var _driver_yaw_deg: float = 0.0
var _driver_pitch_deg: float = 0.0

func _ready() -> void:
	_setup_feed("driver", "OptionalMainDriverCamera", driver_fov)
	_setup_feed("front", "FrontCamera", front_fov)
	_setup_feed("rear", "RearCamera", rear_fov)
	_setup_feed("left", "LeftCamera", side_fov)
	_setup_feed("right", "RightCamera", side_fov)
	_setup_feed("aerial", "OptionalAerialHelperCamera", aerial_fov)
	set_aerial_height(aerial_height)
	set_process(true)

func _process(_delta: float) -> void:
	for feed_name in _feed_cameras.keys():
		_sync_feed_camera_transform(feed_name)

func _setup_feed(key: String, camera_name: String, fov: float) -> void:
	var source_camera := find_child(camera_name, true, false) as Camera3D
	if source_camera == null:
		return
	source_camera.current = false
	_source_cameras[key] = source_camera
	if key == "driver":
		_driver_source_camera = source_camera
		_driver_base_transform = source_camera.transform
		_driver_yaw_deg = 0.0
		_driver_pitch_deg = 0.0

	var viewport := SubViewport.new()
	viewport.name = "%sViewport" % key.capitalize()
	viewport.disable_3d = false
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.msaa_3d = Viewport.MSAA_DISABLED
	viewport.size = Vector2i(640, 360)

	var feed_camera := Camera3D.new()
	feed_camera.name = "%sFeedCamera" % key.capitalize()
	feed_camera.fov = fov
	feed_camera.current = true
	viewport.add_child(feed_camera)

	add_child(viewport)
	viewport.world_3d = get_viewport().world_3d

	_feed_cameras[key] = feed_camera
	_cameras[key] = feed_camera
	_sync_feed_camera_transform(key)
	_feeds[key] = viewport.get_texture()

func _sync_feed_camera_transform(feed_name: String) -> void:
	var source_camera := _source_cameras.get(feed_name, null) as Camera3D
	var feed_camera := _feed_cameras.get(feed_name, null) as Camera3D
	if source_camera == null or feed_camera == null:
		return
	feed_camera.global_transform = source_camera.global_transform

func get_feed(feed_name: String) -> Texture2D:
	return _feeds.get(feed_name, null)

func get_feed_fov(feed_name: String) -> float:
	var camera := _cameras.get(feed_name, null) as Camera3D
	if camera == null:
		return 0.0
	return camera.fov

func set_feed_fov(feed_name: String, fov: float) -> void:
	var camera := _cameras.get(feed_name, null) as Camera3D
	if camera == null:
		return
	var clamped_fov: float = clamp(fov, 35.0, 120.0)
	camera.fov = clamped_fov
	match feed_name:
		"driver":
			driver_fov = clamped_fov
		"front":
			front_fov = clamped_fov
		"rear":
			rear_fov = clamped_fov
		"left", "right":
			side_fov = clamped_fov
		"aerial":
			aerial_fov = clamped_fov

func has_feed(feed_name: String) -> bool:
	return _feeds.has(feed_name)

func set_aerial_height(height: float) -> void:
	aerial_height = clampf(height, aerial_min_height, aerial_max_height)
	var aerial_source := _source_cameras.get("aerial", null) as Camera3D
	if aerial_source == null:
		return
	var transform_copy := aerial_source.transform
	transform_copy.origin.y = aerial_height
	aerial_source.transform = transform_copy

func get_aerial_height() -> float:
	return aerial_height

func adjust_driver_look(delta_x: float, delta_y: float = 0.0) -> void:
	if _driver_source_camera == null:
		return
	_driver_yaw_deg = clampf(
		_driver_yaw_deg - delta_x * driver_mouse_sensitivity,
		-driver_look_limit_deg,
		driver_look_limit_deg
	)
	_driver_pitch_deg = clampf(
		_driver_pitch_deg + delta_y * driver_mouse_sensitivity,
		-driver_pitch_limit_deg,
		driver_pitch_limit_deg
	)
	_apply_driver_look()

func reset_driver_look() -> void:
	if _driver_source_camera == null:
		return
	_driver_yaw_deg = 0.0
	_driver_pitch_deg = 0.0
	_apply_driver_look()

func _apply_driver_look() -> void:
	if _driver_source_camera == null:
		return
	var yaw_basis := Basis(Vector3.UP, deg_to_rad(_driver_yaw_deg))
	var pitch_basis := Basis(Vector3.RIGHT, deg_to_rad(_driver_pitch_deg))
	var transform_copy := _driver_base_transform
	transform_copy.basis = yaw_basis * pitch_basis * _driver_base_transform.basis
	_driver_source_camera.transform = transform_copy

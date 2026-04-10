extends Control

const FEED_IDS: PackedStringArray = ["front", "rear", "left", "right"]
const MAIN_FEED_IDS: PackedStringArray = ["front", "rear", "left", "right", "driver"]
const MINIMAP_ZOOM_STEP: float = 2.0

var _current_main_feed: String = "driver"
var _current_feed_index: int = 0
var _player: RigidBody3D = null
var _camera_rig: Node = null
var _driver_look_enabled: bool = false

@onready var _main_panel: Node = $RootLayout/MainArea/MainFeedPanel
@onready var _minimap_panel: Node = $RootLayout/MainArea/MinimapPanel
@onready var _fps_label: Label = $RootLayout/MainArea/FpsPanel/FpsLabel
@onready var _status_label: Label = $RootLayout/MainArea/InfoBar/InfoContent/StatusLabel
@onready var _speedometer: Label = $RootLayout/MainArea/InfoBar/InfoContent/Speedometer
@onready var _driver_view_button: Button = $RootLayout/MainArea/InfoBar/InfoContent/DriverViewButton

@onready var _front_panel: Node = $RootLayout/SidePanelContainer/FrontPanel
@onready var _rear_panel: Node = $RootLayout/SidePanelContainer/RearPanel
@onready var _left_panel: Node = $RootLayout/SidePanelContainer/LeftPanel
@onready var _right_panel: Node = $RootLayout/SidePanelContainer/RightPanel

func _ready() -> void:
	_setup_panel(_front_panel, "front", "Front")
	_setup_panel(_rear_panel, "rear", "Rear")
	_setup_panel(_left_panel, "left", "Left")
	_setup_panel(_right_panel, "right", "Right")
	_driver_view_button.pressed.connect(_on_driver_view_pressed)
	if _minimap_panel is Control:
		(_minimap_panel as Control).gui_input.connect(_on_minimap_gui_input)

	_set_panel_label(_main_panel, "")
	if _main_panel.has_method("set_fov_controls_visible"):
		_main_panel.set_fov_controls_visible(false)

	_set_panel_label(_minimap_panel, "Map")
	if _minimap_panel.has_method("set_fov_controls_visible"):
		_minimap_panel.set_fov_controls_visible(false)

	_resolve_scene_references()
	_switch_main_feed("driver")
	_refresh_camera_textures()
	_refresh_fov_controls()
	_update_selection_highlight()
	_update_status_text()

func _process(_delta: float) -> void:
	if _player == null or _camera_rig == null:
		_resolve_scene_references()
	if _camera_rig:
		_refresh_camera_textures()
		_refresh_fov_controls()
	if _player:
		_update_speed()
	_update_fps()

func _input(event: InputEvent) -> void:
	var mouse_button := event as InputEventMouseButton
	if mouse_button and mouse_button.pressed and mouse_button.button_index == MOUSE_BUTTON_LEFT and _current_main_feed == "driver":
		var main_control := _main_panel as Control
		if main_control and main_control.get_global_rect().has_point(mouse_button.global_position):
			_set_driver_look_enabled(not _driver_look_enabled)
			get_viewport().set_input_as_handled()
			return

	var mouse_motion := event as InputEventMouseMotion
	if mouse_motion and _current_main_feed == "driver" and _driver_look_enabled and _camera_rig and _camera_rig.has_method("adjust_driver_look"):
		_camera_rig.adjust_driver_look(mouse_motion.relative.x, mouse_motion.relative.y)

	var key_event := event as InputEventKey
	if key_event and key_event.pressed and not key_event.echo and key_event.keycode == KEY_TAB:
		_cycle_main_feed()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("toggle_camera_layout"):
		_cycle_main_feed()
		get_viewport().set_input_as_handled()

func _cycle_main_feed() -> void:
	_current_feed_index = (_current_feed_index + 1) % FEED_IDS.size()
	_switch_main_feed(FEED_IDS[_current_feed_index])

func _setup_panel(panel: Node, feed_id: String, label_text: String) -> void:
	_set_panel_label(panel, label_text)
	if panel.has_method("set_feed_name"):
		panel.set_feed_name(feed_id)
	if panel.has_method("set_fov_controls_visible"):
		panel.set_fov_controls_visible(true)
	if panel.has_method("set_fov_locked"):
		panel.set_fov_locked(true)
	if panel.has_signal("panel_selected") and not panel.panel_selected.is_connected(_switch_main_feed):
		panel.panel_selected.connect(_switch_main_feed)
	if panel.has_signal("fov_changed") and not panel.fov_changed.is_connected(_on_panel_fov_changed):
		panel.fov_changed.connect(_on_panel_fov_changed)
	if panel.has_signal("fov_lock_changed") and not panel.fov_lock_changed.is_connected(_on_panel_fov_lock_changed):
		panel.fov_lock_changed.connect(_on_panel_fov_lock_changed)

func _resolve_scene_references() -> void:
	_player = get_tree().get_first_node_in_group("player_car") as RigidBody3D
	if _player == null:
		return
	_camera_rig = _player.get_node_or_null("CameraRig")

func _refresh_camera_textures() -> void:
	if _camera_rig == null or not _camera_rig.has_method("get_feed"):
		return
	_set_panel_texture(_main_panel, _camera_rig.get_feed(_current_main_feed))
	_set_panel_texture(_minimap_panel, _camera_rig.get_feed("aerial"))
	_set_panel_texture(_front_panel, _camera_rig.get_feed("front"))
	_set_panel_texture(_rear_panel, _camera_rig.get_feed("rear"))
	_set_panel_texture(_left_panel, _camera_rig.get_feed("left"))
	_set_panel_texture(_right_panel, _camera_rig.get_feed("right"))

func _refresh_fov_controls() -> void:
	if _camera_rig == null or not _camera_rig.has_method("get_feed_fov"):
		return
	_set_panel_fov(_front_panel, _camera_rig.get_feed_fov("front"))
	_set_panel_fov(_rear_panel, _camera_rig.get_feed_fov("rear"))
	_set_panel_fov(_left_panel, _camera_rig.get_feed_fov("left"))
	_set_panel_fov(_right_panel, _camera_rig.get_feed_fov("right"))

func _switch_main_feed(feed_id: String) -> void:
	if not MAIN_FEED_IDS.has(feed_id):
		return
	if feed_id != "driver" and _driver_look_enabled:
		_set_driver_look_enabled(false)
	_current_main_feed = feed_id
	if FEED_IDS.has(feed_id):
		_current_feed_index = FEED_IDS.find(feed_id)
	if _camera_rig and _camera_rig.has_method("get_feed"):
		_set_panel_texture(_main_panel, _camera_rig.get_feed(_current_main_feed))
	_update_selection_highlight()
	_update_status_text()

func _on_driver_view_pressed() -> void:
	_switch_main_feed("driver")

func _set_driver_look_enabled(is_enabled: bool) -> void:
	_driver_look_enabled = is_enabled
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if _driver_look_enabled else Input.MOUSE_MODE_VISIBLE)
	if not _driver_look_enabled and _camera_rig and _camera_rig.has_method("reset_driver_look"):
		_camera_rig.reset_driver_look()

func _on_panel_fov_changed(feed_id: String, fov: float) -> void:
	if _camera_rig == null or not _camera_rig.has_method("set_feed_fov"):
		return
	var source_panel := _get_panel_by_feed(feed_id)
	if _is_panel_locked(source_panel):
		for candidate_feed_id in FEED_IDS:
			var candidate_panel := _get_panel_by_feed(candidate_feed_id)
			if _is_panel_locked(candidate_panel):
				_camera_rig.set_feed_fov(candidate_feed_id, fov)
	else:
		_camera_rig.set_feed_fov(feed_id, fov)
	_refresh_fov_controls()

func _on_panel_fov_lock_changed(_feed_id: String, _is_locked: bool) -> void:
	_refresh_fov_controls()

func _on_minimap_gui_input(event: InputEvent) -> void:
	if _camera_rig == null:
		return
	if not _camera_rig.has_method("get_aerial_height") or not _camera_rig.has_method("set_aerial_height"):
		return
	var mouse_button := event as InputEventMouseButton
	if mouse_button == null or not mouse_button.pressed:
		return
	if mouse_button.button_index == MOUSE_BUTTON_WHEEL_UP:
		_adjust_minimap_zoom(-MINIMAP_ZOOM_STEP)
		accept_event()
	elif mouse_button.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		_adjust_minimap_zoom(MINIMAP_ZOOM_STEP)
		accept_event()

func _adjust_minimap_zoom(delta: float) -> void:
	var current_height: float = _camera_rig.get_aerial_height()
	_camera_rig.set_aerial_height(current_height + delta)

func _get_panel_by_feed(feed_id: String) -> Node:
	match feed_id:
		"front":
			return _front_panel
		"rear":
			return _rear_panel
		"left":
			return _left_panel
		"right":
			return _right_panel
	return null

func _set_panel_fov(panel: Node, fov: float) -> void:
	if panel and panel.has_method("set_fov_value"):
		panel.set_fov_value(fov)

func _is_panel_locked(panel: Node) -> bool:
	if panel and panel.has_method("is_fov_locked"):
		return panel.is_fov_locked()
	return false

func _update_selection_highlight() -> void:
	if _front_panel.has_method("set_selected"):
		_front_panel.set_selected(_current_main_feed == "front")
	if _rear_panel.has_method("set_selected"):
		_rear_panel.set_selected(_current_main_feed == "rear")
	if _left_panel.has_method("set_selected"):
		_left_panel.set_selected(_current_main_feed == "left")
	if _right_panel.has_method("set_selected"):
		_right_panel.set_selected(_current_main_feed == "right")

func _update_status_text() -> void:
	_status_label.text = "Camera: %s" % _current_main_feed.capitalize()

func _update_speed() -> void:
	if _speedometer and _speedometer.has_method("set_speed_mps"):
		_speedometer.set_speed_mps(_player.linear_velocity.length())

func _update_fps() -> void:
	if _fps_label:
		_fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

func _set_panel_label(panel: Node, text_value: String) -> void:
	if panel and panel.has_method("set_label"):
		panel.set_label(text_value)

func _set_panel_texture(panel: Node, texture: Texture2D) -> void:
	if panel and panel.has_method("set_texture"):
		panel.set_texture(texture)



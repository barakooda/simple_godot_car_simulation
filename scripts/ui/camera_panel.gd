extends PanelContainer

signal panel_selected(feed_name: String)
signal fov_changed(feed_name: String, fov: float)
signal fov_lock_changed(feed_name: String, is_locked: bool)

var _feed_name: String = ""
var _current_fov: float = 70.0

const FOV_STEP: float = 2.0
const FOV_MIN: float = 35.0
const FOV_MAX: float = 120.0

@onready var _select_button: Button = $VBoxContainer/TopRow/SelectButton
@onready var _lock_toggle: CheckButton = $VBoxContainer/TopRow/LockToggle
@onready var _fov_value_label: Label = $VBoxContainer/TopRow/FovValueLabel
@onready var _texture_rect: TextureRect = $VBoxContainer/TextureRect

func _ready() -> void:
	_select_button.pressed.connect(_on_select_pressed)
	_lock_toggle.toggled.connect(_on_lock_toggled)
	gui_input.connect(_on_gui_input)

func set_label(value: String) -> void:
	_select_button.text = value

func set_feed_name(feed_name: String) -> void:
	_feed_name = feed_name

func set_selected(selected: bool) -> void:
	modulate = Color(1.0, 1.0, 1.0, 1.0) if selected else Color(0.88, 0.88, 0.88, 1.0)

func set_texture(texture: Texture2D) -> void:
	if _texture_rect:
		_texture_rect.texture = texture

func set_fov_controls_visible(controls_visible: bool) -> void:
	_lock_toggle.visible = controls_visible
	_fov_value_label.visible = controls_visible

func set_fov_value(value: float) -> void:
	_current_fov = clampf(value, FOV_MIN, FOV_MAX)
	_update_fov_text()

func set_fov_locked(is_locked: bool) -> void:
	_lock_toggle.button_pressed = is_locked

func is_fov_locked() -> bool:
	return _lock_toggle.button_pressed

func _on_select_pressed() -> void:
	panel_selected.emit(_feed_name)

func _on_gui_input(event: InputEvent) -> void:
	if _feed_name == "":
		return
	var mouse_button := event as InputEventMouseButton
	if mouse_button == null or not mouse_button.pressed:
		return
	if mouse_button.button_index == MOUSE_BUTTON_WHEEL_UP:
		_current_fov = clampf(_current_fov - FOV_STEP, FOV_MIN, FOV_MAX)
		_update_fov_text()
		fov_changed.emit(_feed_name, _current_fov)
		accept_event()
	elif mouse_button.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		_current_fov = clampf(_current_fov + FOV_STEP, FOV_MIN, FOV_MAX)
		_update_fov_text()
		fov_changed.emit(_feed_name, _current_fov)
		accept_event()

func _on_lock_toggled(is_locked: bool) -> void:
	fov_lock_changed.emit(_feed_name, is_locked)

func _update_fov_text() -> void:
	if _fov_value_label:
		_fov_value_label.text = "FOV: %d" % int(round(_current_fov))

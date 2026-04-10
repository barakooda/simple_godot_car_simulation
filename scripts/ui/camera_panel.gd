extends PanelContainer

signal panel_selected(feed_name: String)
signal fov_changed(feed_name: String, fov: float)
signal fov_lock_changed(feed_name: String, is_locked: bool)

var _feed_name: String = ""
var _suppress_fov_signal: bool = false

@onready var _select_button: Button = $VBoxContainer/TopRow/SelectButton
@onready var _lock_toggle: CheckButton = $VBoxContainer/TopRow/LockToggle
@onready var _fov_slider: HSlider = $VBoxContainer/FovRow/FovSlider
@onready var _fov_spinbox: SpinBox = $VBoxContainer/FovRow/FovSpinBox
@onready var _texture_rect: TextureRect = $VBoxContainer/TextureRect

func _ready() -> void:
	_select_button.pressed.connect(_on_select_pressed)
	_lock_toggle.toggled.connect(_on_lock_toggled)
	_fov_slider.value_changed.connect(_on_slider_changed)
	_fov_spinbox.value_changed.connect(_on_spinbox_changed)

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
	$VBoxContainer/FovRow/FovLabel.visible = controls_visible
	_fov_slider.visible = controls_visible
	_fov_spinbox.visible = controls_visible

func set_fov_value(value: float) -> void:
	_suppress_fov_signal = true
	_fov_slider.value = value
	_fov_spinbox.value = value
	_suppress_fov_signal = false

func set_fov_locked(is_locked: bool) -> void:
	_lock_toggle.button_pressed = is_locked

func is_fov_locked() -> bool:
	return _lock_toggle.button_pressed

func _on_select_pressed() -> void:
	panel_selected.emit(_feed_name)

func _on_slider_changed(value: float) -> void:
	if _suppress_fov_signal:
		return
	_suppress_fov_signal = true
	_fov_spinbox.value = value
	_suppress_fov_signal = false
	fov_changed.emit(_feed_name, value)

func _on_spinbox_changed(value: float) -> void:
	if _suppress_fov_signal:
		return
	_suppress_fov_signal = true
	_fov_slider.value = value
	_suppress_fov_signal = false
	fov_changed.emit(_feed_name, value)

func _on_lock_toggled(is_locked: bool) -> void:
	fov_lock_changed.emit(_feed_name, is_locked)

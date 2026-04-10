extends Control

var _layout_grid_mode: bool = false

func _ready() -> void:
	_assign_default_labels()
	_connect_feeds_if_possible()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("toggle_camera_layout"):
		_layout_grid_mode = !_layout_grid_mode
		$MarginContainer/StatusLabel.text = "Layout: 2x2 Grid" if _layout_grid_mode else "Layout: Driver + 3 PiP"

func _assign_default_labels() -> void:
	_set_panel_label($MarginContainer/RootLayout/MainFeedPanel, "Front")
	_set_panel_label($MarginContainer/RootLayout/SidePanelContainer/FrontPanel, "Front")
	_set_panel_label($MarginContainer/RootLayout/SidePanelContainer/RearPanel, "Rear")
	_set_panel_label($MarginContainer/RootLayout/SidePanelContainer/LeftPanel, "Left")
	_set_panel_label($MarginContainer/RootLayout/SidePanelContainer/RightPanel, "Right")

func _connect_feeds_if_possible() -> void:
	var player := get_tree().get_first_node_in_group("player_car") as Node3D
	if player == null:
		return
	var rig := player.get_node_or_null("CameraRig")
	if rig == null or not rig.has_method("get_feed"):
		return
	_set_panel_texture($MarginContainer/RootLayout/MainFeedPanel, rig.get_feed("front"))
	_set_panel_texture($MarginContainer/RootLayout/SidePanelContainer/FrontPanel, rig.get_feed("front"))
	_set_panel_texture($MarginContainer/RootLayout/SidePanelContainer/RearPanel, rig.get_feed("rear"))
	_set_panel_texture($MarginContainer/RootLayout/SidePanelContainer/LeftPanel, rig.get_feed("left"))
	_set_panel_texture($MarginContainer/RootLayout/SidePanelContainer/RightPanel, rig.get_feed("right"))

func _set_panel_label(panel: Node, text_value: String) -> void:
	if panel and panel.has_method("set_label"):
		panel.set_label(text_value)

func _set_panel_texture(panel: Node, texture: Texture2D) -> void:
	if panel and panel.has_method("set_texture"):
		panel.set_texture(texture)

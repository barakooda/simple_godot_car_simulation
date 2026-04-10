extends PanelContainer

@onready var _label: Label = $VBoxContainer/Label
@onready var _texture_rect: TextureRect = $VBoxContainer/TextureRect

func set_label(value: String) -> void:
if _label:
_label.text = value

func set_texture(texture: Texture2D) -> void:
if _texture_rect:
_texture_rect.texture = texture

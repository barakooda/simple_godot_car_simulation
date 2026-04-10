extends Node3D

@export var front_fov: float = 75.0
@export var rear_fov: float = 70.0
@export var side_fov: float = 65.0

var _feeds: Dictionary = {}

func _ready() -> void:
_setup_feed("front", "FrontCamera", front_fov)
_setup_feed("rear", "RearCamera", rear_fov)
_setup_feed("left", "LeftCamera", side_fov)
_setup_feed("right", "RightCamera", side_fov)

func _setup_feed(key: String, camera_name: String, fov: float) -> void:
var camera := find_child(camera_name, true, false) as Camera3D
if camera == null:
return
camera.fov = fov
var viewport := SubViewport.new()
viewport.name = "%sViewport" % key.capitalize()
viewport.disable_3d = false
viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
viewport.msaa_3d = Viewport.MSAA_DISABLED
viewport.size = Vector2i(640, 360)
add_child(viewport)
camera.reparent(viewport)
viewport.world_3d = get_viewport().world_3d
_feeds[key] = viewport.get_texture()

func get_feed(feed_name: String) -> Texture2D:
return _feeds.get(feed_name, null)

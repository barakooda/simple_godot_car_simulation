extends Node
class_name CameraFeedRegistry

var _provider: Node = null

func set_provider(provider: Node) -> void:
_provider = provider

func get_feed(name: String) -> Texture2D:
if _provider and _provider.has_method("get_feed"):
return _provider.get_feed(name)
return null

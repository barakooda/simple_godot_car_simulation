extends Node

func load_world(scene_path: String) -> Node:
var packed := load(scene_path) as PackedScene
return packed.instantiate() if packed else null

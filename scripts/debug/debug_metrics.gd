extends Label

var lines: PackedStringArray = PackedStringArray([])

func set_lines(new_lines: PackedStringArray) -> void:
	lines = new_lines
	text = "\n".join(lines)

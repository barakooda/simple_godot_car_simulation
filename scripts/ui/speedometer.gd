extends Label

func set_speed_mps(speed_mps: float) -> void:
var speed_kmh := speed_mps * 3.6
text = "%d km/h" % int(round(speed_kmh))

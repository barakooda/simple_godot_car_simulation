extends Node
class_name LayoutController

enum LayoutMode {
DRIVER_WITH_PIP,
GRID_2X2,
}

var mode: LayoutMode = LayoutMode.DRIVER_WITH_PIP

func toggle() -> LayoutMode:
mode = LayoutMode.GRID_2X2 if mode == LayoutMode.DRIVER_WITH_PIP else LayoutMode.DRIVER_WITH_PIP
return mode

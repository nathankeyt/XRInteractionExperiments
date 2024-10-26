extends Label3D


func _ready() -> void:
	Debug.print_log.connect(display_log)

func display_log(log: String):
	text = log

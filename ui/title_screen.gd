extends Control
class_name TitleScreen

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	start_button.pressed.connect( _on_start_pressed )

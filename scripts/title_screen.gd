extends Control
class_name TitleScreen

@onready var start_button : Button = $VBoxContainer/StartButton

func _ready() -> void:
	start_button.pressed.connect( _on_start_pressed )

func _on_start_pressed() -> void:
	_start_game()

func _unhandled_input( e: InputEvent ) -> void:
	if e.is_action_pressed("start"):
		_start_game()

func _start_game() -> void:
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file( "res://scenes/stage_manager.tscn" )

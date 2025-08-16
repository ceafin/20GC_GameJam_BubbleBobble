extends Control
class_name TitleScreen

@onready var start_button : Button = $VBoxContainer/StartButton

func _ready() -> void:
	start_button.pressed.connect( _on_start_pressed )

func _on_start_pressed() -> void:
	
	# Load the intro non-stage for the game start
	GameManager.start_game( "res://stages/stage_intro.tscn" )

extends Node
class_name Main

@onready var level_manager : LevelManager = $LevelManager
@onready var ui_layer : UI = $UI

var _hud : Control
var _title : Control

const HUD_SCENE : PackedScene = preload("res://ui/hud.tscn")
const TITLE_SCENE : PackedScene = preload("res://ui/title_screen.tscn")

func _ready() -> void:
	
	# Instantiate and Add the UI scenes
	_hud = HUD_SCENE.instantiate()
	ui_layer.add_child( _hud )
	_title = TITLE_SCENE.instantiate()
	ui_layer.add_child( _title )
	
	_update_ui_for_state( GameManager.state )

	# Wire up the Autoloader:GameManager's Signals
	GameManager.connect( "game_state_changed", Callable( self, "_on_game_state_changed" ) )
	GameManager.connect( "level_changed", Callable( self, "_on_level_changed" ) )

func _on_game_state_changed( state: String ) -> void:
	_update_ui_for_state( state )

func _on_level_changed( path: String ) -> void:
	# Delegate to LevelManager to actually load the level
	if level_manager as LevelManager:
		if level_manager.has_method( "load_first_level" ):
			level_manager.load_first_level( path )

func _update_ui_for_state( state: String ) -> void:
	match state:
		"TITLE":
			get_tree().paused = false
			_title.visible = true
			_hud.visible = false
		"PLAYING":
			_title.visible = false
			_hud.visible = true
		"GAME_OVER":
			_title.visible = true
			_hud.visible = false

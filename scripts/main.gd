extends Node
class_name Main

@onready var stage_manager : StageManager = $StageManager
@onready var ui_layer : UI = $UI
@onready var camera_2d : Camera2D = $Camera2D

var _hud : HUD
var _title : Control

const HUD_SCENE : PackedScene = preload("res://ui/hud.tscn")
const TITLE_SCENE : PackedScene = preload("res://ui/title_screen.tscn")

func _ready() -> void:
	
	# I know I set this in the Inspector, but damnit it better stay that way
	camera_2d.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	camera_2d.position = Vector2.ZERO

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
	if stage_manager as StageManager:
		if stage_manager.has_method( "load_first_level" ):
			stage_manager.load_first_level( path )

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

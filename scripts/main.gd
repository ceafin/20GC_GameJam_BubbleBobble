extends Node
class_name Main

@onready var stage_manager : StageManager = $StageManager
@onready var ui_layer : UI = $UI
@onready var camera_2d : Camera2D = $Camera2D

var _hud : HUD
var _title : Control

const HUD_SCENE : PackedScene = preload("res://ui/hud.tscn")

func _ready() -> void:
	
	# I know I set this in the Inspector, but damnit it better stay that way
	camera_2d.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	camera_2d.position = Vector2.ZERO

	# Instantiate and Add the UI scenes
	_hud = HUD_SCENE.instantiate()
	_hud.position = Vector2(0,1)
	ui_layer.add_child( _hud )
	
	_update_ui_for_state( GM.state )

	# Wire up the Autoloader:GameManager's Signals
	GSB.game_state_changed.connect( Callable( self, "_on_game_state_changed" ) )
	GSB.stage_changed.connect( Callable( self, "_on_stage_changed" ) )

func _on_game_state_changed( state: GameManager.GameState ) -> void:
	_update_ui_for_state( state )

func _on_stage_changed( path: String ) -> void:
	# Delegate to LevelManager to actually load the level
	if stage_manager as StageManager:
		if stage_manager.has_method( "load_first_level" ):
			stage_manager.load_first_level( path )

func _update_ui_for_state( state: GameManager.GameState ) -> void:
	match state:
		GM.GameState.TITLE:
			get_tree().paused = false
			#_title.visible = true
			_hud.visible = false
		GM.GameState.PLAYING:
			#_title.visible = false
			_hud.visible = true
		GM.GameState.GAME_OVER:
			#_title.visible = true
			_hud.visible = false

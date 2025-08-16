extends Control
class_name HUD

@onready var score_label: Label = $HBoxTop/ScoreLabel
@onready var stage_label: Label = $HBoxTop/StageLabel
@onready var high_label : Label = $HBoxTop/HighScoreLabel

@onready var lives_label: Label = $HBoxBottom/LivesLabel
@onready var lives_label_2: Label = $HBoxBottom/LivesLabel2

@onready var hurry_banner : Label = $HurryBanner

func _ready() -> void:
	
	hurry_banner.visible = false
	
	# Just manually update all the things
	_update_score( ScoreManager.score )
	_update_high( ScoreManager.high_score )
	_update_lives( ScoreManager.lives )
	
	_update_stage( GameManager.stage_number )

	# Wire up the signals
	ScoreManager.connect( "score_changed", Callable( self, "_update_score" ) )
	ScoreManager.connect( "high_score_changed", Callable( self, "_update_high" ) )
	ScoreManager.connect( "lives_changed", Callable( self, "_update_lives" ) )
	GameManager.connect( "stage_changed", Callable( self, "_update_stage" ) )

func _update_score( v: int ) -> void:
	score_label.text = "SCORE: %d" % v

func _update_high( v: int ) -> void:
	high_label.text = "HIGH: %d" % v

func _update_lives( v: int ) -> void:
	lives_label.text = "LIVES: %d" % v

func _update_stage( v: int ) -> void:
	stage_label.text = "STAGE: %d" % v

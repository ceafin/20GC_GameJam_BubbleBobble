extends Control
class_name HUD

@onready var score_label: Label = $HBoxTop/ScoreLabel
@onready var stage_label: Label = $HBoxTop/StageLabel
@onready var high_label : Label = $HBoxTop/HighScoreLabel

@onready var lives_label: Label = $HBoxBottom/LivesLabel
@onready var advance_level_button: Button = $HBoxBottom/AdvanceLevelButton

func _ready() -> void:
		
	# Just manually update all the things
	_update_high( SM.high_score )
	_update_score( SM.score )
	_update_lives( GM.lives )
	_update_stage( GM.stage_number )

	# Wire up the signals
	GSB.high_score_changed.connect( Callable( self, "_update_high" ) )
	GSB.score_changed.connect( Callable( self, "_update_score" ) )
	GSB.lives_changed.connect( Callable( self, "_update_lives" ) )
	GSB.stage_changed.connect( Callable( self, "_update_stage" ) )

func _update_high( v: int ) -> void:
	high_label.text = "HIGH: %d" % v

func _update_score( v: int ) -> void:
	score_label.text = "SCORE: %d" % v

func _update_lives( v: int ) -> void:
	lives_label.text = "LIVES: %d" % v

func _update_stage( v: int ) -> void:
	stage_label.text = "STAGE: %d" % v

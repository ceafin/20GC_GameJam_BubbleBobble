extends Control
class_name HUD

@onready var score_label : Label = $ScoreLabel
@onready var high_label : Label = $HighScoreLabel
@onready var lives_label : Label = $LivesLabel
@onready var round_label : Label = $RoundLabel
@onready var hurry_banner : Label = $HurryBanner

func _ready() -> void:
	
	hurry_banner.visible = false
	
	# Just manually update all the things
	_update_score( ScoreManager.score )
	_update_high( ScoreManager.high_score )
	_update_lives( ScoreManager.lives )
	
	_update_round( GameManager.round_number )

	# Wire up the signals
	ScoreManager.connect( "score_changed", Callable( self, "_update_score" ) )
	ScoreManager.connect( "high_score_changed", Callable( self, "_update_high" ) )
	ScoreManager.connect( "lives_changed", Callable( self, "_update_lives" ) )
	GameManager.connect( "round_changed", Callable( self, "_update_round" ) )

func _update_score( v: int ) -> void:
	score_label.text = "SCORE: %d" % v

func _update_high( v: int ) -> void:
	high_label.text = "HIGH: %d" % v

func _update_lives( v: int ) -> void:
	lives_label.text = "LIVES: %d" % v

func _update_round( v: int ) -> void:
	round_label.text = "ROUND: %d" % v

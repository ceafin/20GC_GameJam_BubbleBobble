extends Node
class_name GlobalSignalBus

signal high_score_changed( value: int )
signal score_changed( value: int )

signal lives_changed( value: int )

signal game_state_changed( state: int )
signal stage_changed( path: String )

signal stage_complete()

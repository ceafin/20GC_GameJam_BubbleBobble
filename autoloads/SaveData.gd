extends Node2D

const SAVE_PATH := "user://save.json"

var data : Dictionary = {
	"high_score": 0,
	"options": {
		"music_volume": 0.8,
		"sfx_volume": 1.0
	}
}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_load_data()

func _load_data() -> void:
	if not FileAccess.file_exists( SAVE_PATH ):
		return
	var f : FileAccess = FileAccess.open( SAVE_PATH, FileAccess.READ )
	var parsed : Variant = JSON.parse_string( f.get_as_text() )
	if typeof( parsed ) == TYPE_DICTIONARY:
		data = parsed

func save() -> void:
	var f : FileAccess = FileAccess.open( SAVE_PATH, FileAccess.WRITE )
	f.store_string( JSON.stringify( data ) )

func get_high_score() -> int:
	return int( data.get( "high_score", 0 ) )

func set_high_score( v: int ) -> void:
	data[ "high_score" ] = v
	save()

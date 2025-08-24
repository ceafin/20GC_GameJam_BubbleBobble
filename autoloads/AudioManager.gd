extends Node
class_name AudioManager

var _sfx : AudioStreamPlayer = AudioStreamPlayer.new()
var _music : AudioStreamPlayer = AudioStreamPlayer.new()

@export var sfx_bus : String = "SFX"
@export var music_bus : String = "Music"

func _ready() -> void:
	
	# Instantiate the kids
	add_child( _sfx )
	_sfx.bus = sfx_bus
	add_child( _music )
	_music.bus = music_bus


func play_sfx( stream: AudioStream, pitch_scale: float = 1.0 ) -> void:
	if not stream:
		return
	
	_sfx.pitch_scale = pitch_scale
	_sfx.stream = stream
	_sfx.play()


func play_music( stream: AudioStream, restart: bool = false ) -> void:
	if not stream:
		return
	
	if restart or _music.stream != stream:
		_music.stream = stream
		_music.play()

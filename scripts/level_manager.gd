extends Node2D
class_name LevelManager

@onready var holder_current : Node = $CurrentLevel

var _loaded_level : Node = null

func load_first_level( level_path: String ) -> void:
	_free_children( holder_current )
	var ps : PackedScene = load( level_path )
	_loaded_level = ps.instantiate()
	holder_current.add_child( _loaded_level )

	# Optionally: position camera center if needed (single screen → no follow).

func _free_children( node: Node ) -> void:
	for c in node.get_children():
		c.queue_free()

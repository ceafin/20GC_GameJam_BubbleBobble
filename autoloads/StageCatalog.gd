extends Node

var stages : Array[String] = []

# Do the thing when ready
func _ready() -> void:
	scan()

# Scan the provided directory for where game stages should
# be and round up all their paths in neat Array[String].
func scan( dir_path: String = "res://stages" ) -> void:
	
	# Clean it out first
	stages.clear()
	
	# Set where we're goig
	var dir : DirAccess = DirAccess.open( dir_path )
	
	# Pitch a tantrum
	if dir == null:
		push_error( "StageCatalog: cannot open %s" % dir_path )
		return
	
	# Build the array of paths
	for file in dir.get_files():
		if file.ends_with( ".tscn" ) and not file.ends_with( ".tscn.remap" ):
			stages.append( "%s/%s" % [ dir_path, file ] )
	
	# Alpha sort the strings
	stages.sort()
	

# Return how many stages we have
func count() -> int:
	return stages.size()

# Retrieve path for provided stage/level number
func path_at( index: int ) -> String:
	if ( index >= 0 ) and ( index < stages.size() ):
		return stages[ index ]
	else:
		return ""
	
# Retrieve path for the next level
func next_index( index: int ) -> int:
	if stages.is_empty():
		return -1
	
	return ( index + 1 ) % stages.size()

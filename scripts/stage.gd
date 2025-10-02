extends Node2D
class_name Stage

@onready var monsters : Node2D = $Monsters

func _ready() -> void:
	# Connect to monster death/capture signals
	for monster in monsters.get_children():
		if monster is BaseMonster:
			monster.tree_exited.connect(_on_monster_removed)

func _on_monster_removed() -> void:
	# Check if all monsters are gone
	await get_tree().process_frame # Wait one frame for queue_free to process
	
	var remaining_monsters : int = 0
	for child in monsters.get_children():
		if child is BaseMonster and not child.is_queued_for_deletion():
			remaining_monsters += 1
	
	if remaining_monsters == 0:
		GSB.stage_complete.emit()

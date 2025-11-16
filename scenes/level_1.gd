extends Node2D


func _on_player_killed() -> void:
	$Player.position = $CheckpointManager.last_location 
	$Player.get_node("Health").health = 1

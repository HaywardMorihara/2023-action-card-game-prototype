extends Node2D


func _ready():
	respawn_all()	


func respawn_all():
	for spawn_point in get_tree().get_nodes_in_group("DrawSpawnPoints"):
		var draw_pickup = spawn_point.spawn()
		if draw_pickup:
			add_child(draw_pickup)


func _on_healing_station_healing_station_entered_by_player():
	respawn_all()

extends StaticBody2D

signal healing_station_entered_by_player

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		healing_station_entered_by_player.emit()

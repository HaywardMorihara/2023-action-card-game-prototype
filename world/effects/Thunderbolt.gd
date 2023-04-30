extends Node2D

signal thunderbolt_strike_finished()

func _on_animated_sprite_2d_animation_finished():
	for body_in_blast_radius in $Area2D.get_overlapping_bodies():
		if body_in_blast_radius.is_in_group("Enemies"):
			body_in_blast_radius.queue_destroy()
	thunderbolt_strike_finished.emit()
	queue_free()

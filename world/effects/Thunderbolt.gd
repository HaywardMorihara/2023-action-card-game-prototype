extends Node2D

signal thunderbolt_strike_finished()

func _on_animated_sprite_2d_animation_finished():
	for body_in_blast_radius in $Area2D.get_overlapping_bodies():
		if body_in_blast_radius.is_in_group("Enemies"):
			body_in_blast_radius.queue_destroy()
	thunderbolt_strike_finished.emit()
	$DelayQueueFreeTimer.start()
	visible = false


func _on_thunder_sfx_delay_timer_timeout():
	$ThunderSFX.play()
	# TODO Tweak, didn't look right, maybe blobs will take care of this
#	get_tree().paused = true
#	$HitFrameTimer.start()

func _on_delay_queue_free_timer_timeout():
	queue_free()


func _on_first_bolt_interruption_timer_timeout():
	pass


func _on_first_bolt_delay_timer_timeout():
	$FastThunderSFX.play()

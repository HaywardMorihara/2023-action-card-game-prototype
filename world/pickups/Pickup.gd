class_name Pickup extends Area2D

signal pickup_has_been_picked_up

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.pickup(self)
		pickup_has_been_picked_up.emit()
		queue_free()

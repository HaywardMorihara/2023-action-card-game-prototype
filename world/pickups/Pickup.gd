class_name Pickup extends Area2D


func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.pickup(self)
		queue_free()

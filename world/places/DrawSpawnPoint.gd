extends Node2D

var draw_pickup_scene = preload("res://world/pickups/DrawPickup.tscn")

var has_been_picked_up := true

func spawn() -> Node2D:
	if not has_been_picked_up:
		return null
	var pickup = draw_pickup_scene.instantiate()
	pickup.global_position = global_position
	pickup.pickup_has_been_picked_up.connect(_on_pickup_has_been_picked_up)
	has_been_picked_up = false
	return pickup
	

func _on_pickup_has_been_picked_up():
	has_been_picked_up = true

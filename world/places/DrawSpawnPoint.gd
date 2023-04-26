extends Node2D

var draw_pickup_scene = preload("res://world/pickups/DrawPickup.tscn")


func spawn() -> Node2D:
	var pickup = draw_pickup_scene.instantiate()
	pickup.global_position = global_position
	return pickup

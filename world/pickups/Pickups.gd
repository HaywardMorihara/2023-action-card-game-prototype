extends Node2D


var d = preload("res://world/pickups/DrawPickup.tscn")

func _ready():
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		enemy.blob_drop.connect(_on_Enemy_drop)
		

func _on_Enemy_drop(pickup):
	add_child(pickup)

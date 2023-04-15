extends Node2D

# TODO This should really be on the "Enemies" node?
# And this should really be called "EnemiesManager" or something?

func _ready():
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		enemy.blob_drop.connect(_on_Enemy_drop)
		

func _on_Enemy_drop(pickup):
	add_child(pickup)

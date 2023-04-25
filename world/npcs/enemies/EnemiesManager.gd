extends Node2D

signal enemy_destroyed
# TODO This should really be on the "Enemies" node?
# And this should really be called "EnemiesManager" or something?

func _ready():
	for enemy in get_tree().get_nodes_in_group("Enemies"):
		enemy.blob_drop.connect(_on_Enemy_drop)
		enemy.blob_destroyed.connect(_on_Enemy_destoryed)
		

func _on_Enemy_drop(pickup):
	# TODO This should become a child of Pickups, not Enemies
	add_child(pickup)
	

func _on_Enemy_destoryed():
	enemy_destroyed.emit()
	if get_tree().get_nodes_in_group("Enemies").size() == 0:
		get_tree().change_scene_to_file("res://menus/WinMenu.tscn")

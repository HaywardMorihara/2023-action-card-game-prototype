extends Node2D

signal enemy_destroyed

var current_enemy_count : int
var expected_enemy_count : int

func _ready():
	var all_enemies := get_tree().get_nodes_in_group("Enemies") 
	for enemy in all_enemies:
		enemy.blob_drop.connect(_on_Enemy_drop)
		enemy.blob_queued_destroy.connect(_on_Enemy_destroyed)
	current_enemy_count = all_enemies.size()
	expected_enemy_count = all_enemies.size()

func _process(delta : float):
	# Have to do this because the point where the enemy is destory, they're actually only "queued" to be destroyed
	if current_enemy_count != expected_enemy_count:
		var actual_enemy_group_count := get_tree().get_nodes_in_group("Enemies").size() 
		if actual_enemy_group_count == expected_enemy_count:
			enemy_destroyed.emit()
			current_enemy_count = actual_enemy_group_count
			expected_enemy_count = actual_enemy_group_count
		
func _on_Enemy_drop(pickup):
	# TODO This should become a child of Pickups, not Enemies
	add_child(pickup)
	

func _on_Enemy_destroyed():
	expected_enemy_count -= 1

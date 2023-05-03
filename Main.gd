extends Node2D

func _ready():
	$Tutorial.visible = true
	get_tree().paused = true

func _on_card_ui_deck_is_empty():
	get_tree().change_scene_to_file("res://menus/LoseMenu.tscn")

func _on_enemies_enemy_destroyed():
	$CardEffectHandler/CardUI/EnemyCountLabel.update()
	var all_enemies = get_tree().get_nodes_in_group("Enemies") 
	if all_enemies.size() == 0:
		get_tree().change_scene_to_file("res://menus/WinMenu.tscn")

func _on_play_button_pressed():
	get_tree().paused = false
	$CardEffectHandler/CardUI.visible = true
	$Tutorial.queue_free()
	$CardEffectHandler/CardUI/StartingHandDelayTimer.start()

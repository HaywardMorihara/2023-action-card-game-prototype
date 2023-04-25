extends Node2D


func _on_card_ui_deck_is_empty():
	get_tree().change_scene_to_file("res://menus/LoseMenu.tscn")


func _on_enemies_enemy_destroyed():
	$CardEffectHandler/CardUI/EnemyCountLabel.update()

extends Control


func _on_hero_pressed():
	ActionCardGameGlobal.starting_deck = ActionCardGameGlobal.hero_starting_deck
	get_tree().change_scene_to_file("res://Main.tscn")


func _on_healer_pressed():
	ActionCardGameGlobal.starting_deck = ActionCardGameGlobal.healer_starting_deck
	get_tree().change_scene_to_file("res://Main.tscn")


func _on_hustler_pressed():
	ActionCardGameGlobal.starting_deck = ActionCardGameGlobal.hustler_starting_deck
	get_tree().change_scene_to_file("res://Main.tscn")

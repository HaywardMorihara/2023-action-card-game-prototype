extends Button

func _ready():
	get_tree().paused = false

func _on_pressed():
	get_tree().change_scene_to_file("res://menus/MainMenu.tscn")

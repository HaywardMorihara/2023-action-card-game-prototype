extends Label

func _ready():
	update()

func update():
	var enemies_left := get_tree().get_nodes_in_group("Enemies").size()
	text = "Enemies Left: %s" % str(enemies_left)

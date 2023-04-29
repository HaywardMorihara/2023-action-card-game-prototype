extends Node2D

@onready var top_card : Sprite2D = get_node("TopCard")
@onready var middle_card : Sprite2D = get_node("MiddleCard")
@onready var bottom_card : Sprite2D = get_node("BottomCard")

var contents : Array[ActionCardGameGlobal.CardId]


func _ready():
	update_visibility()

func add(cardId : ActionCardGameGlobal.CardId):
	contents.push_front(cardId)
	update_visibility()


func remove_all() -> Array[ActionCardGameGlobal.CardId]:
	var to_be_returned = contents
	contents = []
	update_visibility()
	return to_be_returned


func update_visibility():
	
	
	match contents.size():
		2:
			var bottom_card_scene = ActionCardGameGlobal.card_id_to_card_scene[contents[1]].instantiate()
			bottom_card.texture = bottom_card_scene.get_node("Sprite2D").texture
			bottom_card_scene.queue_free()
			bottom_card.visible = true	
			var middle_card_scene = ActionCardGameGlobal.card_id_to_card_scene[contents[0]].instantiate()
			middle_card.texture = middle_card_scene.get_node("Sprite2D").texture
			middle_card_scene.queue_free()
			middle_card.visible = true	
			top_card.visible = false
		1:
			var bottom_card_scene = ActionCardGameGlobal.card_id_to_card_scene[contents[0]].instantiate()
			bottom_card.texture = bottom_card_scene.get_node("Sprite2D").texture
			bottom_card_scene.queue_free()
			bottom_card.visible = true	
			middle_card.visible = false	
			top_card.visible = false
		0:
			bottom_card.visible = false	
			middle_card.visible = false	
			top_card.visible = false
		_:
			var bottom_card_scene = ActionCardGameGlobal.card_id_to_card_scene[contents[2]].instantiate()
			bottom_card.texture = bottom_card_scene.get_node("Sprite2D").texture
			bottom_card_scene.queue_free()
			bottom_card.visible = true	
			var middle_card_scene = ActionCardGameGlobal.card_id_to_card_scene[contents[1]].instantiate()
			middle_card.texture = middle_card_scene.get_node("Sprite2D").texture
			middle_card_scene.queue_free()
			middle_card.visible = true	
			var top_card_scene = ActionCardGameGlobal.card_id_to_card_scene[contents[0]].instantiate()
			top_card.texture = top_card_scene.get_node("Sprite2D").texture
			top_card_scene.queue_free()
			top_card.visible = true	

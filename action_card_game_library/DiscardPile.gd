extends Node2D

var contents : Array[ActionCardGameGlobal.CardId]

func _ready():
	visible = false

func add(cardId : ActionCardGameGlobal.CardId):
	visible = true
	contents.push_front(cardId)


func remove_all() -> Array[ActionCardGameGlobal.CardId]:
	var to_be_returned = contents
	contents = []
	visible = false
	return to_be_returned

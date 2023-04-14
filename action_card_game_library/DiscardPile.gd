extends Node2D

var contents : Array[ActionCardGameGlobal.CardId]

func _ready():
	visible = false

func add(cardId : ActionCardGameGlobal.CardId):
	visible = true
	contents.push_front(cardId)

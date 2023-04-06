extends Area2D

signal card_drawn(card_id : ActionCardGameGlobal.CardId)

var deck_contents : Array[ActionCardGameGlobal.CardId]


func _ready():
	# TODO Replace
	deck_contents = [
		ActionCardGameGlobal.CardId.ONE, 
		ActionCardGameGlobal.CardId.TWO, 
		ActionCardGameGlobal.CardId.THREE,
	]
	##
	shuffle()


func shuffle():
	randomize()
	deck_contents.shuffle()
	

func add_card_to_bottom_of_deck(card_id : ActionCardGameGlobal.CardId):
	if deck_contents.size() == 0:
		visible = true
	deck_contents.push_back(card_id)


func add_card_to_front_of_deck(card_id : ActionCardGameGlobal.CardId):
	if deck_contents.size() == 0:
		visible = true
	deck_contents.push_front(card_id)


func draw_next_card():
	var next_card_id = deck_contents.pop_front()
	card_drawn.emit(next_card_id)
	if deck_contents.size() == 0:
		visible = false
	

func _on_input_event(viewport, event, shape_idx):
	if deck_contents.size() > 0 && event.is_action_pressed("deck_draw"):
		draw_next_card()

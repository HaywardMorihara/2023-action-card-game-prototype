extends Area2D

signal card_drawn(card_id : ActionCardGameGlobal.CARD_TYPES)

var deck_contents : Array[ActionCardGameGlobal.CARD_TYPES]


func _ready():
	# TODO Remove
	deck_contents = [
		ActionCardGameGlobal.CARD_TYPES.ONE, 
		ActionCardGameGlobal.CARD_TYPES.TWO, 
		ActionCardGameGlobal.CARD_TYPES.THREE,
	]
	##
	shuffle()


func shuffle():
	randomize()
	deck_contents.shuffle()
	

func add_card_to_bottom_of_deck(card_id : ActionCardGameGlobal.CARD_TYPES):
	deck_contents.push_back(card_id)


func add_card_to_front_of_deck(card_id : ActionCardGameGlobal.CARD_TYPES):
	deck_contents.push_front(card_id)


func draw_next_card():
	var next_card_id = deck_contents.pop_front()
	card_drawn.emit(next_card_id)
	

func _on_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("deck_draw"):
		draw_next_card()

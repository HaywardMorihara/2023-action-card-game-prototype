extends Area2D

signal card_drawn(card_id : ActionCardGameGlobal.CardId)
signal deck_discard(card_id : ActionCardGameGlobal.CardId)

var current_contents : Array[ActionCardGameGlobal.CardId]
var total_cards : int

@export var is_click_to_draw : bool = false

func _ready():
	# TODO Replace
	current_contents = [
		ActionCardGameGlobal.CardId.ONE, 
		ActionCardGameGlobal.CardId.TWO, 
		ActionCardGameGlobal.CardId.THREE,
		ActionCardGameGlobal.CardId.THREE,
	]
	##
	shuffle()
	total_cards = current_contents.size()

func shuffle():
	randomize()
	current_contents.shuffle()
	

func add_card_to_bottom_of_deck(card_id : ActionCardGameGlobal.CardId):
	if current_contents.size() == 0:
		visible = true
	current_contents.push_back(card_id)


func add_card_to_front_of_deck(card_id : ActionCardGameGlobal.CardId):
	if current_contents.size() == 0:
		visible = true
	current_contents.push_front(card_id)


func draw_next_card():
	var next_card_id = current_contents.pop_front()
	card_drawn.emit(next_card_id)
	if current_contents.size() == 0:
		visible = false
	
	
func discard_from_top(num_of_cards : int):
	var next_card_id = current_contents.pop_front()
	deck_discard.emit(next_card_id)
	if current_contents.size() == 0:
		visible = false


func _on_input_event(viewport, event, shape_idx):
	if is_click_to_draw:
		if current_contents.size() > 0 && event.is_action_pressed("deck_draw"):
			draw_next_card()

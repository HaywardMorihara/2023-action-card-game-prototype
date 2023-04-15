extends CanvasLayer

@onready var Deck := get_node("Deck")
@onready var Hand := get_node("Hand")
@onready var DiscardPile := get_node("DiscardPile")
@onready var HealthUI := get_node("HealthUI")

func _ready():
	HealthUI.update_max(Deck.total_cards)
	HealthUI.update_current(Deck.current_contents.size(), DiscardPile.contents.size())


func draw_next_card():
	Deck.draw_next_card()
	HealthUI.update_current(Deck.current_contents.size(), DiscardPile.contents.size())
	
	
func discard_from_deck(num_of_cards : int):
	Deck.discard_from_top(num_of_cards)
	HealthUI.update_current(Deck.current_contents.size(), DiscardPile.contents.size())


func _on_deck_deck_discard(card_id):
	DiscardPile.add(card_id)
	HealthUI.update_current(Deck.current_contents.size(), DiscardPile.contents.size())


func _on_hand_card_played(card, position):
	DiscardPile.add(card.id)
	HealthUI.update_current(Deck.current_contents.size(), DiscardPile.contents.size())


func _on_healing_station_healing_station_entered_by_player():
	$Popup.show()
	get_tree().paused = true


func _on_yes_heal_button_pressed():
	var cards_from_discard_pile = DiscardPile.remove_all()
	for cardId in cards_from_discard_pile:
		Deck.add_card_to_front_of_deck(cardId)
	Deck.shuffle()
	var cards_from_hand = Hand.remove_all()
	for cardId in cards_from_hand:
		Deck.add_card_to_front_of_deck(cardId)
	for n in 5:
		if Deck.current_contents.size() <= 1:
			break
		Deck.draw_next_card()
	HealthUI.update_current(Deck.current_contents.size(), DiscardPile.contents.size())
	$Popup.hide()
	get_tree().paused = false


func _on_no_heal_button_pressed():
	$Popup.hide()
	get_tree().paused = false


func _on_player_player_new_card(cardId):
	Deck.total_cards += 1
	Deck.add_card_to_bottom_of_deck(cardId)
	HealthUI.update_max(Deck.total_cards)
	HealthUI.update_current(Deck.current_contents.size(), DiscardPile.contents.size())

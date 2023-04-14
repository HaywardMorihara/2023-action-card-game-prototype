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

extends CanvasLayer

signal deck_is_empty

@export var card_tween_duration : float = 0.1

@onready var Deck := get_node("Deck")
@onready var Hand := get_node("Hand")
@onready var DiscardPile := get_node("DiscardPile")
@onready var HealthUI := get_node("HealthUI")
@onready var HealTimer := get_node("HealTimer")

func _ready():
	HealthUI.update_max(Deck.total_cards)
	HealthUI.update_current(Deck.current_contents.size(), DiscardPile.contents.size())

func draw_next_card():
	Deck.draw_next_card(Hand.global_position)
	HealthUI.update_current(Deck.current_contents.size(), DiscardPile.contents.size())
	
func discard_from_deck(num_of_cards : int):
	Deck.discard_from_top(num_of_cards, DiscardPile.global_position)
	if Deck.current_contents.size() == 0:
		deck_is_empty.emit()
	HealthUI.update_current(Deck.current_contents.size(), DiscardPile.contents.size())

func _on_deck_deck_discard(card_id):
	DiscardPile.add(card_id)
	HealthUI.update_current(Deck.current_contents.size(), DiscardPile.contents.size())

func _on_hand_card_played(card, position):
	DiscardPile.add(card.id)
	HealthUI.update_current(Deck.current_contents.size(), DiscardPile.contents.size())
	_card_movement_animation(card.id, position, DiscardPile.global_position)

func _on_healing_station_healing_station_entered_by_player():
	$Popup.show()
	get_tree().paused = true

func _on_yes_heal_button_pressed():
	$Popup.hide()
	HealTimer.start()

func _on_no_heal_button_pressed():
	$Popup.hide()
	get_tree().paused = false

func _on_player_player_new_card(cardId : ActionCardGameGlobal.CardId):
	Deck.total_cards += 1
	Deck.add_card_to_bottom_of_deck(cardId)
	HealthUI.update_max(Deck.total_cards)
	HealthUI.update_current(Deck.current_contents.size(), DiscardPile.contents.size())
	_card_movement_animation(cardId, $Center.position, Deck.global_position)

func _on_starting_hand_delay_timer_timeout():
	if ActionCardGameGlobal.starting_hand_count:
		var num_cards_in_hand := get_tree().get_nodes_in_group("cards_in_hand").size()
		if num_cards_in_hand < ActionCardGameGlobal.starting_hand_count:
			draw_next_card()
			$StartingHandDelayTimer.start()
			
func _card_movement_animation(card_id : ActionCardGameGlobal.CardId, from_global_pos : Vector2, to_global_pos : Vector2):
	var card_for_animation = ActionCardGameGlobal.card_id_to_card_scene[card_id].instantiate()
	card_for_animation.position = from_global_pos
	add_child(card_for_animation)
	card_for_animation.move_to(to_global_pos, card_tween_duration, true)

func _on_heal_timer_timeout():
	var next_discard_card_id = DiscardPile.pop_front()
	if next_discard_card_id:
		_card_movement_animation(next_discard_card_id, DiscardPile.global_position, Deck.global_position)
		Deck.add_card_to_front_of_deck(next_discard_card_id)
		HealthUI.update_current(Deck.current_contents.size(), DiscardPile.contents.size())
		HealTimer.start()
		return
	
	var next_card_in_hand = get_tree().get_first_node_in_group("cards_in_hand")
	if next_card_in_hand:
		_card_movement_animation(next_card_in_hand.id, Hand.global_position, Deck.global_position)
		next_card_in_hand.remove_from_group("cards_in_hand")
		next_card_in_hand.queue_free()
		Deck.add_card_to_front_of_deck(next_card_in_hand.id)
		HealthUI.update_current(Deck.current_contents.size(), DiscardPile.contents.size())
		HealTimer.start()
		return

	Deck.shuffle()
	$StartingHandDelayTimer.start()
	get_tree().paused = false


func _on_player_player_heal(amount):
	var next_discard_card_id = DiscardPile.pop_front()
	if next_discard_card_id:
		_card_movement_animation(next_discard_card_id, DiscardPile.global_position, Deck.global_position)
		Deck.add_card_to_front_of_deck(next_discard_card_id)
		HealthUI.update_current(Deck.current_contents.size(), DiscardPile.contents.size())

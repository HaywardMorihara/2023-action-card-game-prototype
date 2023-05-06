class_name CardUI extends CanvasLayer

signal deck_is_empty
signal card_ui_current_animation_finished

@export var card_tween_duration : float = 0.25

@onready var Deck := get_node("Deck")
@onready var Hand := get_node("Hand")
@onready var DiscardPile := get_node("DiscardPile")
@onready var HealthUI := get_node("HealthUI")
@onready var HealTimer := get_node("HealTimer")

enum CurrentAnimation {
	NONE,
	REGROUP,
	DISCARD_HAND,
	ADDING_NEW_CARDS_TO_DECK,
	DRAWING_CARDS,
	HEALING,
}
var current_animation : CurrentAnimation = CurrentAnimation.NONE
var new_cards_to_be_added_to_deck : Array[ActionCardGameGlobal.CardId] = []
var num_cards_to_draw := 0
var num_cards_to_heal := 0

func _ready():
	HealthUI.update_max(Deck.total_cards)
	HealthUI.update_current(Deck.current_contents.size(), DiscardPile.contents.size())

func _process(delta):
	if Deck.current_contents.size() == 0:
		deck_is_empty.emit()

func draw_next_card():
	if Deck.current_contents.size() > 1:
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

func add_new_card_to_deck(cardId : ActionCardGameGlobal.CardId):
	Deck.total_cards += 1
	Deck.add_card_to_bottom_of_deck(cardId)
	HealthUI.update_max(Deck.total_cards)
	HealthUI.update_current(Deck.current_contents.size(), DiscardPile.contents.size())
	_card_movement_animation(cardId, $Center.position, Deck.global_position)

func add_new_card_to_hand(cardId : ActionCardGameGlobal.CardId):
	Deck.total_cards += 1
	Hand.add_card(cardId)
	HealthUI.update_max(Deck.total_cards)
	HealthUI.update_current(Deck.current_contents.size(), DiscardPile.contents.size())
	_card_movement_animation(cardId, $Center.position, Hand.global_position)

func _on_player_player_new_card(cardId : ActionCardGameGlobal.CardId):
	add_new_card_to_hand(cardId)

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
	var next_discard_card_id = DiscardPile.pop_back()
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

func shuffle_hand_into_deck_and_draw_starting_hand():
	current_animation = CurrentAnimation.REGROUP
	$AnimationDelayTimer.start()

func discard_your_hand():
	current_animation = CurrentAnimation.DISCARD_HAND
	$AnimationDelayTimer.start()

func add_new_cards_to_deck(cardIds : Array[ActionCardGameGlobal.CardId]):
	new_cards_to_be_added_to_deck = cardIds
	current_animation = CurrentAnimation.ADDING_NEW_CARDS_TO_DECK
	$AnimationDelayTimer.start()

func draw_cards(num : int):
	num_cards_to_draw = num
	current_animation = CurrentAnimation.DRAWING_CARDS
	$AnimationDelayTimer.start()

func heal(num : int):
	num_cards_to_heal = min(num, DiscardPile.contents.size())
	current_animation = CurrentAnimation.HEALING
	$AnimationDelayTimer.start()
	$Deck/HealParticles.emitting = true

func heal_from_bottom_of_deck(amount : int):
	for i in amount:
		var next_discard_card_id = DiscardPile.pop_back()
		if next_discard_card_id != null:
			_card_movement_animation(next_discard_card_id, DiscardPile.global_position, Deck.global_position)
			Deck.add_card_to_front_of_deck(next_discard_card_id)
			Deck.shuffle()
			HealthUI.update_current(Deck.current_contents.size(), DiscardPile.contents.size())
	$Deck/HealParticles.emitting = true

func _on_player_player_heal(amount):
	heal_from_bottom_of_deck(amount)

func _on_animation_delay_timer_timeout():
	match current_animation:
		CurrentAnimation.REGROUP:
			var next_card_in_hand = get_tree().get_first_node_in_group("cards_in_hand")
			if next_card_in_hand:
				_card_movement_animation(next_card_in_hand.id, Hand.global_position, Deck.global_position)
				next_card_in_hand.remove_from_group("cards_in_hand")
				next_card_in_hand.queue_free()
				Deck.add_card_to_front_of_deck(next_card_in_hand.id)
				
				$AnimationDelayTimer.start()
				return
			Deck.shuffle()
			$StartingHandDelayTimer.start()
			current_animation = CurrentAnimation.NONE
		CurrentAnimation.DISCARD_HAND:
			var next_card_in_hand = get_tree().get_first_node_in_group("cards_in_hand")
			if next_card_in_hand:
				DiscardPile.add(next_card_in_hand.id)
				_card_movement_animation(next_card_in_hand.id, Hand.global_position, DiscardPile.global_position)
				next_card_in_hand.remove_from_group("cards_in_hand")
				next_card_in_hand.queue_free()
				HealthUI.update_current(Deck.current_contents.size(), DiscardPile.contents.size())
				$AnimationDelayTimer.start()
				return
			current_animation = CurrentAnimation.NONE
		CurrentAnimation.ADDING_NEW_CARDS_TO_DECK:
			var next_card_to_add_to_deck = new_cards_to_be_added_to_deck.pop_front()
			if next_card_to_add_to_deck != null:
				add_new_card_to_deck(next_card_to_add_to_deck)
				$AnimationDelayTimer.start()
				return
			current_animation = CurrentAnimation.NONE
		CurrentAnimation.DRAWING_CARDS:
			if num_cards_to_draw > 0:
				num_cards_to_draw -= 1
				draw_next_card()
				$AnimationDelayTimer.start()
				return
			current_animation = CurrentAnimation.NONE
		CurrentAnimation.HEALING:
			if num_cards_to_heal > 0:
				num_cards_to_heal -= 1
				var next_discard_card_id = DiscardPile.pop_back()
				if next_discard_card_id != null:
					_card_movement_animation(next_discard_card_id, DiscardPile.global_position, Deck.global_position)
					Deck.add_card_to_front_of_deck(next_discard_card_id)
					Deck.shuffle()
					HealthUI.update_current(Deck.current_contents.size(), DiscardPile.contents.size())
					$AnimationDelayTimer.start()
					return
			current_animation = CurrentAnimation.NONE
	if current_animation == CurrentAnimation.NONE:
		card_ui_current_animation_finished.emit()

func _on_hand_card_in_hand_removed(card):
	Deck.total_cards -= 1
	HealthUI.update_max(Deck.total_cards)

func set_toast(message : String, time_limit = null):
	$Toast.visible = true
	$Toast.text = message
	if time_limit != null:
		$Toast/ToastTimer.start(time_limit)
	
func unset_toast():
	$Toast.visible = false
	$Toast.text = ""
	
func _on_hand_card_preconditions_not_met(card):
	set_toast("Card preconditions not met.", 3.0)

func _on_toast_timer_timeout():
	unset_toast()

extends Area2D

signal card_played(card , position)
signal hand_is_up_toggled(is_hand_up : bool)
signal card_in_hand_is_being_looked_at(is_being_looked_at : bool, card : Card)
signal card_in_hand_is_selected(card : Card)
signal card_in_hand_removed(card)
signal card_preconditions_not_met(card)

@export var hand_up_y := 45
@export var hand_up_background_color := Color(1,1,1,1)

var resting_background_color : Color
var at_rest_y : float
var is_hand_up : bool = false
var is_card_being_held : bool = false
var is_mouse_hovering_over_hand := false

func _ready():
	resting_background_color = $ColorRect.color
	at_rest_y = position.y
	for card in get_tree().get_nodes_in_group("cards"):
		card.card_placed.connect(_on_card_card_placed)
		card.card_being_held.connect(_on_card_card_being_held)

func add_card(card_id : ActionCardGameGlobal.CardId):
	var new_card_scene = ActionCardGameGlobal.card_id_to_card_scene[card_id]
	var new_card = new_card_scene.instantiate()
	new_card.card_placed.connect(_on_card_card_placed)
	new_card.card_being_held.connect(_on_card_card_being_held)
	new_card.card_being_looked_at.connect(_on_card_card_being_looked_at)
	new_card.card_selected.connect(_on_card_is_selected)
	new_card.card_removed.connect(_on_card_removed)
	new_card.add_to_group("cards_in_hand")
	new_card.id = card_id
	add_child(new_card)
	reset_card_positions()

func reset_card_positions():
	var hand_width = $CollisionShape2D.shape.get_size().x	
	var cards_in_hand = get_tree().get_nodes_in_group("cards_in_hand")
	var num_cards_in_hand = cards_in_hand.size()
	for i in range(num_cards_in_hand):
		var new_pos = cards_in_hand[i].position
		new_pos.x = - (hand_width / 2) + (hand_width / (num_cards_in_hand + 1)) * (i + 1)
		cards_in_hand[i].set_initial_position(new_pos)

func remove_all() -> Array[ActionCardGameGlobal.CardId]:
	var cards_from_hand : Array[ActionCardGameGlobal.CardId] = []
	for card in get_tree().get_nodes_in_group("cards_in_hand"):
		cards_from_hand.push_front(card.id)
		card.remove_from_group("cards_in_hand")
		card.queue_free()
	return cards_from_hand

func _move_hand_up(up := true):
	is_hand_up = up
	if is_hand_up:
		position.y = at_rest_y - hand_up_y
	else:
		position.y = at_rest_y
	hand_is_up_toggled.emit(is_hand_up)

func _on_mouse_entered():
	is_mouse_hovering_over_hand = true
	$ColorRect.color = hand_up_background_color
	var cards_in_hand = get_tree().get_nodes_in_group("cards_in_hand")
	var num_cards_in_hand = cards_in_hand.size()
	if num_cards_in_hand == 0:
		return
	_move_hand_up(true)

func _on_mouse_exited():
	is_mouse_hovering_over_hand = false
	$ColorRect.color = resting_background_color
	if is_card_being_held:
		return
	_move_hand_up(false)

func _on_card_card_placed(card, position):
	if is_mouse_hovering_over_hand:
		card.return_to_initial_position()
	else:
		if not card.check_preconditions():
			card.return_to_initial_position()
			card_preconditions_not_met.emit(self)
		else:
			card.remove_from_group("cards_in_hand")
			card.play()
			reset_card_positions()
			card_played.emit(card, position)
	_move_hand_up(false)

func _on_card_card_being_held(is_card_held):
	is_card_being_held = is_card_held


func _on_card_card_being_looked_at(is_being_looked_at : bool, card : Card):
	card_in_hand_is_being_looked_at.emit(is_being_looked_at, card)


func _on_deck_card_drawn(card_id):
	add_card(card_id)

func _on_card_is_selected(card):
	card_in_hand_is_selected.emit(card)
	
func _on_card_removed(card):
	card_in_hand_removed.emit(card)
	card.remove_from_group("cards_in_hand")
	reset_card_positions()

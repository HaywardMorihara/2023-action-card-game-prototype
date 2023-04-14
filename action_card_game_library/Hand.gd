extends Area2D

signal card_played(card , position)
signal hand_is_up_toggled(is_hand_up : bool)

var is_hand_up : bool = false
var is_card_being_held : bool = false


func add_card(card_id : ActionCardGameGlobal.CardId):
	# TODO How to translate this into what card should be instantiated?
	
	var new_card_scene = ActionCardGameGlobal.card_id_to_card_scene[card_id]
	var new_card = new_card_scene.instantiate()
	new_card.card_placed.connect(_on_card_card_placed)
	new_card.card_being_held.connect(_on_card_card_being_held)
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
	

func _ready():
	for card in get_tree().get_nodes_in_group("cards"):
		card.card_placed.connect(_on_card_card_placed)
		card.card_being_held.connect(_on_card_card_being_held)


func _on_mouse_entered():
	var cards_in_hand = get_tree().get_nodes_in_group("cards_in_hand")
	var num_cards_in_hand = cards_in_hand.size()
	if num_cards_in_hand > 0:
		is_hand_up = true
		position.y = 720 - 135
		hand_is_up_toggled.emit(is_hand_up)


func _on_mouse_exited():
	if not is_card_being_held:
		is_hand_up = false
		position.y = 720
		hand_is_up_toggled.emit(is_hand_up)


func _on_card_card_placed(card, position):
	if position.y > self.position.y:
		card.return_to_initial_position()
	else:
		card.remove_from_group("cards_in_hand")
		card.play()
		reset_card_positions()
		card_played.emit(card, position)
	
	is_hand_up = false
	position.y = 720
	hand_is_up_toggled.emit(is_hand_up)


func _on_card_card_being_held(is_card_held):
	is_card_being_held = is_card_held


func _on_deck_card_drawn(card_id):
	add_card(card_id)

extends Area2D

var is_hand_up : bool = false

var card_scene = preload("res://card.tscn")
var Card = preload("res://Card.gd")


func add_card():
	var new_card = card_scene.instantiate()
	new_card.card_placed.connect(_on_card_card_placed)
	new_card.add_to_group("cards_in_hand")
	add_child(new_card)
	reset_card_positions()

func reset_card_positions():
	var hand_width = $CollisionShape2D.shape.get_size().x	
	var cards_in_hand = get_tree().get_nodes_in_group("cards_in_hand")
	var num_cards_in_hand = cards_in_hand.size()
	for i in range(num_cards_in_hand):
		cards_in_hand[i].position.x = - (hand_width / 2) + (hand_width / (num_cards_in_hand + 1)) * (i + 1)


func _ready():
	for card in get_tree().get_nodes_in_group("cards"):
		card.card_placed.connect(_on_card_card_placed)


func _process(delta):
	if is_hand_up:
		position.y = 720 - 135
	else:
		position.y = 720


func _on_mouse_entered():
	is_hand_up = true


func _on_mouse_exited():
	is_hand_up = false


func _on_card_card_placed(card, position):
	if is_hand_up:
		card.return_to_initial_position()
	else:
		card.remove_from_group("cards_in_hand")
		card.play()
		reset_card_positions()


func _on_deck_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("deck_draw"):
		add_card()

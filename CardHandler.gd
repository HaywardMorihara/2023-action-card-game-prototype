extends Node2D


func _on_hand_card_played(card, position):
	print("Played %s at %s!" % [card.id, position])

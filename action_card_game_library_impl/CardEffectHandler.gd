extends Node2D


@onready var CardUI = get_node("CardUI")

func _on_hand_card_played(card, position):
	match card.id:
		ActionCardGameGlobal.CardId.ONE:
			print("One!")
		ActionCardGameGlobal.CardId.TWO:
			print("Two!")
		ActionCardGameGlobal.CardId.THREE:
			print("Three!")


func _on_player_player_draw_card():
	CardUI.draw_next_card()


func _on_player_player_damage(amount):
	CardUI.discard_from_deck(amount)

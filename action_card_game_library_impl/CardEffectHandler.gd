extends Node2D


func _on_hand_card_played(card, position):
	match card.id:
		ActionCardGameGlobal.CardId.ONE:
			print("One!")
		ActionCardGameGlobal.CardId.TWO:
			print("Two!")
		ActionCardGameGlobal.CardId.THREE:
			print("Three!")


func _on_player_player_draw_card():
	$CardUI.draw_next_card()

class_name IngredientCard extends Card


func check_preconditions() -> bool:
	var cards_in_hand = get_tree().get_nodes_in_group("cards_in_hand")
	for card in cards_in_hand:
		match id:
			ActionCardGameGlobal.CardId.INGREDIENT_1:
				match card.id:
					ActionCardGameGlobal.CardId.INGREDIENT_2:
						return true
					ActionCardGameGlobal.CardId.INGREDIENT_3:
						# TODO Refactor
						var Deck = get_tree().get_root().get_node("Main").get_node("CardEffectHandler").get_node("CardUI").get_node("Deck")
						if Deck.current_contents.size() <= 5:
							return true
			ActionCardGameGlobal.CardId.INGREDIENT_2:
				match card.id:
					ActionCardGameGlobal.CardId.INGREDIENT_1:
						return true
					ActionCardGameGlobal.CardId.INGREDIENT_3:
						return true
			ActionCardGameGlobal.CardId.INGREDIENT_3:
				match card.id:
					ActionCardGameGlobal.CardId.INGREDIENT_2:
						return true
					ActionCardGameGlobal.CardId.INGREDIENT_1:
						# TODO Refactor
						var Deck = get_tree().get_root().get_node("Main").get_node("CardEffectHandler").get_node("CardUI").get_node("Deck")
						if Deck.current_contents.size() <= 5:
							return true
	return false

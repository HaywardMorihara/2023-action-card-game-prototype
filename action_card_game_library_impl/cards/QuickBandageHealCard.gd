extends Card

func check_preconditions() -> bool:
	# TODO Refactor
	var DiscardPile = get_tree().get_root().get_node("Main").get_node("CardEffectHandler").get_node("CardUI").get_node("DiscardPile")
	return DiscardPile.contents.size() < 11

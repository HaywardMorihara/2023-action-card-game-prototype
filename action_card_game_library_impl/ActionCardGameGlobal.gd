extends Node

# TODO Not sure that I love how the player has to have these exactly...

enum CardId {
	FIREBALL,
	POTION_HEAL,
	INJECTION_DRAW,
	REGROUP_SHUFFLE,
}

var card_id_to_card_scene = {
	CardId.FIREBALL : preload("cards/FireballCard.tscn"),
	CardId.POTION_HEAL : preload("cards/PotionHealCard.tscn"),
	CardId.INJECTION_DRAW : preload("cards/InjectionDrawCard.tscn"),
	CardId.REGROUP_SHUFFLE : preload("cards/RegroupShuffleCard.tscn"),
}

var starting_hand_count = 5

var starting_deck : Array[CardId] = [
	CardId.FIREBALL,
	CardId.FIREBALL,
	CardId.FIREBALL,
	CardId.FIREBALL,
	CardId.FIREBALL,
	CardId.FIREBALL,
	CardId.FIREBALL,
	CardId.FIREBALL,
	CardId.FIREBALL,
	CardId.FIREBALL,
	CardId.REGROUP_SHUFFLE,
	CardId.INJECTION_DRAW,
	CardId.INJECTION_DRAW,
	CardId.POTION_HEAL,
	CardId.POTION_HEAL,
]

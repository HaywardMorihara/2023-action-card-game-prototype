extends Node

# TODO Not sure that I love how the player has to have these exactly...

enum CardId {
	ONE,
	TWO,
	THREE,
	FIREBALL,
}

var card_id_to_card_scene = {
	CardId.ONE : preload("cards/Card1.tscn"),
	CardId.TWO : preload("cards/Card2.tscn"),
	CardId.THREE : preload("cards/Card3.tscn"),
	CardId.FIREBALL : preload("cards/FireballCard.tscn")
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
	CardId.FIREBALL,
	CardId.FIREBALL,
	CardId.FIREBALL,
	CardId.FIREBALL,
	CardId.FIREBALL,
]

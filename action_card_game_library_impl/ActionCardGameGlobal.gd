extends Node

# TODO Not sure that I love how the player has to have these exactly...

enum CardId {
	FIREBALL,
	POTION_HEAL,
	INJECTION_DRAW,
	REGROUP_SHUFFLE,
	BANISH_REMOVAL,
	THUNDERBOLT_ATTACK,
	INGREDIENT_1,
	INGREDIENT_2,
	INGREDIENT_3,
	DARK_HOLE_DESTROY,
	FAST_FEET,
	BERZERKER_DRAW,
	QUICK_BANDAGE_HEAL,
}

var card_id_to_card_scene = {
	CardId.FIREBALL : preload("cards/FireballCard.tscn"),
	CardId.POTION_HEAL : preload("cards/PotionHealCard.tscn"),
	CardId.INJECTION_DRAW : preload("cards/InjectionDrawCard.tscn"),
	CardId.REGROUP_SHUFFLE : preload("cards/RegroupShuffleCard.tscn"),
	CardId.BANISH_REMOVAL : preload("cards/BanishRemovalCard.tscn"),
	CardId.THUNDERBOLT_ATTACK : preload("cards/ThunderboltAttackCard.tscn"), 
	CardId.INGREDIENT_1 : preload("cards/Ingredient1Card.tscn"),
	CardId.INGREDIENT_2 : preload("cards/Ingredient2Card.tscn"),
	CardId.INGREDIENT_3 : preload("cards/Ingredient3Card.tscn"),
	CardId.DARK_HOLE_DESTROY : preload("cards/DarkHoleDestroyCard.tscn"),
	CardId.FAST_FEET : preload("cards/FastFeetCard.tscn"),
	CardId.BERZERKER_DRAW : preload("cards/BerzerkerCard.tscn")
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
	CardId.THUNDERBOLT_ATTACK,
	CardId.REGROUP_SHUFFLE,
	CardId.INJECTION_DRAW,
	CardId.INJECTION_DRAW,
	CardId.POTION_HEAL,
	CardId.POTION_HEAL,
	CardId.BANISH_REMOVAL,
	CardId.DARK_HOLE_DESTROY,
#	CardId.INGREDIENT_1,
#	CardId.INGREDIENT_2,
#	CardId.INGREDIENT_3,
	CardId.FAST_FEET,
	CardId.BERZERKER_DRAW,
	CardId.BERZERKER_DRAW,
	CardId.BERZERKER_DRAW,
	CardId.BERZERKER_DRAW,
	CardId.BERZERKER_DRAW,
	CardId.BERZERKER_DRAW,
	CardId.BERZERKER_DRAW,
	CardId.BERZERKER_DRAW,
	CardId.BERZERKER_DRAW,
	CardId.BERZERKER_DRAW,
]

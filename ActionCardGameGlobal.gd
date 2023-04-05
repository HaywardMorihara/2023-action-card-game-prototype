extends Node


enum CARD_TYPES {
	ONE,
	TWO,
	THREE,
}

var card_type_to_card_scene = {
	CARD_TYPES.ONE : preload("res://cards/Card1.tscn"),
	CARD_TYPES.TWO : preload("res://cards/Card1.tscn"),
	CARD_TYPES.THREE : preload("res://cards/Card1.tscn"),
}

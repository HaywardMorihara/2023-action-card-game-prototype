extends Control

@onready var title : Label = get_node("Title")
@onready var description : Label = get_node("Description")

func _ready():
	visible = false


func set_card(card : Card):
	if card:
		title.text = card.title
		description.text = card.description
	else:
		title.text = ""
		description.text = ""


func _on_hand_card_in_hand_is_being_looked_at(is_being_looked_at : bool, card : Card):
	visible = is_being_looked_at
	set_card(card)

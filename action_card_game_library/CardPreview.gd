extends Control

@onready var image : TextureRect = get_node("Image")
@onready var title : Label = get_node("Title")
@onready var description : Label = get_node("Description")

var current_card_id

func _ready():
	visible = false

func set_card(card : Card):
	if card:
		current_card_id = card.id
		image.texture = card.get_node("Sprite2D").texture
		title.text = card.title
		description.text = card.description
	else:
		current_card_id = null
		image.texture = null
		title.text = ""
		description.text = ""

func _on_hand_card_in_hand_is_being_looked_at(is_being_looked_at : bool, card : Card):
	if is_being_looked_at:
		set_card(card)
		visible = true
	if not is_being_looked_at:
		if current_card_id == card.id:	
			set_card(null)
			visible = false
		else:
			set_card(card)

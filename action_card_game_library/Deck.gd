extends Area2D

signal card_drawn(card_id : ActionCardGameGlobal.CardId)
signal deck_discard(card_id : ActionCardGameGlobal.CardId)

@export var is_click_to_draw : bool = false
@export var draw_tween_duration : float = 0.25

@onready var bottom_card : Sprite2D = get_node("Card1")
@onready var middle_card : Sprite2D = get_node("Card2")
@onready var top_card : Sprite2D = get_node("Card3")

var current_contents : Array[ActionCardGameGlobal.CardId]
var total_cards : int

func _ready():
	if ActionCardGameGlobal.starting_deck:
		current_contents = ActionCardGameGlobal.starting_deck.duplicate()
	shuffle()
	total_cards = current_contents.size()
	update_visibility()

func shuffle():
	$AnimationPlayer.play("shuffle")
	randomize()
	current_contents.shuffle()

func add_card_to_bottom_of_deck(card_id : ActionCardGameGlobal.CardId):
	if current_contents.size() == 0:
		visible = true
	current_contents.push_back(card_id)
	update_visibility()

func add_card_to_front_of_deck(card_id : ActionCardGameGlobal.CardId):
	if current_contents.size() == 0:
		visible = true
	current_contents.push_front(card_id)
	update_visibility()

func draw_next_card(to_position = null):
	if current_contents.size() == 0:
		return
	var next_card_id = current_contents.pop_front()
	card_drawn.emit(next_card_id)
	if current_contents.size() == 0:
		visible = false
	update_visibility()
	if to_position:
		_card_movement_animation(next_card_id, to_position)
	
func discard_from_top(num_of_cards : int, to_position = null):
	if current_contents.size() == 0:
		return
	var next_card_id = current_contents.pop_front()
	deck_discard.emit(next_card_id)
	if current_contents.size() == 0:
		visible = false
	update_visibility()
	if to_position:
		_card_movement_animation(next_card_id, to_position)

func update_visibility():
	match current_contents.size():
		2:
			bottom_card.visible = true	
			middle_card.visible = true	
			top_card.visible = false
		1:
			bottom_card.visible = true	
			middle_card.visible = false	
			top_card.visible = false
		0:
			bottom_card.visible = false	
			middle_card.visible = false	
			top_card.visible = false
		_:
			bottom_card.visible = true	
			middle_card.visible = true	
			top_card.visible = true	
	
func _card_movement_animation(card_id : ActionCardGameGlobal.CardId, to_global_pos : Vector2):
	var card_for_animation = ActionCardGameGlobal.card_id_to_card_scene[card_id].instantiate()
	add_child(card_for_animation)
	card_for_animation.move_to(to_global_pos, draw_tween_duration, true)

func _on_input_event(viewport, event, shape_idx):
	if is_click_to_draw:
		if current_contents.size() > 0 && event.is_action_pressed("deck_draw"):
			draw_next_card()

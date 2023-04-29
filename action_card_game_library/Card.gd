class_name Card extends Area2D

signal card_placed(card, position)
signal card_being_held(is_card_held)
signal card_being_looked_at(is_being_looked_at : bool, card : Card)

@export var title : String
@export var description : String

var id : ActionCardGameGlobal.CardId
var dragging = false
var mouse_over = false
var initial_position : Vector2

func play():
	queue_free()


func set_initial_position(point):
	initial_position = point
	position = point


func return_to_initial_position():
	position = initial_position


func _process(delta):
	if dragging:
		global_position = get_global_mouse_position()


func _input(event):
	if mouse_over:
		var mouse_pos = get_global_mouse_position()
		if event.is_action_pressed("card_select"):
			dragging = true
			card_being_held.emit(dragging)
		elif event.is_action_released("card_select"):
			dragging = false
			card_placed.emit(self, mouse_pos)
			card_being_held.emit(dragging)


func _on_mouse_entered():
	mouse_over = true
	position.y -= 10
	card_being_looked_at.emit(true, self)


func _on_mouse_exited():
	mouse_over = false
	position.y += 10
	card_being_looked_at.emit(false, null)

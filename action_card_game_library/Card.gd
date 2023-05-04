class_name Card extends Area2D

signal card_placed(card, position)
signal card_being_held(is_card_held)
signal card_being_looked_at(is_being_looked_at : bool, card : Card)
signal card_selected(card)
signal card_removed(card)

@export var title : String
@export var description : String

@onready var SFX := get_node("SFX")

var id : ActionCardGameGlobal.CardId
var dragging := false
var mouse_over := false
var is_moving := false
var to_be_destroyed := false
var initial_position : Vector2
var is_in_card_selection_mode := false

func play():
	queue_free()

func set_initial_position(point):
	initial_position = point
	position = point

func return_to_initial_position():
	position = initial_position

func move_to(to_global_pos : Vector2, duration : float, destroy_on_arrival := false):
	is_moving = true
	to_be_destroyed = true
	var tween = create_tween().tween_property(self, "global_position", to_global_pos, duration)
	tween.finished.connect(_on_draw_tween_finished)
	SFX.play()

func check_preconditions() -> bool:
	return true

func _process(delta):
	if dragging:
		global_position = get_global_mouse_position()

func _input(event):
	if mouse_over:
		var mouse_pos = get_global_mouse_position()
		if is_in_card_selection_mode:
			if event.is_action_released("card_select"):
				card_selected.emit(self)
		else:
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
	
func _on_draw_tween_finished():
	is_moving = false
	if to_be_destroyed:
		card_removed.emit(self)
		queue_free()

func remove_from_play():
	is_moving = true
	to_be_destroyed = true
	var tween = create_tween().tween_property(self, "scale", Vector2.ZERO, 0.2)
	tween.finished.connect(_on_draw_tween_finished)

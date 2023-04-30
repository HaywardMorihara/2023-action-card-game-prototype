extends Node2D

@onready var CardUINode : CardUI = get_node("CardUI")
@onready var World = get_node("World")

var fireball_scene = preload("res://world/effects/Fireball.tscn")

var is_in_card_selection_mode := false
var card_selection_mode := CardSelectionMode.NONE
enum CardSelectionMode {
	NONE,
	REMOVE_FROM_PLAY,
}

func _on_hand_card_played(card, position):
	match card.id:
		ActionCardGameGlobal.CardId.FIREBALL:
			var fireball = fireball_scene.instantiate()
			# _Could_ get Player node from Group...
			var player_position = World.get_node("Player").global_position
			var mouse_to_player_pos = get_global_mouse_position() - player_position
			var angle = mouse_to_player_pos.angle()
			fireball.start(player_position, angle)
			World.add_child(fireball)
		ActionCardGameGlobal.CardId.POTION_HEAL:
			CardUINode.heal_from_bottom_of_deck(2)
		ActionCardGameGlobal.CardId.INJECTION_DRAW:
			CardUINode.draw_next_card()
			CardUINode.draw_next_card()
		ActionCardGameGlobal.CardId.REGROUP_SHUFFLE:
			CardUINode.shuffle_hand_into_deck_and_draw_starting_hand()
		ActionCardGameGlobal.CardId.BANISH_REMOVAL:
			card_selection_mode = CardSelectionMode.REMOVE_FROM_PLAY
			enter_card_selection_mode()

func enter_card_selection_mode():
	get_tree().paused = true
	is_in_card_selection_mode = true
	$World/CanvasModulate.color = Color.DIM_GRAY
	for card in get_tree().get_nodes_in_group("cards_in_hand"):
		card.is_in_card_selection_mode = true
	match card_selection_mode:
		CardSelectionMode.REMOVE_FROM_PLAY:
			CardUINode.set_toast("Select a Card to remove from play.")

func exit_card_selection_mode():
	get_tree().paused = false
	is_in_card_selection_mode = false
	$World/CanvasModulate.color = Color.WHITE
	for card in get_tree().get_nodes_in_group("cards_in_hand"):
		card.is_in_card_selection_mode = false
	CardUINode.unset_toast()
	card_selection_mode = CardSelectionMode.NONE

func _on_player_player_draw_card():
	CardUINode.draw_next_card()

func _on_player_player_damage(amount):
	CardUINode.discard_from_deck(amount)

func _on_hand_hand_is_up_toggled(is_hand_up : bool):
	if not is_in_card_selection_mode and PlayerSettings.pause_when_hand_up:
		get_tree().paused = is_hand_up
		if is_hand_up:
			$World/CanvasModulate.color = Color.DIM_GRAY
		else:
			$World/CanvasModulate.color = Color.WHITE

func _on_hand_card_in_hand_is_selected(card):
	match card_selection_mode:
		CardSelectionMode.REMOVE_FROM_PLAY:
			card.remove_from_play()
	exit_card_selection_mode()

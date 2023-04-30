extends Node2D

@onready var CardUI = get_node("CardUI")
@onready var World = get_node("World")

var fireball_scene = preload("res://world/effects/Fireball.tscn")

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
			CardUI.heal_from_bottom_of_deck(2)
		ActionCardGameGlobal.CardId.INJECTION_DRAW:
			CardUI.draw_next_card()
			CardUI.draw_next_card()

func _on_player_player_draw_card():
	CardUI.draw_next_card()

func _on_player_player_damage(amount):
	CardUI.discard_from_deck(amount)

func _on_hand_hand_is_up_toggled(is_hand_up : bool):
	if PlayerSettings.pause_when_hand_up:
		get_tree().paused = is_hand_up
		if is_hand_up:
			$World/CanvasModulate.color = Color.DIM_GRAY
		else:
			$World/CanvasModulate.color = Color.WHITE

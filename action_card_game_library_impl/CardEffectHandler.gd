extends Node2D

@onready var CardUINode : CardUI = get_node("CardUI")
@onready var World := get_node("World")

var fireball_scene = preload("res://world/effects/Fireball.tscn")
var thunderbolt_scene = preload("res://world/effects/Thunderbolt.tscn")
var dark_hole_scene = preload("res://world/effects/DarkHoleDestroy.tscn")

var is_hand_currently_up := false
var is_in_card_selection_mode := false
var is_canvas_changed_for_card_effect := false
var is_low_deck_effect_playing := false
var card_selection_mode := CardSelectionMode.NONE
var card_played_for_selection_mode : ActionCardGameGlobal.CardId
var cards_waiting_for_animation_to_finish : Array[ActionCardGameGlobal.CardId]
enum CardSelectionMode {
	NONE,
	REMOVE_FROM_PLAY,
	INGREDIENT_SELECTION,
}

func _on_hand_card_played(card, position):
	match card.id:
		ActionCardGameGlobal.CardId.FIREBALL:
			var fireball = fireball_scene.instantiate()
			var player_position = World.get_node("Player").global_position
			var mouse_to_player_pos = get_global_mouse_position() - player_position
			var angle = mouse_to_player_pos.angle()
			fireball.start(player_position, angle)
			World.add_child(fireball)
		ActionCardGameGlobal.CardId.POTION_HEAL:
			CardUINode.heal_from_bottom_of_deck(2)
			$HealSFX.play()
		ActionCardGameGlobal.CardId.INJECTION_DRAW:
			CardUINode.draw_next_card()
			CardUINode.draw_next_card()
		ActionCardGameGlobal.CardId.REGROUP_SHUFFLE:
			CardUINode.shuffle_hand_into_deck_and_draw_starting_hand()
		ActionCardGameGlobal.CardId.BANISH_REMOVAL:
			card_selection_mode = CardSelectionMode.REMOVE_FROM_PLAY
			enter_card_selection_mode()
		ActionCardGameGlobal.CardId.THUNDERBOLT_ATTACK:
			CardUINode.discard_from_deck(1)
			is_canvas_changed_for_card_effect = true
			# TODO How do I get this to not effec tthe Thunderbolt??? Then I could make it darker
			var tween = create_tween().tween_property($World/CanvasModulate, "color", Color.DARK_SLATE_BLUE, 1)
			var thunderbolt = thunderbolt_scene.instantiate()
			thunderbolt.global_position = get_global_mouse_position()
			thunderbolt.thunderbolt_strike_finished.connect(_on_thunderbolt_strike_finished)
			$World.add_child(thunderbolt)
		ActionCardGameGlobal.CardId.INGREDIENT_1:
			card_selection_mode = CardSelectionMode.INGREDIENT_SELECTION
			card_played_for_selection_mode = card.id
			enter_card_selection_mode()
		ActionCardGameGlobal.CardId.INGREDIENT_2:
			card_selection_mode = CardSelectionMode.INGREDIENT_SELECTION
			card_played_for_selection_mode = card.id
			enter_card_selection_mode()
		ActionCardGameGlobal.CardId.INGREDIENT_3:
			card_selection_mode = CardSelectionMode.INGREDIENT_SELECTION
			card_played_for_selection_mode = card.id
			enter_card_selection_mode()
		ActionCardGameGlobal.CardId.DARK_HOLE_DESTROY:
			CardUINode.discard_your_hand()
			is_canvas_changed_for_card_effect = true
			var tween = create_tween().tween_property($World/CanvasModulate, "color", Color(0.1,0.1,0.1,0.8), 1)
			var dark_hole = dark_hole_scene.instantiate()
			dark_hole.global_position = get_global_mouse_position()
			dark_hole.dark_hole_finished.connect(_on_dark_hole_finished)
			$World.add_child(dark_hole)
		ActionCardGameGlobal.CardId.FAST_FEET:
			$World/Player.change_speed($World/Player.speed * 0.25, 30)
		ActionCardGameGlobal.CardId.BERZERKER_DRAW:
			CardUINode.discard_your_hand()
			cards_waiting_for_animation_to_finish.push_back(card.id)
		ActionCardGameGlobal.CardId.QUICK_BANDAGE_HEAL:
			CardUINode.heal(10)

func enter_card_selection_mode():
	get_tree().paused = true
	is_in_card_selection_mode = true
	modulate_canvas(Color.DIM_GRAY)
	for card in get_tree().get_nodes_in_group("cards_in_hand"):
		card.is_in_card_selection_mode = true
	match card_selection_mode:
		CardSelectionMode.REMOVE_FROM_PLAY:
			CardUINode.set_toast("Select a Card to remove from play.")
		CardSelectionMode.INGREDIENT_SELECTION:
			CardUINode.set_toast("Select another Ingredient to mix with. Both Cards will be removed from play.")

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
	World.get_node("CanvasModulate").color = Color.RED
	$LowHealthTimer.start(0.1)

func _on_hand_hand_is_up_toggled(is_hand_up : bool):
	is_hand_currently_up = is_hand_up
	if not is_in_card_selection_mode and PlayerSettings.pause_when_hand_up:
		get_tree().paused = is_hand_up
		if is_hand_up:
			modulate_canvas(Color.DIM_GRAY)
		else:
			modulate_canvas(Color.WHITE)

func _process(delta):
	# Note: Having to do this because there's some bug and this seems to be the catch all
	if is_hand_currently_up:
		get_tree().paused = true

func _on_hand_card_in_hand_is_selected(card : Card):
	match card_selection_mode:
		CardSelectionMode.REMOVE_FROM_PLAY:
			card.remove_from_play()
		CardSelectionMode.INGREDIENT_SELECTION:
			match card_played_for_selection_mode:
				ActionCardGameGlobal.CardId.INGREDIENT_1:
					match card.id:
						ActionCardGameGlobal.CardId.INGREDIENT_2:
							ingredients_1_2_effect()
							remove_ingredients_from_play(card)
						ActionCardGameGlobal.CardId.INGREDIENT_3:
							var Deck = CardUINode.get_node("Deck")
							if Deck.current_contents.size() > 5:
								CardUINode.set_toast("%s is not valid - must have <= 5 Cards in your Deck." % card.id, 2.0)
								return
							else:
								ingredients_1_3_effect()
								remove_ingredients_from_play(card)
						_:
							CardUINode.set_toast("%s is not valid." % card.title, 2.0)
				ActionCardGameGlobal.CardId.INGREDIENT_2:
					match card.id:
						ActionCardGameGlobal.CardId.INGREDIENT_1:
							ingredients_1_2_effect()
							remove_ingredients_from_play(card)
						ActionCardGameGlobal.CardId.INGREDIENT_3:
							ingredients_2_3_effect()
							remove_ingredients_from_play(card)
						_:
							CardUINode.set_toast("%s is not valid." % card.title, 2.0)
				ActionCardGameGlobal.CardId.INGREDIENT_3:
					match card.id:
						ActionCardGameGlobal.CardId.INGREDIENT_2:
							ingredients_2_3_effect()
							remove_ingredients_from_play(card)
						ActionCardGameGlobal.CardId.INGREDIENT_1:
							var Deck = CardUINode.get_node("Deck")
							if Deck.current_contents.size() > 5:
								CardUINode.set_toast("%s is not valid - must have <= 5 Cards in your Deck." % card.id, 2.0)
								return
							else:
								ingredients_1_3_effect()
								remove_ingredients_from_play(card)
						_:
							CardUINode.set_toast("%s is not valid." % card.title, 2.0)
	exit_card_selection_mode()

func _on_thunderbolt_strike_finished():
	is_canvas_changed_for_card_effect = false
	var tween = create_tween().tween_property($World/CanvasModulate, "color", Color.WHITE, 1)
	
func _on_dark_hole_finished():
	is_canvas_changed_for_card_effect = false
	var tween = create_tween().tween_property($World/CanvasModulate, "color", Color.WHITE, 1)

func modulate_canvas(color : Color):
	if is_canvas_changed_for_card_effect or is_low_deck_effect_playing:
		return
	$World/CanvasModulate.color = color

func ingredients_1_2_effect():
	$World/Player.default_speed = $World/Player.default_speed * 1.25
	$World/Player.change_speed($World/Player.speed * 0.25)
	
func ingredients_1_3_effect():
	var Deck = CardUINode.get_node("Deck")
	var deck_contents = Deck.current_contents.duplicate()
	CardUINode.add_new_cards_to_deck(deck_contents)
	
func ingredients_2_3_effect():
	CardUINode.add_new_cards_to_deck([ActionCardGameGlobal.CardId.FIREBALL, ActionCardGameGlobal.CardId.FIREBALL, ActionCardGameGlobal.CardId.FIREBALL, ActionCardGameGlobal.CardId.FIREBALL,ActionCardGameGlobal.CardId.FIREBALL])
	
func remove_ingredients_from_play(ingredient_selected_card : Card):
	var DiscardPile = CardUINode.get_node("DiscardPile")
	DiscardPile.contents.erase(card_played_for_selection_mode)
	DiscardPile.update_visibility()
	var health_ui = CardUINode.get_node("HealthUI")
	var max_card_count = health_ui.max_card_count
	var Deck = CardUINode.get_node("Deck")
	Deck.total_cards -= 1
	health_ui.update_max(Deck.total_cards)
	ingredient_selected_card.remove_from_play()

func _on_card_ui_card_ui_current_animation_finished():
	var next_card_id = cards_waiting_for_animation_to_finish.pop_front()
	if next_card_id != null:
		match next_card_id:
			ActionCardGameGlobal.CardId.BERZERKER_DRAW:
				CardUINode.draw_cards(7)

func _on_deck_deck_low(is_low : bool):
	if is_low && not is_low_deck_effect_playing:
		is_low_deck_effect_playing = true
		$LowHealthTimer.start()
		return
	if not is_low && is_low_deck_effect_playing:
		is_low_deck_effect_playing = false
		modulate_canvas(Color.WHITE)
		return

func _on_low_health_timer_timeout():
	if not is_low_deck_effect_playing:
		modulate_canvas(Color.WHITE)
		return
		
	if World.get_node("CanvasModulate").color == Color.RED:
		var tween = create_tween().tween_property($World/CanvasModulate, "color", Color.WHITE, 1)
	if World.get_node("CanvasModulate").color == Color.WHITE or World.get_node("CanvasModulate").color == Color.DIM_GRAY:
		var tween = create_tween().tween_property($World/CanvasModulate, "color", Color.RED, 1)
			
	$LowHealthTimer.start()

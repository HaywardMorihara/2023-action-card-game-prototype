extends CanvasLayer


func _ready():
	$HealthUI.update_max($Deck.total_cards)
	$HealthUI.update_current($Deck.current_contents.size())


func draw_next_card():
	$Deck.draw_next_card()
	$HealthUI.update_current($Deck.current_contents.size())

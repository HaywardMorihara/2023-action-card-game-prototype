extends Control

var current_card_count : int
var current_discard_count : int
var max_card_count : int
var max_bar_width : float

func _ready():
	max_bar_width = $HealthBar.size.x


func update_max(max : int):
	max_card_count = max
	update()


func update_current(current : int, discard_count : int):
	current_card_count = current
	current_discard_count = discard_count
	update()


func update():
	$HealthLabel.text = "Deck (Health): %s / %s" % [str(current_card_count), str(max_card_count)]
	$DiscardLabel.text = "Discard: %s" % str(current_discard_count)
	
	var card_count_percentage = float(current_card_count) / float(max_card_count)
	$HealthBar.size.x = max_bar_width * card_count_percentage
	
	if card_count_percentage >= 0.51:
		$HealthBar.color = Color.GREEN
	if card_count_percentage < 0.51:
		$HealthBar.color = Color.YELLOW
	if card_count_percentage < 0.34:
		$HealthBar.color = Color.RED

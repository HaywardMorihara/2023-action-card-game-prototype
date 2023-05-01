extends CharacterBody2D

signal player_draw_card
signal player_damage(amount : int)
signal player_new_card(cardId : ActionCardGameGlobal.CardId)
signal player_heal(amount : int)

@export var default_speed :float = 100.0

@onready var animation : AnimatedSprite2D = get_node("AnimatedSprite2D")

var speed : float

func _ready():
	speed = default_speed

func pickup(pickup):
	if pickup.is_in_group("DrawPickup"):
		player_draw_card.emit()
	elif pickup.is_in_group("NewCardPickup"):
		player_new_card.emit(pickup.cardId)
	elif pickup.is_in_group("HealPickup"):
		player_heal.emit(1)

func damage(amount : int):
	player_damage.emit(amount)

func change_speed(amount : float, time_limit = null):
	speed += amount
	if time_limit:
		$Label.visible = true
		$SpeedBostTimer.start(time_limit)

func _physics_process(delta):
	velocity = _get_input_direction() * speed
	move_and_slide()
	_animate()
	
func _process(delta):
	if $Label.visible:
		$Label.text = str(round($SpeedBostTimer.time_left))
	
func _get_input_direction() -> Vector2:
	# Auto-normalized
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")

func _animate():
	if velocity.is_zero_approx():
		animation.play("idle")
	else:
		if abs(velocity.x) > abs(velocity.y):
			if velocity.x > 0:
				animation.play("walk_right")
			else:
				animation.play("walk_left")
		else:
			if velocity.y > 0:
				animation.play("walk_down")
			else:
				animation.play("walk_up")				

func _on_speed_bost_timer_timeout():
	speed = default_speed
	$Label.visible = false

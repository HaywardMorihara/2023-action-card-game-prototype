extends CharacterBody2D

signal blob_drop(pickup)
signal blob_queued_destroy

@export var speed = 50
@export var detection_radius = 200
@export var damage_to_player = 1
@export var collision_bounce : float = 5.0
@export var draw_drop_probability : float = 0.25
@export var heal_drop_probability : float = 0.4

@onready var animation : AnimatedSprite2D = get_node("AnimatedSprite2D")
@onready var bounce_timer : Timer = get_node("BouceTimer")

var draw_pickup_scene = preload("res://world/pickups/DrawPickup.tscn")
var heal_pickup_scene = preload("res://world/pickups/HealPickup.tscn")

var is_queued_destroy := false
var is_bounced := false
var is_disabled := false
var is_destroy_animation_finished := false
var is_destroy_sfx_finished := false

func _ready():
	randomize()

func _physics_process(delta):
	if is_queued_destroy:
		return
	if is_disabled:
		move_and_slide()
		return
	
	# Implementing acceleration would make this feel more natural
	if not is_bounced:
		velocity = _decide_direction() * speed
	# https://docs.godotengine.org/en/stable/tutorials/physics/using_character_body_2d.html#which-movement-method-to-use
	var collision = move_and_collide(velocity * delta)
	if collision:
		# https://docs.godotengine.org/en/stable/tutorials/physics/using_character_body_2d.html
		if collision.get_collider().is_in_group("Player"):
			collision.get_collider().damage(damage_to_player)
			
			# Bounce
			is_bounced = true
			bounce_timer.start()
			velocity = velocity.bounce(collision.get_normal()) * collision_bounce

			# Trying destroy instead of balancing - so the Player has the option to run into a Blog if they run out of cards. At the cost of the top card of their Deck, they destory a Blob and have a 25% chance to Heal/Draw
#			queue_destroy()
		else:
			velocity.slide(collision.get_normal())
	_animate()
	

func _animate():
	if is_queued_destroy:
		animation.play("DestroyedRight")	
	elif velocity.is_zero_approx():
		animation.play("IdleRight")
	else:
		animation.play("HopRight")
		if velocity.x > 0:
			scale.x = 1
		else:	
			scale.x = -1


func _decide_direction() -> Vector2:
	var player_pos = get_tree().get_first_node_in_group("Player").global_position
	if global_position.distance_to(player_pos) > detection_radius:
		return Vector2.ZERO
	return global_position.direction_to(player_pos)

func queue_destroy():
	$HitFrameTimer.start()
	get_tree().paused = true
	is_queued_destroy = true
	animation.play("DestroyedRight")
	var draw_pickup
	var heal_pickup
	if randf_range(0, 1.0) < draw_drop_probability:
		draw_pickup = draw_pickup_scene.instantiate()
		draw_pickup.global_position = global_position
		blob_drop.emit(draw_pickup)
	if randf_range(0, 1.0) < heal_drop_probability:
		heal_pickup = heal_pickup_scene.instantiate()
		heal_pickup.global_position = global_position
		blob_drop.emit(heal_pickup)
	if draw_pickup and heal_pickup:
		draw_pickup.global_position -= Vector2(8, 0)
		heal_pickup.global_position += Vector2(8, 0)
	$SquishSFX.play(0.5)

func _on_animated_sprite_2d_animation_finished():
	is_destroy_animation_finished = true
	visible = false
	collision_layer = 8
	if is_queued_destroy and animation.get_animation() == "DestroyedRight" and is_destroy_animation_finished and is_destroy_sfx_finished:
		queue_free()
		blob_queued_destroy.emit()

func _on_bouce_timer_timeout():
	is_bounced = false

func disable(seconds : float):
	is_disabled = true
	$DisableTimer.start(seconds)

func _on_disable_timer_timeout():
	is_disabled = false


func _on_squish_sfx_finished():
	is_destroy_sfx_finished = true
	if is_queued_destroy and animation.get_animation() == "DestroyedRight" and is_destroy_animation_finished and is_destroy_sfx_finished:
		queue_free()
		blob_queued_destroy.emit()

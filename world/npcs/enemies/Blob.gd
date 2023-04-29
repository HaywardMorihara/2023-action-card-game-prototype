extends CharacterBody2D

signal blob_drop(pickup)
signal blob_queued_destroy

@export var speed = 50
@export var detection_radius = 200
@export var damage_to_player = 1
@export var draw_drop_probability : float = 0.25
@export var heal_drop_probability : float = 0.25

@onready var animation : AnimatedSprite2D = get_node("AnimatedSprite2D")
@onready var bounce_timer : Timer = get_node("BouceTimer")

var draw_pickup_scene = preload("res://world/pickups/DrawPickup.tscn")
var heal_pickup_scene = preload("res://world/pickups/HealPickup.tscn")

var is_queued_destroy := false
var is_bounced := false


func _ready():
	randomize()


func _physics_process(delta):
	if is_queued_destroy:
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
			is_bounced = true
			bounce_timer.start()
			velocity = velocity.bounce(collision.get_normal()) * 2
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


func _on_animated_sprite_2d_animation_finished():
	if is_queued_destroy and animation.get_animation() == "DestroyedRight":
		queue_free()
		blob_queued_destroy.emit()


func _on_bouce_timer_timeout():
	is_bounced = false

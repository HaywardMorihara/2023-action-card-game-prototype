extends CharacterBody2D

signal blob_drop(pickup)
signal blob_queued_destroy

@export var speed = 50
@export var detection_radius = 200
@export var damage_to_player = 1
@export var draw_drop_probability : float = 0.5
@export var new_card_drop_probability : float = 0.1

@onready var animation : AnimatedSprite2D = get_node("AnimatedSprite2D")

var draw_pickup_scene = preload("res://world/pickups/DrawPickup.tscn")
var new_card_pickup_scene = preload("res://world/pickups/NewCardPickup.tscn")

var is_queued_destroy := false


func _ready():
	randomize()


func _physics_process(delta):
	if is_queued_destroy:
		return
	# TODO Needs to be acceleration so there can be an actual bounce
	velocity = _decide_direction() * speed
	# https://docs.godotengine.org/en/stable/tutorials/physics/using_character_body_2d.html#which-movement-method-to-use
	var collision = move_and_collide(velocity * delta)
	if collision:
		# https://docs.godotengine.org/en/stable/tutorials/physics/using_character_body_2d.html
		if collision.get_collider().is_in_group("Player"):
			collision.get_collider().damage(1)
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
	if randf_range(0, 1.0) < draw_drop_probability:
		var pickup = draw_pickup_scene.instantiate()
		pickup.global_position = global_position
		blob_drop.emit(pickup)
	if randf_range(0, 1.0) < new_card_drop_probability:
		var pickup = draw_pickup_scene.instantiate()
		pickup.global_position = global_position
		blob_drop.emit(pickup)


func _on_animated_sprite_2d_animation_finished():
	if is_queued_destroy and animation.get_animation() == "DestroyedRight":
		queue_free()
		blob_queued_destroy.emit()

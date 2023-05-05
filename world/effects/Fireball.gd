extends CharacterBody2D

@export var speed = 200

# https://docs.godotengine.org/en/4.0/tutorials/physics/using_character_body_2d.html
# NOT https://kidscancode.org/godot_recipes/4.x/2d/2d_shooting/ (because not official)

var is_queued_destroy := false

func start(_position : Vector2, _direction : float):
	rotation = _direction
	position = _position
	velocity = Vector2(speed, 0).rotated(rotation)


# https://docs.godotengine.org/en/3.2/tutorials/physics/physics_introduction.html#collision-layers-and-masks
func _physics_process(delta):
	if is_queued_destroy:
		return
	var collision = move_and_collide(velocity * delta)
	if collision:
		var body = collision.get_collider()
		if body.is_in_group("Enemies"):
			body.queue_destroy()
		$ExplosionSFX.play()
		is_queued_destroy = true
		$TailCPUParticles2D.queue_free()
		$BodyCPUParticles2D.queue_free()
		$ExplosionCPUParticles2D.emitting = true


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func _on_explosion_sfx_finished():
	queue_free()

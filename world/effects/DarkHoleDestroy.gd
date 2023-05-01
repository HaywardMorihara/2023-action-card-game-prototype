extends Node2D

signal dark_hole_finished()

@export var strength := 200 

func _ready():
	for body in $EventHorizonArea.get_overlapping_bodies():
		if body.is_in_group("Enemies"):
			body.queue_destory()
	for body in $GravitationalPullArea.get_overlapping_bodies():
		if body.is_on_group("Enemies"):
			suck(body)

func _on_life_timer_timeout():
	$InnerParticles.emitting = false
	$OuterParticles.emitting = false
	$OrbitalParticles.emitting = false
	$CollapseTimer.start()

func _on_collapse_timer_timeout():
	dark_hole_finished.emit()
	queue_free()

func _on_gravitational_pull_area_body_entered(body):
	if body.is_in_group("Enemies"):
		suck(body)

func suck(enemy):
	var hole_to_enemy_pos = global_position - enemy.global_position
	var angle = hole_to_enemy_pos.angle()
	enemy.disable(1)
	enemy.velocity = Vector2(strength, 0).rotated(angle)

func _on_event_horizon_area_body_entered(body):
	if body.is_in_group("Enemies"):
		body.queue_destroy()

extends Node2D
class_name Pole

@export var is_current: bool = false
@export var is_done: bool = false
@export var player_blocker: Node2D
@export var ground_sprite: Sprite2D
@export var particles: GPUParticles2D

signal ball_entered_hole
signal player_entered_pole

func make_current() -> void:
  is_current = true

func make_inactive() -> void:
  is_current = false

func make_done() -> void:
  is_done = true
  ground_sprite.visible = false
  particles.emitting = true

func _on_balldetect_body_entered(body: Node2D) -> void:
  if body.is_in_group('ball'):
    ball_entered_hole.emit()
    player_blocker.queue_free()
    make_done()

  if body.is_in_group('player'):
    player_entered_pole.emit()

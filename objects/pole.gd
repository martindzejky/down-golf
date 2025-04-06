extends Node2D
class_name Pole

@export var is_current: bool = false
@export var is_done: bool = false
@export var player_blocker: Node2D

signal ball_entered_hole
signal player_entered_pole

func make_current() -> void:
  is_current = true

func make_inactive() -> void:
  is_current = false

func _on_balldetect_body_entered(body: Node2D) -> void:
  if body.is_in_group('ball'):
    ball_entered_hole.emit()
    player_blocker.queue_free()
    is_done = true

  if body.is_in_group('player'):
    player_entered_pole.emit()

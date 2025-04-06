extends Node2D

@export var is_done: bool = false
@export var player_blocker: Node2D

signal ball_entered_hole
signal player_entered_pole

func _on_balldetect_body_entered(body: Node2D) -> void:
  if body.is_in_group('ball'):
    ball_entered_hole.emit()
    is_done = true
    player_blocker.queue_free()

  if body.is_in_group('player'):
    player_entered_pole.emit()

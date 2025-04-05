extends Node2D

signal ball_entered_hole

func _on_balldetect_body_entered(body: Node2D) -> void:
  if body.is_in_group('ball'):
    ball_entered_hole.emit()

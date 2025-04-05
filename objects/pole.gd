extends Node2D

signal ball_entered_hole


func _on_balldetect_area_entered(area: Area2D) -> void:
  if area.is_in_group('ball'):
    ball_entered_hole.emit()

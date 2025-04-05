extends Node2D

@export var blocking: Node


func _on_pole_ball_entered_hole() -> void:
  if blocking:
    blocking.queue_free()
    blocking = null

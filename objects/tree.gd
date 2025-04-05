extends Node2D

@export var animation: AnimationPlayer

func _on_area_body_entered(body: Node2D) -> void:
  if body.is_in_group('ball') and not animation.is_playing():
    animation.play('shake')

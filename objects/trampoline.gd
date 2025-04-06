extends Node2D

const BOUNCE_FORCE = 700.0
const BOUNCE_IMPULSE = 1000.0

@export var animation_player: AnimationPlayer
@export var bounce_sound: AudioStreamPlayer

func _on_detector_body_entered(body: Node2D) -> void:
  # Check if the body is the ball or player
  if body.is_in_group('ball'):
    # Apply upward impulse to the ball
    body.apply_central_impulse(Vector2(0, -BOUNCE_IMPULSE))

    # Play animation and sound
    play_bounce_animation()

  elif body.is_in_group('player'):
    # For player, we need to set velocity directly
    body.velocity.y = -BOUNCE_FORCE

    # Play animation and sound
    play_bounce_animation()

func play_bounce_animation() -> void:
  animation_player.play('bounce')
  bounce_sound.play()

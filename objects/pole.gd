extends Node2D
class_name Pole

@export var is_current: bool = false
@export var is_done: bool = false
@export var ball_hits: int = 0

@export var player_blocker: Node2D
@export var ground_sprite: Sprite2D
@export var particles: GPUParticles2D
@export var particles2: GPUParticles2D
@export var animation: AnimationPlayer
@export var hits_number_label: Label

signal ball_entered_hole
signal player_entered_pole

func _ready() -> void:
  # Connect to the player's ball_hit signal
  var player = get_tree().get_first_node_in_group('player')
  player.connect('ball_hit', self._on_player_ball_hit)

func make_current() -> void:
  is_current = true

func make_inactive() -> void:
  is_current = false

func make_done() -> void:
  if is_done: return

  is_done = true
  ground_sprite.visible = false
  particles.emitting = true
  particles2.emitting = true
  animation.play('shake')

func _on_balldetect_body_entered(body: Node2D) -> void:
  if body.is_in_group('ball'):
    ball_entered_hole.emit()
    player_blocker.queue_free()
    make_done()

  if body.is_in_group('player'):
    player_entered_pole.emit()

func _on_player_ball_hit() -> void:
  if is_current and not is_done:
    ball_hits += 1

    if ball_hits < 10:
      hits_number_label.text = str(ball_hits)
    else:
      hits_number_label.text = 'X'

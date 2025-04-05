extends RigidBody2D


@export var particles: GPUParticles2D

var last_velocity: Vector2 = Vector2.ZERO

func _physics_process(_delta: float) -> void:
  last_velocity = linear_velocity

func _on_body_entered(body: Node) -> void:
  if last_velocity.length() > 120:
    particles.emitting = true

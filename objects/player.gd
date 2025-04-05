extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity = ProjectSettings.get_setting('physics/2d/default_gravity')

@export var animation: AnimationPlayer
@export var sprite: Sprite2D

func _physics_process(delta):
  # Add the gravity
  if not is_on_floor():
    velocity.y += gravity * delta

  # Handle jump
  if Input.is_action_just_pressed('jump') and is_on_floor():
    velocity.y = JUMP_VELOCITY

  # Get the input direction and handle the movement/deceleration
  var direction = Input.get_axis('move_left', 'move_right')
  if direction:
    velocity.x = direction * SPEED
    sprite.flip_h = direction < 0
  else:
    velocity.x = move_toward(velocity.x, 0, SPEED)

  # Handle shooting - only when on floor
  if Input.is_action_just_pressed('shoot') and is_on_floor():
    shoot()

  move_and_slide()

  # Update animation
  if not is_on_floor():
    animation.play('jump')
  elif abs(velocity.x) > 0.1:
    animation.play('run')
  else:
    animation.play('idle')

func shoot():
  # TODO: Implement shooting mechanics
  pass

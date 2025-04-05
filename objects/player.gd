extends CharacterBody2D

const SPEED = 160.0
const JUMP_VELOCITY = -400.0
const MIN_SHOOT_POWER = 10.0
const MAX_SHOOT_POWER = 100.0
const SHOOT_IMPULSE_MULTIPLIER = 15.0
const SHOOT_UP_DIVISOR = 180.0

# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity = ProjectSettings.get_setting('physics/2d/default_gravity')

enum State {
  MOVING,
  READY_TO_SHOOT,
  CHARGING,
  SHOOTING
}

var current_state = State.MOVING
var shoot_power = 0.0

@export var flip_node: Node2D
@export var animation: AnimationPlayer
@export var sprite: Sprite2D
@export var shoot_strength_bar: ProgressBar

func _physics_process(delta):
  process_state_machine(delta)

func process_state_machine(delta):
  match current_state:
    State.MOVING:
      process_moving_state(delta)
    State.READY_TO_SHOOT:
      process_ready_to_shoot_state(delta)
    State.CHARGING:
      process_charging_state(delta)
    State.SHOOTING:
      process_shooting_state(delta)

func process_moving_state(delta):
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
    if not is_zero_approx(direction):
      flip_node.scale.x = sign(direction)
  else:
    velocity.x = move_toward(velocity.x, 0, SPEED)

  move_and_slide()

  # Update animation
  if not is_on_floor():
    animation.play('jump')
  elif abs(velocity.x) > 0.1:
    animation.play('run')
  else:
    animation.play('idle')

  # Check for state transition
  if Input.is_action_just_pressed('shoot') and is_on_floor():
    current_state = State.READY_TO_SHOOT

func process_ready_to_shoot_state(delta):
  # Stop all movement
  velocity = Vector2.ZERO
  move_and_slide()

  # Play ready to shoot animation
  animation.play('ready_to_shoot')

  # Check for state transitions
  if Input.is_action_just_pressed('shoot'):
    current_state = State.CHARGING
    shoot_power = 0.0
  # Go back to moving if any movement input is pressed
  elif Input.is_action_pressed('move_left') or Input.is_action_pressed('move_right') or Input.is_action_pressed('jump'):
    current_state = State.MOVING

func process_charging_state(delta):
  # Update shoot strength bar visibility
  shoot_strength_bar.visible = true
  shoot_strength_bar.value = shoot_power

  # Stop all movement
  velocity = Vector2.ZERO
  move_and_slide()

  # Increase power while charging
  shoot_power = min(shoot_power + delta * 50.0, MAX_SHOOT_POWER)

  # Play charging animation
  animation.play('charging')

  # Check for state transitions
  if not Input.is_action_pressed('shoot'):
    if shoot_power >= MIN_SHOOT_POWER:
      current_state = State.SHOOTING
      shoot_strength_bar.visible = false
      animation.play('shooting')
    else:
      current_state = State.READY_TO_SHOOT
      shoot_strength_bar.visible = false
      shoot_power = 0.0

func process_shooting_state(delta):
  # Stop all movement
  velocity = Vector2.ZERO
  move_and_slide()

  # Shooting animation should be playing already

func _on_animation_animation_finished(anim_name: StringName) -> void:
  if anim_name == 'shooting':
    current_state = State.MOVING
    shoot_power = 0.0


func _on_shootarea_body_entered(body: Node2D) -> void:
  if body.is_in_group('ball'):
    var direction = Vector2.RIGHT * flip_node.scale.x + Vector2.UP * (shoot_power / SHOOT_UP_DIVISOR)
    var impulse = direction * shoot_power * SHOOT_IMPULSE_MULTIPLIER
    body.apply_central_impulse(impulse)

    animation.pause()
    await get_tree().create_timer(0.2).timeout
    animation.play()

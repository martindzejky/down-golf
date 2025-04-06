extends CharacterBody2D

const SPEED = 160.0
const JUMP_START_VELOCITY = -200.0
const JUMP_MIN_VELOCITY = -20.0
const JUMP_MAX_VELOCITY = -35.0
const MIN_SHOOT_POWER = 10.0
const MAX_SHOOT_POWER = 100.0
const SHOOT_IMPULSE_MULTIPLIER_X = 15.0
const SHOOT_IMPULSE_MULTIPLIER_Y = 30.0
const AIM_SPEED = 100.0

signal ball_hit

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
var was_in_air = false
var is_jumping = false

# Aiming variables
var aim_angle = 0.0
var aim_direction = 1.0  # 1 for increasing, -1 for decreasing

@export var flip_node: Node2D
@export var animation: AnimationPlayer
@export var sprite: Sprite2D
@export var shoot_strength_bar: ProgressBar
@export var pow: Sprite2D
@export var aim_arrow: Node2D
@export var shoot_area_shape: CollisionShape2D
@export var jump_key: Timer

@export var swing_hit_sound: AudioStreamPlayer
@export var swing_small_sound: AudioStreamPlayer
@export var swing_large_sound: AudioStreamPlayer
@export var jump_sound: AudioStreamPlayer
@export var land_sound: AudioStreamPlayer
@export var ready_to_shoot_sound: AudioStreamPlayer
@export var charging_sound: AudioStreamPlayer

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

    # Apply jump force while key is held and timer is running
    if is_jumping and Input.is_action_pressed('jump') and not jump_key.is_stopped():
      # Interpolate from max to min velocity as timer counts down
      var t = jump_key.time_left / jump_key.wait_time
      var jump_force = lerp(JUMP_MIN_VELOCITY, JUMP_MAX_VELOCITY, t)
      velocity.y += jump_force * delta * 60.0  # Normalize to 60fps
    elif not Input.is_action_pressed('jump'):
      # Reset jumping state when key is released
      is_jumping = false
  else:
    # Reset jumping state when on floor
    is_jumping = false

  # Handle jump
  if Input.is_action_just_pressed('jump') and is_on_floor():
    is_jumping = true
    jump_key.start()
    velocity.y = JUMP_START_VELOCITY
    jump_sound.play()

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
    was_in_air = true
    if velocity.y < 0:
      animation.play('jump')
    else:
      animation.play('falling')
  elif was_in_air:
    was_in_air = false
    land_sound.play()
    animation.play('idle')
  elif abs(velocity.x) > 0.1:
    animation.play('run')
  else:
    animation.play('idle')

  # Check for state transition
  if Input.is_action_just_pressed('shoot') and is_on_floor():
    current_state = State.READY_TO_SHOOT
    ready_to_shoot_sound.play()

func process_ready_to_shoot_state(delta):
  # Stop all movement
  velocity = Vector2.ZERO
  move_and_slide()

  # Play ready to shoot animation
  animation.play('ready_to_shoot')

  # Handle aiming
  aim_arrow.visible = true
  aim_arrow.scale.x = 1.0

  # Update aim angle
  aim_angle += aim_direction * AIM_SPEED * delta

  # Change direction when reaching limits
  if aim_angle >= 90:
    aim_angle = 90
    aim_direction = -1
  elif aim_angle <= 0:
    aim_angle = 0
    aim_direction = 1

  # Set rotation based on player direction
  aim_arrow.rotation_degrees = -aim_angle

  # Check for state transitions
  if Input.is_action_just_pressed('shoot'):
    current_state = State.CHARGING
    charging_sound.play()
    shoot_power = 0.0
    swing_small_sound.play()
  # Go back to moving if any movement input is pressed
  elif Input.is_action_pressed('move_left') or Input.is_action_pressed('move_right') or Input.is_action_pressed('jump'):
    current_state = State.MOVING
    aim_arrow.visible = false

func process_charging_state(delta):
  # Update shoot strength bar visibility
  shoot_strength_bar.visible = true
  shoot_strength_bar.value = shoot_power

  # Scale aim arrow sprite based on power
  var power_scale = 0.5 + shoot_power / MAX_SHOOT_POWER
  aim_arrow.scale.x = power_scale

  # Stop all movement
  velocity = Vector2.ZERO
  move_and_slide()

  # Increase power while charging
  shoot_power = shoot_power + delta * 50.0
  if shoot_power > MAX_SHOOT_POWER:
    current_state = State.READY_TO_SHOOT
    shoot_strength_bar.visible = false
    shoot_power = 0.0
    charging_sound.stop()

  # Play charging animation
  animation.play('charging')

  # Check for state transitions
  if not Input.is_action_pressed('shoot'):
    if shoot_power >= MIN_SHOOT_POWER:
      swing_large_sound.play()
      current_state = State.SHOOTING
      shoot_strength_bar.visible = false
      animation.play('shooting')
      aim_arrow.visible = false
      charging_sound.stop()
    else:
      current_state = State.READY_TO_SHOOT
      shoot_strength_bar.visible = false
      shoot_power = 0.0
      charging_sound.stop()

func process_shooting_state(delta):
  # Stop all movement
  velocity = Vector2.ZERO
  move_and_slide()

  # Shooting animation should be playing already

func _on_animation_animation_finished(anim_name: StringName) -> void:
  if anim_name == 'shooting':
    current_state = State.MOVING
    shoot_power = 0.0
    aim_angle = 0.0


func _on_shootarea_body_entered(body: Node2D) -> void:
  if body.is_in_group('ball'):
    # Calculate direction based on aim angle.
    # Negate angle to match the arrow rotation.
    var rad_angle = deg_to_rad(-aim_angle)
    # When facing left, we need to flip the x component of the direction
    var direction = Vector2(cos(rad_angle) * flip_node.scale.x, -sin(rad_angle))

    # Apply different multipliers for X and Y to compensate for gravity
    var impulse = Vector2(
      direction.x * shoot_power * SHOOT_IMPULSE_MULTIPLIER_X,
      direction.y * shoot_power * SHOOT_IMPULSE_MULTIPLIER_Y
    )

    body.apply_central_impulse(impulse)

    emit_signal('ball_hit')
    call_deferred('disable_shoot_area')

    animation.pause()
    pow.visible = true
    swing_hit_sound.play()
    await get_tree().create_timer(0.2).timeout
    animation.play()
    pow.visible = false

func disable_shoot_area() -> void:
  shoot_area_shape.disabled = true

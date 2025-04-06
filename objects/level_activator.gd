extends Node

@export var pole: Pole
@export var camera_bounds: CameraBounds

func _ready():
  # If there is no current pole, activate this level.
  # Used for testing a single level at a time.
  var poles = get_tree().get_nodes_in_group('pole')
  var found_current_pole = false
  for pole in poles:
    if pole.is_current:
      found_current_pole = true
      break

  if not found_current_pole:
    activate()

func activate() -> void:
  # Deactivate all poles
  get_tree().call_group('pole', 'make_inactive')

  # Activate this level's pole
  pole.make_current()

  # Activate camera bounds
  camera_bounds.activate()

func deactivate() -> void:
  # Deactivate all poles
  get_tree().call_group('pole', 'make_inactive')

  # Deactivate camera bounds
  camera_bounds.deactivate()

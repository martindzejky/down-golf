extends Node2D
class_name CameraBounds

@export var shape: CollisionShape2D

func activate() -> void:
  print('camera bounds activate')

  # Get current camera (usually from viewport)
  var camera = get_viewport().get_camera_2d()

  # Get shape extents
  var extents = shape.shape.size / 2

  # Calculate global bounds
  var global_pos = shape.global_position

  # Set camera limits based on shape position and extents
  camera.limit_left = global_pos.x - extents.x
  camera.limit_right = global_pos.x + extents.x
  camera.limit_top = global_pos.y - extents.y
  camera.limit_bottom = global_pos.y + extents.y

func deactivate() -> void:
  # Get current camera
  var camera = get_viewport().get_camera_2d()

  # Reset to original limits
  camera.limit_left = -10000000
  camera.limit_right = 10000000
  camera.limit_top = -10000000
  camera.limit_bottom = 10000000

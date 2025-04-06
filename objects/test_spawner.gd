extends Node2D

@export var player_scene: PackedScene
@export var ball_scene: PackedScene
@export var camera_scene: PackedScene
@export var level_pole: Pole

func _ready():
  # Check if player exists already
  if get_tree().get_nodes_in_group('player').size() == 0:
    # Spawn player
    var player_instance = player_scene.instantiate()
    add_child(player_instance)

    # Spawn ball
    var ball_instance = ball_scene.instantiate()
    add_child(ball_instance)

    # Spawn camera
    var camera_instance = camera_scene.instantiate()
    add_child(camera_instance)

  # If there is no current pole, mark the linked one
  var poles = get_tree().get_nodes_in_group('pole')
  var found_current_pole = false
  for pole in poles:
    if pole.is_current:
      found_current_pole = true
      break

  if not found_current_pole:
    level_pole.make_current()

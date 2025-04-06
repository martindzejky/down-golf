extends Node2D
class_name TestSpawner

@export var player_scene: PackedScene
@export var ball_scene: PackedScene
@export var camera_scene: PackedScene

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

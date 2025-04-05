extends Camera2D

var player: Node2D
var ball: Node2D

func _ready():
  # Get references to player and ball using their group names
  player = get_tree().get_first_node_in_group('player')
  ball = get_tree().get_first_node_in_group('ball')

func _process(_delta):
  if not player or not ball:
    return

  # Get current viewport size (in screen coordinates)
  var viewport_size = get_viewport_rect().size

  # Convert to world coordinates by accounting for zoom
  var world_viewport_size = viewport_size / zoom

  # Calculate the midpoint between player and ball
  var midpoint = (player.global_position + ball.global_position) / 2

  # Calculate max distance from player to keep them in view (half viewport minus margin)
  # The margin is also scaled by zoom
  var margin = 150 / zoom.x  # pixels from edge of screen, adjusted for zoom
  var max_distance = world_viewport_size / 2 - Vector2(margin, margin)

  # Clamp camera position relative to player
  var offset = midpoint - player.global_position
  offset = offset.clamp(-max_distance, max_distance)

  # Set camera position
  global_position = player.global_position + offset

extends Camera2D

const BALL_CONSIDERATION_DISTANCE = 600
const POLE_CONSIDERATION_DISTANCE = 400
const PLAYER_VIEW_MARGIN = 200

var player: Node2D
var ball: Node2D

func _ready():
  # Get references to player and ball using their group names
  player = get_tree().get_first_node_in_group('player')
  ball = get_tree().get_first_node_in_group('ball')

func _process(_delta):
  # Find the current pole
  var poles = get_tree().get_nodes_in_group('pole')
  var current_pole = null
  for pole in poles:
    if pole.is_current:
      current_pole = pole
      break

  # Poles have a camera_marker child node which should be used for camera calculations
  var pole_camera_marker = null
  if current_pole:
    pole_camera_marker = current_pole.get_node('camera_marker')

  # Find all camera points
  var camera_points = get_tree().get_nodes_in_group('camera_point')

  # Filter only those that are within their consideration distance of the player
  var filtered_camera_points = []
  for point in camera_points:
    if point.global_position.distance_to(player.global_position) < point.consideration_distance:
      filtered_camera_points.append(point)

  # Get current viewport size (in screen coordinates)
  var viewport_size = get_viewport_rect().size

  # Convert to world coordinates by accounting for zoom
  var world_viewport_size = viewport_size / zoom

  # Calculate the midpoint between player and ball, and possibly pole
  var midpoint: Vector2
  var points = [player.global_position]

  # Check if ball is close enough to consider
  if player.global_position.distance_to(ball.global_position) < BALL_CONSIDERATION_DISTANCE:
    points.append(ball.global_position)

  # Check if pole is close enough to consider
  if pole_camera_marker and player.global_position.distance_to(pole_camera_marker.global_position) < POLE_CONSIDERATION_DISTANCE:
    points.append(pole_camera_marker.global_position)

  # Add all filtered camera points
  for point in filtered_camera_points:
    points.append(point.global_position)

  # Calculate midpoint based on all considered points
  midpoint = Vector2.ZERO
  for point in points:
    midpoint += point
  midpoint = midpoint / points.size()

  # Calculate max distance from player to keep them in view (half viewport minus margin)
  # The margin is also scaled by zoom
  var margin = PLAYER_VIEW_MARGIN / zoom.x  # pixels from edge of screen, adjusted for zoom
  var max_distance = world_viewport_size / 2 - Vector2(margin, margin)

  # Clamp camera position relative to player
  var offset = midpoint - player.global_position
  offset = offset.clamp(-max_distance, max_distance)

  # Set camera position
  global_position = player.global_position + offset

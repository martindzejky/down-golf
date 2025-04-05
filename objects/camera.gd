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

  # Calculate the midpoint between player and ball
  var midpoint = (player.global_position + ball.global_position) / 2
  global_position = midpoint

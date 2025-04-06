extends Label

var total_shots = 0

func _ready():
  call_deferred('connect_to_player')

func connect_to_player():
  var player = get_tree().get_first_node_in_group('player')
  player.connect('ball_hit', update_total_shots)

func update_total_shots():
  total_shots += 1
  text = 'Total shots: ' + str(total_shots)

extends HBoxContainer

@export var pole: Pole
@export var label: Label

var shots = 0
var level_name = ''

func _ready():
  level_name = process_level_name(pole.get_parent().name)
  call_deferred('connect_to_player')
  update_label_text()
  visible = false

func connect_to_player():
  var player = get_tree().get_first_node_in_group('player')
  player.connect('ball_hit', update_shots)

func update_shots():
  if pole.is_current:
    shots += 1
    update_label_text()
    visible = true

func update_label_text():
  label.text = level_name + ': ' + str(shots)

func process_level_name(level_name_to_process: String):
  return level_name_to_process.replace('_', ' ').capitalize()
extends VFlowContainer

@export var level_shots_scene: PackedScene

func _ready() -> void:
  call_deferred('setup_level_shots')

func setup_level_shots() -> void:
  var poles = get_tree().get_nodes_in_group('pole')
  for pole in poles:
    var level_shots = level_shots_scene.instantiate()
    level_shots.pole = pole
    add_child(level_shots)

extends Node

@export var first_level_activator: LevelActivator

func _ready():
  first_level_activator.activate()

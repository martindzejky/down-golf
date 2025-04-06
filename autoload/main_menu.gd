extends Node

@export var menu: Node

func _ready():
  # Make sure the menu is initially hidden
  menu.visible = false

func _process(_delta):
  if Input.is_action_just_pressed('menu'):
    toggle_menu()

func toggle_menu():
  # Toggle the menu visibility
  menu.visible = !menu.visible

  # Toggle the game pause state
  get_tree().paused = menu.visible


func _on_restart_pressed() -> void:
  toggle_menu()

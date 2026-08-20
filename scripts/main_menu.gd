extends Control
class_name MainMenu

signal start_game_pressed
signal settings_pressed
signal quit_pressed

@onready var start_button: Button = $Center/VBox/StartButton
@onready var settings_button: Button = $Center/VBox/SettingsButton
@onready var quit_button: Button = $Center/VBox/QuitButton

func _ready() -> void:
    start_button.pressed.connect(_on_start)
    settings_button.pressed.connect(_on_settings)
    quit_button.pressed.connect(_on_quit)

func _on_start() -> void:
    start_game_pressed.emit()

func _on_settings() -> void:
    settings_pressed.emit()

func _on_quit() -> void:
    quit_pressed.emit()

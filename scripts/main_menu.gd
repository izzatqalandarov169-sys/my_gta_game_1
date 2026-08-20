extends Control
class_name MainMenu

signal open_world_pressed
signal multiplayer_pressed
signal garage_pressed
signal weapon_shop_pressed
signal settings_pressed
signal quit_pressed

@onready var open_world_button: Button = $MenuGrid/OpenWorldButton
@onready var multiplayer_button: Button = $MenuGrid/MultiplayerButton
@onready var garage_button: Button = $MenuGrid/GarageButton
@onready var weapon_shop_button: Button = $MenuGrid/WeaponShopButton
@onready var settings_button: Button = $Bottom/SettingsButton
@onready var quit_button: Button = $Bottom/QuitButton

func _ready() -> void:
    open_world_button.pressed.connect(_on_open_world)
    multiplayer_button.pressed.connect(_on_multiplayer)
    garage_button.pressed.connect(_on_garage)
    weapon_shop_button.pressed.connect(_on_weapon_shop)
    settings_button.pressed.connect(_on_settings)
    quit_button.pressed.connect(_on_quit)

func _on_open_world() -> void:
    open_world_pressed.emit()

func _on_multiplayer() -> void:
    multiplayer_pressed.emit()

func _on_garage() -> void:
    garage_pressed.emit()

func _on_weapon_shop() -> void:
    weapon_shop_pressed.emit()

func _on_settings() -> void:
    settings_pressed.emit()

func _on_quit() -> void:
    quit_pressed.emit()

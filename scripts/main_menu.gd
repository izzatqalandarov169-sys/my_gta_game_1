extends Control
class_name MainMenu

signal open_world_pressed
signal multiplayer_pressed
auto
signal garage_pressed
signal weapon_shop_pressed
signal settings_pressed
signal quit_pressed

@onready var open_world_button: Button = $MenuGrid/OpenWorldButton
@onready var multiplayer_button: Button = $MenuGrid/MultiplayerButton
@onready var garage_button: Button = $MenuGrid/GarageButton
@onready var weapon_shop_button: Button = $MenuGrid/WeaponShopButton
@onready var settings_button: Button = $Bottom/SettingsButton
@onready var promo_button: Button = $Bottom/PromoCodeButton
@onready var quit_button: Button = $Bottom/QuitButton

var promo_system: PromoCodeSystem
var promo_popup: PanelContainer
var promo_input: LineEdit
var promo_status: Label
const PLAYER_ID := "local_player"

func _ready() -> void:
    promo_system = GameServices.promos
    GameServices.register_player(PLAYER_ID)
    open_world_button.pressed.connect(_on_open_world)
    multiplayer_button.pressed.connect(_on_multiplayer)
    garage_button.pressed.connect(_on_garage)
    weapon_shop_button.pressed.connect(_on_weapon_shop)
    settings_button.pressed.connect(_on_settings)
    promo_button.pressed.connect(_on_promo_button)
    quit_button.pressed.connect(_on_quit)
    _build_promo_popup()

func _build_promo_popup() -> void:
    promo_popup = PanelContainer.new()
    promo_popup.set_anchors_preset(Control.PRESET_CENTER)
    promo_popup.position = Vector2(-250, -170)
    promo_popup.custom_minimum_size = Vector2(500, 340)
    promo_popup.visible = false
    add_child(promo_popup)

    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation", 14)
    promo_popup.add_child(box)

    var title := Label.new()
    title.text = "🎟 PROMO CODE"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 28)
    box.add_child(title)

    var hint := Label.new()
    hint.text = "Kodingizni kiriting"
    hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    box.add_child(hint)

    promo_input = LineEdit.new()
    promo_input.placeholder_text = "MASALAN: DILSHOD2026"
    promo_input.max_length = 32
    promo_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
    box.add_child(promo_input)

    var activate := Button.new()
    activate.text = "ACTIVATE"
    activate.custom_minimum_size = Vector2(0, 56)
    activate.pressed.connect(_activate_promo)
    box.add_child(activate)

    promo_status = Label.new()
    promo_status.text = ""
    promo_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    promo_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    box.add_child(promo_status)

    var close := Button.new()
    close.text = "YOPISH"
    close.pressed.connect(func(): promo_popup.visible = false)
    box.add_child(close)

func _on_promo_button() -> void:
    promo_popup.visible = true
    promo_input.grab_focus()
    promo_status.text = ""

func _activate_promo() -> void:
    var code := promo_input.text.strip_edges().to_upper()
    if code.is_empty():
        promo_status.text = "❌ Kodni kiriting."
        return

    var result := GameServices.redeem_promo(PLAYER_ID, code)
    if bool(result.get("ok", false)):
        var reward: Dictionary = result.get("reward", {})
        promo_status.text = "✅ Promo faollashtirildi!\nMukofot: %s\nBalans: %s so‘m" % [str(reward), _money(int(reward.get("balance_uzs", 0)))]
        promo_input.clear()
    else:
        var reason := str(result.get("reason", "unknown"))
        var messages := {
            "not_found": "❌ Bunday promo kod topilmadi.",
            "expired": "⏰ Promo kod muddati tugagan.",
            "already_used": "⚠️ Bu promo kod allaqachon ishlatilgan.",
            "banned": "🚫 Hisob bloklangan.",
            "reward_rejected": "❌ Mukofot server tomonidan rad etildi."
        }
        promo_status.text = str(messages.get(reason, "❌ Promo kod qabul qilinmadi."))

func _money(value: int) -> String:
    return "{0}".format([value]).insert(0, "")

func _on_open_world() -> void:
    open_world_pressed.emit()
    get_tree().change_scene_to_file("res://scenes/OpenWorld.tscn")

func _on_multiplayer() -> void:
    multiplayer_pressed.emit()
    get_tree().change_scene_to_file("res://scenes/OpenWorld.tscn")

func _on_garage() -> void:
    garage_pressed.emit()

func _on_weapon_shop() -> void:
    weapon_shop_pressed.emit()

func _on_settings() -> void:
    settings_pressed.emit()

func _on_quit() -> void:
    quit_pressed.emit()
    get_tree().quit()

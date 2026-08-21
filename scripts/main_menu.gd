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
@onready var promo_button: Button = $Bottom/PromoCodeButton
@onready var quit_button: Button = $Bottom/QuitButton

var promo_popup: PanelContainer
var promo_input: LineEdit
var promo_status: Label
var modal: PanelContainer
var modal_title: Label
var modal_body: VBoxContainer
const PLAYER_ID := "local_player"
const SETTINGS_PATH := "user://uzbek_legends_settings.cfg"

func _ready() -> void:
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
        promo_status.text = "✅ Promo faollashtirildi!\nMukofot: %s\nBalans: %s" % [str(reward), _money(int(reward.get("balance_uzs", 0)))]
        promo_input.clear()
    else:
        var reason := str(result.get("reason", "unknown"))
        var messages := {"not_found":"❌ Bunday promo kod topilmadi.","expired":"⏰ Promo kod muddati tugagan.","already_used":"⚠️ Bu promo kod allaqachon ishlatilgan.","banned":"🚫 Hisob bloklangan.","reward_rejected":"❌ Mukofot server tomonidan rad etildi."}
        promo_status.text = str(messages.get(reason, "❌ Promo kod qabul qilinmadi."))

func _money(value: int) -> String:
    var text := str(value)
    var result := ""
    while text.length() > 3:
        result = " " + text.substr(text.length() - 3, 3) + result
        text = text.substr(0, text.length() - 3)
    return text + result + " so‘m"

func _create_modal(title_text: String, size: Vector2 = Vector2(900, 600)) -> void:
    _close_modal()
    modal = PanelContainer.new()
    modal.set_anchors_preset(Control.PRESET_CENTER)
    modal.position = -size / 2.0
    modal.custom_minimum_size = size
    add_child(modal)
    var root := VBoxContainer.new()
    root.add_theme_constant_override("separation", 12)
    modal.add_child(root)
    modal_title = Label.new()
    modal_title.text = title_text
    modal_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    modal_title.add_theme_font_size_override("font_size", 30)
    root.add_child(modal_title)
    modal_body = VBoxContainer.new()
    modal_body.add_theme_constant_override("separation", 8)
    modal_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
    root.add_child(modal_body)
    var close := Button.new()
    close.text = "← ORQAGA"
    close.custom_minimum_size = Vector2(0, 52)
    close.pressed.connect(_close_modal)
    root.add_child(close)

func _close_modal() -> void:
    if is_instance_valid(modal):
        modal.queue_free()
    modal = null
    modal_title = null
    modal_body = null

func _on_garage() -> void:
    garage_pressed.emit()
    _create_modal("🚗 GARAJ — AVTOMOBILLAR")
    var info := Label.new()
    info.text = "Barcha katalog ochiq. Mashinani tanlang:"
    info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    modal_body.add_child(info)
    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    modal_body.add_child(scroll)
    var list := VBoxContainer.new()
    list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(list)
    var temp := VehicleSystem.new()
    var catalog: Array[Dictionary] = temp._build_catalog()
    temp.free()
    for model in catalog:
        var button := Button.new()
        button.custom_minimum_size = Vector2(0, 52)
        button.text = "%s %s • %s • %s so‘m" % [str(model.get("brand", "")), str(model.get("name", "")), str(model.get("type", "")), _money(int(model.get("price", 0)))]
        button.pressed.connect(_select_vehicle.bind(model))
        list.add_child(button)

func _select_vehicle(model: Dictionary) -> void:
    GameServices.set_meta("selected_vehicle", model.duplicate(true))
    if modal_title != null:
        modal_title.text = "✅ TANLANDI: %s %s" % [str(model.get("brand", "")), str(model.get("name", ""))]

func _on_weapon_shop() -> void:
    weapon_shop_pressed.emit()
    _create_modal("🔫 QUROL DO‘KONI")
    var info := Label.new()
    info.text = "Qurollar katalogi: tanlang va jihozlang."
    info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    modal_body.add_child(info)
    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    modal_body.add_child(scroll)
    var list := VBoxContainer.new()
    list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(list)
    var temp := WeaponSystem.new()
    var catalog: Array[Dictionary] = temp._build_catalog()
    temp.free()
    for index in range(catalog.size()):
        var weapon: Dictionary = catalog[index]
        var button := Button.new()
        button.custom_minimum_size = Vector2(0, 52)
        button.text = "%02d. %s • %s so‘m" % [index + 1, str(weapon.get("name", "")), _money(int(weapon.get("price", 0)))]
        button.pressed.connect(_select_weapon.bind(index, weapon))
        list.add_child(button)

func _select_weapon(index: int, weapon: Dictionary) -> void:
    GameServices.set_meta("selected_weapon", weapon.duplicate(true))
    GameServices.set_meta("selected_weapon_index", index)
    if modal_title != null:
        modal_title.text = "✅ JIHOZLANDI: %s" % str(weapon.get("name", ""))

func _on_settings() -> void:
    settings_pressed.emit()
    _create_modal("⚙️ SOZLAMALAR", Vector2(650, 500))
    var config := ConfigFile.new()
    config.load(SETTINGS_PATH)
    var graphics := CheckButton.new()
    graphics.text = "Yengil grafik rejimi"
    graphics.button_pressed = bool(config.get_value("graphics", "low", false))
    graphics.toggled.connect(func(value):
        config.set_value("graphics", "low", value)
        config.save(SETTINGS_PATH)
    )
    modal_body.add_child(graphics)
    var vibration := CheckButton.new()
    vibration.text = "Vibratsiya"
    vibration.button_pressed = bool(config.get_value("controls", "vibration", true))
    vibration.toggled.connect(func(value):
        config.set_value("controls", "vibration", value)
        config.save(SETTINGS_PATH)
    )
    modal_body.add_child(vibration)
    var fps := OptionButton.new()
    fps.add_item("30 FPS")
    fps.add_item("45 FPS")
    fps.add_item("60 FPS")
    var current_fps := int(config.get_value("graphics", "fps", 60))
    fps.select(clampi((current_fps - 30) / 15, 0, 2))
    fps.item_selected.connect(func(index):
        var values := [30, 45, 60]
        config.set_value("graphics", "fps", values[index])
        config.save(SETTINGS_PATH)
    )
    modal_body.add_child(fps)
    var note := Label.new()
    note.text = "📱 Mobil boshqaruv saqlanadi. PC tugmalari bu menyuga qo‘shilmaydi."
    note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    modal_body.add_child(note)

func _on_open_world() -> void:
    open_world_pressed.emit()
    get_tree().change_scene_to_file("res://scenes/OpenWorld.tscn")

func _on_multiplayer() -> void:
    multiplayer_pressed.emit()
    get_tree().change_scene_to_file("res://scenes/OpenWorld.tscn")

func _on_quit() -> void:
    quit_pressed.emit()
    get_tree().quit()

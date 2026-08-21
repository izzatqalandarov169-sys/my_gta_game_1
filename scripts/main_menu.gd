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

const PLAYER_ID := "local_player"
const SETTINGS_PATH := "user://uzbek_legends_settings.cfg"

var promo_popup: PanelContainer
var promo_input: LineEdit
var promo_status: Label
var modal: PanelContainer
var modal_title: Label
var modal_body: VBoxContainer
var balance_label: Label
var preview_viewport: SubViewport
var preview_world: Node3D
var preview_camera: Camera3D
var selected_item: Dictionary = {}
var selected_item_type := ""

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
    _build_balance_label()

func _build_balance_label() -> void:
    balance_label = Label.new()
    balance_label.position = Vector2(20, 145)
    balance_label.size = Vector2(350, 42)
    balance_label.add_theme_font_size_override("font_size", 18)
    balance_label.text = "💰 %s" % _money(GameServices.get_balance_uzs(PLAYER_ID))
    add_child(balance_label)

func _refresh_balance() -> void:
    if balance_label != null:
        balance_label.text = "💰 %s" % _money(GameServices.get_balance_uzs(PLAYER_ID))

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
        _refresh_balance()
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

func _create_modal(title_text: String, size: Vector2 = Vector2(1080, 620)) -> void:
    _close_modal()
    modal = PanelContainer.new()
    modal.set_anchors_preset(Control.PRESET_CENTER)
    modal.position = -size / 2.0
    modal.custom_minimum_size = size
    add_child(modal)
    var root := VBoxContainer.new()
    root.add_theme_constant_override("separation", 10)
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
    selected_item = {}
    selected_item_type = ""
    preview_viewport = null
    preview_world = null
    preview_camera = null

func _make_catalog_layout(title_text: String) -> Dictionary:
    _create_modal(title_text)
    var split := HBoxContainer.new()
    split.size_flags_vertical = Control.SIZE_EXPAND_FILL
    split.add_theme_constant_override("separation", 16)
    modal_body.add_child(split)

    var left := VBoxContainer.new()
    left.custom_minimum_size = Vector2(560, 0)
    left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    split.add_child(left)

    var right := VBoxContainer.new()
    right.custom_minimum_size = Vector2(390, 0)
    right.add_theme_constant_override("separation", 8)
    split.add_child(right)

    preview_viewport = SubViewport.new()
    preview_viewport.size = Vector2i(360, 300)
    preview_viewport.transparent_bg = false
    preview_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    var preview_container := SubViewportContainer.new()
    preview_container.custom_minimum_size = Vector2(360, 300)
    preview_container.stretch = true
    preview_container.add_child(preview_viewport)
    right.add_child(preview_container)

    preview_world = Node3D.new()
    preview_viewport.add_child(preview_world)
    var env := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color("#101820")
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color("#b9c8d8")
    environment.ambient_light_energy = 1.2
    env.environment = environment
    preview_world.add_child(env)
    var light := DirectionalLight3D.new()
    light.rotation_degrees = Vector3(-35, -25, 0)
    light.light_energy = 1.4
    preview_world.add_child(light)
    preview_camera = Camera3D.new()
    preview_camera.position = Vector3(0, 1.8, 6.0)
    preview_camera.look_at(Vector3(0, 0.9, 0))
    preview_viewport.add_child(preview_camera)
    preview_camera.current = true

    return {"left": left, "right": right}

func _on_garage() -> void:
    garage_pressed.emit()
    var ui := _make_catalog_layout("🚗 GARAJ — AVTOMOBILLAR")
    var left: VBoxContainer = ui.left
    var right: VBoxContainer = ui.right
    var info := Label.new()
    info.text = "Mashina shu yerning o‘zida ko‘rinadi. Sotib ol → TANLASH → OPEN WORLD."
    info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    left.add_child(info)
    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    left.add_child(scroll)
    var list := VBoxContainer.new()
    list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(list)
    var temp := VehicleSystem.new()
    var catalog: Array[Dictionary] = temp._build_catalog()
    temp.free()
    for model in catalog:
        var id := "%s:%s" % [str(model.get("brand", "")), str(model.get("name", ""))]
        var button := Button.new()
        button.custom_minimum_size = Vector2(0, 62)
        button.text = "%s %s  •  %s  •  %s" % [str(model.get("brand", "")), str(model.get("name", "")), str(model.get("year_to", "")), _money(int(model.get("price", 0)))]
        button.pressed.connect(_show_vehicle.bind(model, id, right))
        list.add_child(button)
    _show_vehicle(catalog[0], "%s:%s" % [str(catalog[0].get("brand", "")), str(catalog[0].get("name", ""))], right)

func _brand_color(brand: String) -> Color:
    var colors := {
        "Uzbekistan": Color("#e7e9ed"), "Tesla": Color("#d82121"), "BMW": Color("#2d73c8"),
        "Rolls-Royce": Color("#b6b6b6"), "Lamborghini": Color("#f1b400"), "Porsche": Color("#b51f1f"),
        "Ferrari": Color("#d51f2b"), "Mercedes-Benz": Color("#c9d0d8"), "Super Vehicles": Color("#5b7cff")
    }
    return colors.get(brand, Color("#5d7aa3"))

func _clear_preview() -> void:
    if preview_world == null:
        return
    for child in preview_world.get_children():
        if child is MeshInstance3D or child is Node3D and child.name == "PreviewVehicle":
            child.queue_free()

func _show_vehicle(model: Dictionary, id: String, right: VBoxContainer) -> void:
    selected_item = model.duplicate(true)
    selected_item_type = "vehicle"
    _clear_preview()
    var root := Node3D.new()
    root.name = "PreviewVehicle"
    preview_world.add_child(root)
    var body := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = Vector3(2.8, 0.8, 4.8)
    body.mesh = mesh
    body.position.y = 0.55
    body.material_override = _mat(_brand_color(str(model.get("brand", ""))), 0.28, 0.25)
    root.add_child(body)
    var cabin := MeshInstance3D.new()
    var cabin_mesh := BoxMesh.new()
    cabin_mesh.size = Vector3(2.15, 0.72, 2.15)
    cabin.mesh = cabin_mesh
    cabin.position = Vector3(0, 1.18, 0.25)
    cabin.material_override = _mat(Color("#182532"), 0.12, 0.05)
    root.add_child(cabin)
    for p in [Vector3(-1.25, 0.35, -1.55), Vector3(1.25, 0.35, -1.55), Vector3(-1.25, 0.35, 1.55), Vector3(1.25, 0.35, 1.55)]:
        var wheel := MeshInstance3D.new()
        var wheel_mesh := CylinderMesh.new()
        wheel_mesh.top_radius = 0.43
        wheel_mesh.bottom_radius = 0.43
        wheel_mesh.height = 0.25
        wheel_mesh.radial_segments = 16
        wheel.mesh = wheel_mesh
        wheel.position = p
        wheel.rotation_degrees = Vector3(90, 0, 0)
        wheel.material_override = _mat(Color("#090b0e"), 0.9)
        root.add_child(wheel)
    root.rotation_degrees.y = -20

    for child in right.get_children():
        if child is Label or child is Button:
            child.queue_free()
    var name_label := Label.new()
    name_label.text = "%s %s" % [str(model.get("brand", "")), str(model.get("name", ""))]
    name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    name_label.add_theme_font_size_override("font_size", 24)
    right.add_child(name_label)
    var spec := Label.new()
    spec.text = "%s–%s  •  %s  •  %d km/soat\nNarxi: %s" % [str(model.get("year_from", "")), str(model.get("year_to", "")), str(model.get("type", "")), int(model.get("speed", 0)), _money(int(model.get("price", 0)))]
    spec.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    spec.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    right.add_child(spec)
    var buy := Button.new()
    buy.custom_minimum_size = Vector2(0, 58)
    var owned := GameServices.owns(PLAYER_ID, "vehicle", id)
    buy.text = "✅ TANLASH" if owned else "💰 SOTIB OLISH"
    buy.pressed.connect(_buy_or_select.bind("vehicle", id, int(model.get("price", 0))))
    right.add_child(buy)
    var hint := Label.new()
    hint.text = "Sotib olingan mashina keyin istalgan payt tanlanadi."
    hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    right.add_child(hint)

func _on_weapon_shop() -> void:
    weapon_shop_pressed.emit()
    var ui := _make_catalog_layout("🔫 QUROL DO‘KONI")
    var left: VBoxContainer = ui.left
    var right: VBoxContainer = ui.right
    var info := Label.new()
    info.text = "Qurol shu yerning o‘zida ko‘rinadi. Sotib ol → TANLASH → OPEN WORLD."
    info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    left.add_child(info)
    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    left.add_child(scroll)
    var list := VBoxContainer.new()
    list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroll.add_child(list)
    var temp := WeaponSystem.new()
    var catalog: Array[Dictionary] = temp._build_catalog()
    temp.free()
    for index in range(catalog.size()):
        var weapon: Dictionary = catalog[index]
        var id := str(weapon.get("name", ""))
        var button := Button.new()
        button.custom_minimum_size = Vector2(0, 58)
        button.text = "%02d. %s  •  %s" % [index + 1, id, _money(int(weapon.get("price", 0)))]
        button.pressed.connect(_show_weapon.bind(index, weapon, id, right))
        list.add_child(button)
    _show_weapon(0, catalog[0], str(catalog[0].get("name", "")), right)

func _show_weapon(index: int, weapon: Dictionary, id: String, right: VBoxContainer) -> void:
    selected_item = weapon.duplicate(true)
    selected_item_type = "weapon"
    _clear_preview()
    var root := Node3D.new()
    root.name = "PreviewWeapon"
    preview_world.add_child(root)
    var barrel := MeshInstance3D.new()
    var barrel_mesh := BoxMesh.new()
    barrel_mesh.size = Vector3(0.34, 0.34, 2.6)
    barrel.mesh = barrel_mesh
    barrel.position = Vector3(0, 1.15, 0)
    barrel.material_override = _mat(Color("#1b1f25"), 0.25, 0.2)
    root.add_child(barrel)
    var grip := MeshInstance3D.new()
    var grip_mesh := BoxMesh.new()
    grip_mesh.size = Vector3(0.38, 0.85, 0.5)
    grip.mesh = grip_mesh
    grip.position = Vector3(0, 0.58, -0.55)
    grip.material_override = _mat(Color("#40352c"), 0.75, 0.0)
    root.add_child(grip)
    root.rotation_degrees = Vector3(-8, 25, 0)
    for child in right.get_children():
        if child is Label or child is Button:
            child.queue_free()
    var name_label := Label.new()
    name_label.text = "🔫 %s" % id
    name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    name_label.add_theme_font_size_override("font_size", 24)
    right.add_child(name_label)
    var spec := Label.new()
    spec.text = "Tur: %s\nO‘q: %d  •  Zarar: %d\nNarxi: %s" % [str(weapon.get("class", "")), int(weapon.get("ammo", 0)), int(weapon.get("damage", 0)), _money(int(weapon.get("price", 0)))]
    spec.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    right.add_child(spec)
    var buy := Button.new()
    buy.custom_minimum_size = Vector2(0, 58)
    var owned := GameServices.owns(PLAYER_ID, "weapon", id)
    buy.text = "✅ TANLASH" if owned else "💰 SOTIB OLISH"
    buy.pressed.connect(_buy_or_select.bind("weapon", id, int(weapon.get("price", 0))))
    right.add_child(buy)

func _buy_or_select(item_type: String, item_id: String, price: int) -> void:
    if GameServices.owns(PLAYER_ID, item_type, item_id):
        GameServices.set_meta("selected_%s" % item_type, selected_item.duplicate(true))
        if modal_title != null:
            modal_title.text = "✅ TANLANDI: %s" % item_id
        return
    var result := GameServices.buy(PLAYER_ID, item_type, item_id, price)
    if bool(result.get("ok", false)):
        GameServices.set_meta("selected_%s" % item_type, selected_item.duplicate(true))
        _refresh_balance()
        if modal_title != null:
            modal_title.text = "✅ SOTIB OLINDI: %s" % item_id
    else:
        if modal_title != null:
            var reason := str(result.get("reason", "unknown"))
            modal_title.text = "❌ %s" % ("PUL YETARLI EMAS" if reason == "insufficient_funds" else reason.to_upper())

func _mat(color: Color, roughness: float, metallic: float = 0.0) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = roughness
    material.metallic = metallic
    return material

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
    note.text = "📱 Bu menyuda PC tugmalari yo‘q. O‘yin mobil boshqaruvga mo‘ljallangan."
    note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    modal_body.add_child(note)

func _show_loading(text: String) -> void:
    _create_modal(text, Vector2(520, 260))
    var label := Label.new()
    label.text = "🌍 Dunyo yuklanmoqda...\n\nAgar sahna ochilsa, mobil joystick va ACTION tugmalari avtomatik chiqadi."
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    modal_body.add_child(label)
    await get_tree().process_frame

func _on_open_world() -> void:
    open_world_pressed.emit()
    await _show_loading("OPEN WORLD")
    var error := get_tree().change_scene_to_file("res://scenes/OpenWorld.tscn")
    if error != OK:
        _create_modal("OPEN WORLD XATOSI", Vector2(650, 300))
        var label := Label.new()
        label.text = "Sahna ochilmadi. Xato kodi: %s" % error
        label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        modal_body.add_child(label)

func _on_multiplayer() -> void:
    multiplayer_pressed.emit()
    await _show_loading("MULTIPLAYER")
    var error := get_tree().change_scene_to_file("res://scenes/OpenWorld.tscn")
    if error != OK:
        _create_modal("MULTIPLAYER XATOSI", Vector2(650, 300))
        var label := Label.new()
        label.text = "Open World sahnasi ochilmadi. Xato kodi: %s" % error
        label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        modal_body.add_child(label)

func _on_quit() -> void:
    quit_pressed.emit()
    get_tree().quit()

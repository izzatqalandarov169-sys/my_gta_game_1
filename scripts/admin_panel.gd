extends Control
class_name AdminPanel

const ADMIN_KEY := "UZB-ADMIN-2026"

var promo_system: PromoCodeSystem
var backend: AuthoritativeBackend
var key_input: LineEdit
var code_input: LineEdit
var expiry_input: LineEdit
var price_input: LineEdit
var reward_type_input: LineEdit
var reward_value_input: LineEdit
var status_label: Label
var list_box: VBoxContainer
var unlocked := false

func _ready() -> void:
    promo_system = GameServices.promos
    backend = GameServices.backend
    _build_ui()

func _build_ui() -> void:
    var root := VBoxContainer.new()
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.add_theme_constant_override("separation", 10)
    root.add_theme_constant_override("margin_left", 30)
    root.add_theme_constant_override("margin_top", 30)
    root.add_theme_constant_override("margin_right", 30)
    root.add_theme_constant_override("margin_bottom", 30)
    add_child(root)

    var title := Label.new()
    title.text = "🇺🇿 ADMIN PANEL — UZB LEGENDS"
    title.add_theme_font_size_override("font_size", 28)
    root.add_child(title)

    var auth := HBoxContainer.new()
    root.add_child(auth)
    key_input = LineEdit.new()
    key_input.placeholder_text = "Admin kaliti"
    key_input.secret = true
    auth.add_child(key_input)
    var login := Button.new()
    login.text = "KIRISH"
    login.pressed.connect(_unlock)
    auth.add_child(login)

    status_label = Label.new()
    root.add_child(status_label)

    var form := GridContainer.new()
    form.columns = 2
    root.add_child(form)
    code_input = _field(form, "Promo kodi")
    expiry_input = _field(form, "Muddat (unix)")
    price_input = _field(form, "Narx (UZS)")
    reward_type_input = _field(form, "Mukofot turi: uzs / vehicle / weapon")
    reward_value_input = _field(form, "Mukofot qiymati")

    var create := Button.new()
    create.text = "PROMO YARATISH"
    create.pressed.connect(_create_promo)
    root.add_child(create)

    var refresh := Button.new()
    refresh.text = "PROMOLAR RO‘YXATI"
    refresh.pressed.connect(_refresh_list)
    root.add_child(refresh)

    list_box = VBoxContainer.new()
    root.add_child(list_box)
    _lock_form(true)

func _field(parent: GridContainer, label_text: String) -> LineEdit:
    var label := Label.new()
    label.text = label_text
    parent.add_child(label)
    var field := LineEdit.new()
    parent.add_child(field)
    return field

func _unlock() -> void:
    if key_input.text == ADMIN_KEY:
        unlocked = true
        _lock_form(false)
        status_label.text = "✅ Admin rejimi ochildi."
    else:
        status_label.text = "❌ Admin kaliti noto‘g‘ri."

func _lock_form(lock: bool) -> void:
    for node in [code_input, expiry_input, price_input, reward_type_input, reward_value_input]:
        node.editable = not lock

func _create_promo() -> void:
    if not unlocked:
        return
    var code := code_input.text.strip_edges().to_upper()
    var expires := int(expiry_input.text)
    var price := int(price_input.text)
    var reward_type := reward_type_input.text.strip_edges().to_lower()
    var reward_value := reward_value_input.text.strip_edges()
    if code.is_empty() or expires <= 0 or price < 0:
        status_label.text = "❌ Kod, muddat va UZS narxini tekshiring."
        return
    if reward_type not in ["uzs", "vehicle", "weapon"] or reward_value.is_empty():
        status_label.text = "❌ Mukofot turi yoki qiymati noto‘g‘ri."
        return
    var reward := {"type": reward_type, "value": reward_value}
    if promo_system.create_promo(code, expires, price, reward):
        status_label.text = "✅ %s promo yaratildi — %s." % [code, _money(price)]
        _refresh_list()
    else:
        status_label.text = "❌ Promo yaratilmadi."

func _refresh_list() -> void:
    if list_box == null:
        return
    for child in list_box.get_children():
        child.queue_free()
    for promo in promo_system.list_promos():
        var row := Label.new()
        row.text = "%s | %s | tugaydi: %s | mukofot: %s" % [promo.get("name", ""), _money(int(promo.get("price_uzs", 0))), str(promo.get("expires_at", "")), str(promo.get("reward", {}))]
        list_box.add_child(row)

func _money(value: int) -> String:
    var text := str(value)
    var result := ""
    while text.length() > 3:
        result = " " + text.substr(text.length() - 3, 3) + result
        text = text.substr(0, text.length() - 3)
    return text + result + " so‘m"

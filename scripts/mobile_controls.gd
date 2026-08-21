extends CanvasLayer
class_name MobileControls

signal move_changed(direction: Vector2)
signal action_pressed(action: String)
signal look_changed(delta: Vector2)

var move_vector := Vector2.ZERO
var joystick_center := Vector2.ZERO
var joystick_radius := 90.0
var joystick_touch := -1
var look_touch := -1
var look_last := Vector2.ZERO
var joystick_base: Control
var joystick_knob: Control
var viewport_size := Vector2.ZERO

func _ready() -> void:
    add_to_group("mobile_controls")
    layer = 20
    viewport_size = get_viewport().get_visible_rect().size
    _build_controls()

func _build_controls() -> void:
    var root := Control.new()
    root.name = "MobileHUD"
    root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(root)

    joystick_center = Vector2(viewport_size.x * 0.16, viewport_size.y * 0.78)
    joystick_radius = minf(viewport_size.x, viewport_size.y) * 0.105
    joystick_base = _make_circle(Color(0.04, 0.05, 0.07, 0.52), joystick_center - Vector2(joystick_radius, joystick_radius), Vector2(joystick_radius * 2.0, joystick_radius * 2.0))
    root.add_child(joystick_base)
    joystick_knob = _make_circle(Color(0.75, 0.82, 0.9, 0.82), joystick_center - Vector2(joystick_radius * 0.46, joystick_radius * 0.46), Vector2(joystick_radius * 0.92, joystick_radius * 0.92))
    root.add_child(joystick_knob)

    _add_button(root, "ENTER", Vector2(viewport_size.x * 0.84, viewport_size.y * 0.72), Vector2(108, 64), "enter")
    _add_button(root, "BRAKE", Vector2(viewport_size.x * 0.84, viewport_size.y * 0.84), Vector2(108, 64), "brake")
    _add_button(root, "FIRE", Vector2(viewport_size.x * 0.93, viewport_size.y * 0.72), Vector2(108, 64), "fire")
    _add_button(root, "JUMP", Vector2(viewport_size.x * 0.93, viewport_size.y * 0.84), Vector2(108, 64), "jump")

func _make_circle(color: Color, pos: Vector2, size: Vector2) -> Control:
    var panel := Panel.new()
    panel.position = pos
    panel.size = size
    panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var style := StyleBoxFlat.new()
    style.bg_color = color
    var radius := int(size.x * 0.5)
    style.corner_radius_top_left = radius
    style.corner_radius_top_right = radius
    style.corner_radius_bottom_left = radius
    style.corner_radius_bottom_right = radius
    panel.add_theme_stylebox_override("panel", style)
    return panel

func _add_button(root: Control, text: String, center: Vector2, size: Vector2, action: String) -> void:
    var button := Button.new()
    button.text = text
    button.position = center - size * 0.5
    button.size = size
    button.add_theme_font_size_override("font_size", 15)
    button.pressed.connect(func(): action_pressed.emit(action))
    root.add_child(button)

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            if event.position.x <= viewport_size.x * 0.38:
                joystick_touch = event.index
                _update_joystick(event.position)
            elif event.position.x >= viewport_size.x * 0.42:
                look_touch = event.index
                look_last = event.position
        else:
            if event.index == joystick_touch:
                joystick_touch = -1
                set_move(Vector2.ZERO)
            if event.index == look_touch:
                look_touch = -1
    elif event is InputEventScreenDrag:
        if event.index == joystick_touch:
            _update_joystick(event.position)
        elif event.index == look_touch:
            var delta := event.position - look_last
            look_last = event.position
            look_changed.emit(delta)

func _update_joystick(position: Vector2) -> void:
    var delta := position - joystick_center
    set_move(delta / joystick_radius)
    if joystick_knob:
        joystick_knob.position = joystick_center + move_vector * joystick_radius * 0.48 - joystick_knob.size * 0.5

func set_move(direction: Vector2) -> void:
    move_vector = direction.limit_length(1.0)
    move_changed.emit(move_vector)

func press_action(action: String) -> void:
    action_pressed.emit(action)

func release_move() -> void:
    set_move(Vector2.ZERO)

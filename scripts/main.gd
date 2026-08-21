extends Node3D

var player: CharacterBody3D
var pivot: Node3D
var camera: Camera3D
var controls: MobileControls
var driving_vehicle: VehicleController
var yaw := 0.0
var pitch := -12.0
var low_end := false
var hud: Label

func _ready() -> void:
    var cores := OS.get_processor_count()
    var screen := DisplayServer.screen_get_size()
    low_end = OS.has_feature("mobile") and (cores <= 6 or screen.x <= 1280)
    Engine.max_fps = 45 if low_end else 60
    Engine.physics_ticks_per_second = 45 if low_end else 60
    _world()
    _player()
    _npcs()
    _cars()
    _hud()
    controls = MobileControls.new()
    add_child(controls)
    controls.look_changed.connect(_look)
    controls.action_pressed.connect(_action)

func _physics_process(delta: float) -> void:
    if player == null or controls == null:
        return
    if driving_vehicle != null:
        player.global_position = driving_vehicle.global_position
        player.visible = false
        _update_hud()
        return

    var input := controls.move_vector
    var dir := Vector3(input.x, 0, input.y)
    if dir.length_squared() > 0.01:
        dir = Basis(Vector3.UP, yaw) * dir.normalized()
        player.velocity.x = dir.x * 5.2
        player.velocity.z = dir.z * 5.2
        player.rotation.y = lerp_angle(player.rotation.y, atan2(-dir.x, -dir.z), 0.18)
    else:
        player.velocity.x = move_toward(player.velocity.x, 0.0, 20.0 * delta)
        player.velocity.z = move_toward(player.velocity.z, 0.0, 20.0 * delta)

    if player.is_on_floor():
        player.velocity.y = -0.2
    else:
        player.velocity.y -= 18.0 * delta
    player.move_and_slide()
    pivot.rotation_degrees = Vector3(pitch, yaw, 0)
    _update_hud()

func _world() -> void:
    var env := WorldEnvironment.new()
    var e := Environment.new()
    e.background_mode = Environment.BG_SKY
    var sky := Sky.new()
    var sm := ProceduralSkyMaterial.new()
    sm.sky_top_color = Color("#16365c")
    sm.sky_horizon_color = Color("#b8d8ea")
    sm.ground_bottom_color = Color("#101611")
    sm.ground_horizon_color = Color("#667060")
    sky.sky_material = sm
    e.sky = sky
    e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
    e.ambient_light_energy = 0.9
    e.tonemap_mode = Environment.TONE_MAPPER_ACES
    e.fog_enabled = true
    e.fog_density = 0.006 if low_end else 0.003
    env.environment = e
    add_child(env)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-55, -30, 0)
    sun.light_energy = 1.2
    sun.shadow_enabled = not low_end
    sun.directional_shadow_max_distance = 70.0 if low_end else 120.0
    add_child(sun)

    _box(Vector3(800, 1, 800), Vector3(0, -0.5, 0), _mat(Color("#52604c"), 0.95), true)

    var road := _mat(Color("#24282b"), 0.88)
    var line := _mat(Color("#d9cf92"), 0.55)
    for i in range(-6, 7):
        var p := float(i) * 48.0
        _box(Vector3(13, 0.08, 800), Vector3(p, 0, 0), road)
        _box(Vector3(800, 0.08, 13), Vector3(0, 0, p), road)
        _box(Vector3(0.12, 0.09, 800), Vector3(p, 0.06, 0), line)
        _box(Vector3(800, 0.09, 0.12), Vector3(0, 0.06, p), line)

    var limit := 4 if low_end else 6
    for x in range(-limit, limit + 1):
        for z in range(-limit, limit + 1):
            if abs(x) % 2 == 0 and abs(z) % 2 == 0:
                _building(Vector3(x * 48 + 18, 0, z * 48 + 18))

func _building(pos: Vector3) -> void:
    var size := Vector3(randf_range(9.0, 14.0), randf_range(8.0, 30.0), randf_range(9.0, 14.0))
    var color := Color.from_hsv(randf_range(0.53, 0.62), 0.12, randf_range(0.32, 0.56))
    _box(size, pos + Vector3(0, size.y * 0.5, 0), _mat(color, 0.72), true)

func _player() -> void:
    player = CharacterBody3D.new()
    player.name = "Player"

    var shape := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.height = 1.8
    capsule.radius = 0.34
    shape.shape = capsule
    shape.position.y = 0.9
    player.add_child(shape)

    _human(player, Color("#204c82"))
    player.position = Vector3(0, 0, 12)
    add_child(player)

    pivot = Node3D.new()
    pivot.position = Vector3(0, 1.45, 0)
    player.add_child(pivot)

    camera = Camera3D.new()
    camera.position = Vector3(0, 3.8, 7.2)
    camera.rotation_degrees = Vector3(0, 180, 0)
    camera.fov = 66
    camera.current = true
    pivot.add_child(camera)

func _human(root: Node3D, shirt_color: Color) -> void:
    _primitive(root, CapsuleMesh.new(), Vector3(0, 1.05, 0), 1.0, 0.33, shirt_color)
    _primitive(root, SphereMesh.new(), Vector3(0, 1.85, 0), 0.58, 0.29, Color("#c98e69"))
    _limb(root, Vector3(-0.42, 1.05, 0), 0.62, 0.11, shirt_color)
    _limb(root, Vector3(0.42, 1.05, 0), 0.62, 0.11, shirt_color)
    _limb(root, Vector3(-0.18, 0.38, 0), 0.78, 0.13, Color("#20252b"))
    _limb(root, Vector3(0.18, 0.38, 0), 0.78, 0.13, Color("#20252b"))

func _primitive(root: Node3D, mesh: PrimitiveMesh, pos: Vector3, height: float, radius: float, color: Color) -> void:
    if mesh is CapsuleMesh:
        mesh.height = height
        mesh.radius = radius
    elif mesh is SphereMesh:
        mesh.height = height
        mesh.radius = radius
    var node := MeshInstance3D.new()
    node.mesh = mesh
    node.position = pos
    node.material_override = _mat(color, 0.7)
    root.add_child(node)

func _limb(root: Node3D, pos: Vector3, height: float, radius: float, color: Color) -> void:
    var mesh := CylinderMesh.new()
    mesh.height = height
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.radial_segments = 8
    _primitive(root, mesh, pos, height, radius, color)

func _npcs() -> void:
    var count := 10 if low_end else 20
    for i in range(count):
        var npc := SmartNPC.new()
        npc.name = "Citizen_%02d" % i
        npc.add_to_group("npc")
        npc.position = Vector3(randf_range(-130, 130), 0, randf_range(-130, 130))
        npc.setup(["calm", "clever", "brave", "fearful"][i % 4], float(i % 8) / 10.0, 0.6, i % 5 == 0)
        add_child(npc)
        _human(npc, Color.from_hsv(float(i % 8) / 8.0, 0.55, 0.75))

        var collision := CollisionShape3D.new()
        var capsule := CapsuleShape3D.new()
        capsule.height = 1.7
        capsule.radius = 0.3
        collision.shape = capsule
        collision.position.y = 0.85
        npc.add_child(collision)

func _cars() -> void:
    var count := 5 if low_end else 10
    for i in range(count):
        var car := VehicleController.new()
        car.name = "Car_%02d" % i
        car.add_to_group("vehicle")
        car.position = Vector3(randf_range(-110, 110), 0, randf_range(-110, 110))
        car.max_speed = 45.0 + float(i % 5) * 5.0
        add_child(car)

        _box(Vector3(2, 0.65, 4.1), Vector3(0, 0.55, 0), _mat(Color.from_hsv(float(i % 10) / 10.0, 0.7, 0.82), 0.38), false, car)
        _box(Vector3(1.55, 0.58, 1.9), Vector3(0, 1.02, 0.15), _mat(Color("#17232d"), 0.25), false, car)

        var collision := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = Vector3(2, 0.9, 4.1)
        collision.shape = shape
        collision.position.y = 0.55
        car.add_child(collision)

func _box(size: Vector3, pos: Vector3, material: Material, collision := false, parent: Node = null) -> void:
    var target: Node = self if parent == null else parent
    var node := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    node.mesh = mesh
    node.position = pos
    node.material_override = material
    target.add_child(node)
    if collision:
        var shape_node := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = size
        shape_node.shape = shape
        shape_node.position = pos
        target.add_child(shape_node)

func _mat(color: Color, roughness: float) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = roughness
    return material

func _hud() -> void:
    var layer := CanvasLayer.new()
    layer.layer = 10
    var panel := ColorRect.new()
    panel.position = Vector2(16, 16)
    panel.size = Vector2(390, 82)
    panel.color = Color(0.02, 0.03, 0.05, 0.75)
    layer.add_child(panel)
    hud = Label.new()
    hud.position = Vector2(28, 24)
    hud.add_theme_font_size_override("font_size", 18)
    layer.add_child(hud)
    add_child(layer)
    _update_hud()

func _update_hud() -> void:
    if hud == null:
        return
    var mode := "HAYDOVCHI" if driving_vehicle != null else "PIYODA"
    var speed := 0
    if driving_vehicle != null:
        speed = int(driving_vehicle.get_speed_kmh())
    hud.text = "UZBEK LEGENDS | 1000 so‘m | WANTED 0\n%02d AI NPC | %02d AVTO | %s %d km/soat" % [get_tree().get_nodes_in_group("npc").size(), get_tree().get_nodes_in_group("vehicle").size(), mode, speed]

func _look(delta: Vector2) -> void:
    yaw -= delta.x * 0.18
    pitch = clampf(pitch - delta.y * 0.12, -42.0, 16.0)

func _action(action: String) -> void:
    if action == "enter":
        _toggle_vehicle()
    elif action == "brake" and driving_vehicle != null:
        driving_vehicle.mobile_brake = true
    elif action == "jump" and driving_vehicle == null and player.is_on_floor():
        player.velocity.y = 7.0
    elif action == "fire":
        hud.text = "🔫 QUROL TAYYOR • AI/NPC faol"

func _toggle_vehicle() -> void:
    if driving_vehicle != null:
        var exit_pos := driving_vehicle.global_position + driving_vehicle.global_transform.basis.x * 2.6
        driving_vehicle.set_driver_active(false)
        driving_vehicle = null
        player.visible = true
        player.global_position = exit_pos
        return

    var nearest: VehicleController
    var best := 5.0
    for node in get_tree().get_nodes_in_group("vehicle"):
        var distance := player.global_position.distance_to(node.global_position)
        if distance < best:
            best = distance
            nearest = node
    if nearest == null:
        hud.text = "Yaqin atrofda mashina yo‘q"
        return
    driving_vehicle = nearest
    driving_vehicle.set_driver_active(true)
    player.visible = false

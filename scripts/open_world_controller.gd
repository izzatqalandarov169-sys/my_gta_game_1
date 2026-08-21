extends Node3D

var player: PlayerController
var pivot: Node3D
var camera: Camera3D
var controls: MobileControls
var driving_vehicle: VehicleController
var yaw := 0.0
var pitch := -12.0
var low_end := false
var hud: Label
var weapon_cooldown := 0.0
var wanted := 0

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
    _city_details()
    _hud()
    controls = MobileControls.new()
    controls.add_to_group("mobile_controls")
    add_child(controls)
    controls.look_changed.connect(_look)
    controls.action_pressed.connect(_action)

func _physics_process(delta: float) -> void:
    weapon_cooldown = maxf(0.0, weapon_cooldown - delta)
    if player == null or controls == null:
        return
    if driving_vehicle != null:
        player.global_position = driving_vehicle.global_position
        player.visible = false
        _update_hud()
        return
    player.visible = true
    player.set_move_input(controls.move_vector)
    player.set_camera_yaw(yaw)
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

func _city_details() -> void:
    var limit := 4 if low_end else 6
    for x in range(-limit, limit + 1):
        for z in range(-limit, limit + 1):
            if (abs(x) + abs(z)) % 3 == 0:
                var p := Vector3(x * 48.0 + 10.0, 0, z * 48.0 + 10.0)
                _lamp(p)
            if (x + z) % 4 == 0:
                _tree(Vector3(x * 48.0 + 5.0, 0, z * 48.0 + 5.0))

func _lamp(pos: Vector3) -> void:
    _box(Vector3(0.12, 4.0, 0.12), pos + Vector3(0, 2, 0), _mat(Color("#25292b"), 0.5), false)
    var light := OmniLight3D.new()
    light.position = pos + Vector3(0, 4.0, 0)
    light.light_energy = 0.5 if low_end else 0.8
    light.omni_range = 7.0 if low_end else 10.0
    light.light_color = Color("#ffdca0")
    add_child(light)

func _tree(pos: Vector3) -> void:
    _box(Vector3(0.35, 2.0, 0.35), pos + Vector3(0, 1, 0), _mat(Color("#493425"), 0.9), false)
    var crown := SphereMesh.new()
    crown.radius = 1.3
    crown.height = 2.6
    _primitive_named(self, "TreeCrown", crown, pos + Vector3(0, 2.7, 0), _mat(Color("#315b32"), 0.95))

func _player() -> void:
    player = PlayerController.new()
    player.name = "Player"
    var shape := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.height = 1.8
    capsule.radius = 0.34
    shape.shape = capsule
    shape.position.y = 0.9
    player.add_child(shape)
    _human(player, Color("#204c82"))
    _add_player_weapon()
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

func _add_player_weapon() -> void:
    var gun := MeshInstance3D.new()
    gun.name = "MobileRifle"
    var mesh := BoxMesh.new()
    mesh.size = Vector3(0.12, 0.16, 0.75)
    gun.mesh = mesh
    gun.position = Vector3(0.52, 1.12, -0.38)
    gun.rotation_degrees = Vector3(0, 0, -8)
    gun.material_override = _mat(Color("#16191d"), 0.35)
    player.add_child(gun)

func _human(root: Node3D, shirt_color: Color) -> void:
    var body := CapsuleMesh.new()
    body.height = 1.0
    body.radius = 0.33
    _primitive_named(root, "Body", body, Vector3(0, 1.05, 0), _mat(shirt_color, 0.7))
    var head := SphereMesh.new()
    head.height = 0.58
    head.radius = 0.29
    _primitive_named(root, "Head", head, Vector3(0, 1.85, 0), _mat(Color("#c98e69"), 0.62))
    _limb_named(root, "LeftArm", Vector3(-0.42, 1.05, 0), 0.62, 0.11, shirt_color)
    _limb_named(root, "RightArm", Vector3(0.42, 1.05, 0), 0.62, 0.11, shirt_color)
    _limb_named(root, "LeftLeg", Vector3(-0.18, 0.38, 0), 0.78, 0.13, Color("#20252b"))
    _limb_named(root, "RightLeg", Vector3(0.18, 0.38, 0), 0.78, 0.13, Color("#20252b"))

func _primitive_named(root: Node3D, name: String, mesh: PrimitiveMesh, pos: Vector3, material: Material) -> void:
    var node := MeshInstance3D.new()
    node.name = name
    node.mesh = mesh
    node.position = pos
    node.material_override = material
    root.add_child(node)

func _limb_named(root: Node3D, name: String, pos: Vector3, height: float, radius: float, color: Color) -> void:
    var mesh := CylinderMesh.new()
    mesh.height = height
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.radial_segments = 8
    _primitive_named(root, name, mesh, pos, _mat(color, 0.7))

func _npcs() -> void:
    var count := 10 if low_end else 20
    for i in range(count):
        var npc := SmartNPC.new()
        npc.name = "Citizen_%02d" % i
        npc.add_to_group("npc")
        npc.position = Vector3(randf_range(-130, 130), 0, randf_range(-130, 130))
        npc.setup(["calm", "clever", "brave", "fearful"][i % 4], float(i % 8) / 10.0, 0.6, i % 3 == 0)
        add_child(npc)
        _human(npc, Color.from_hsv(float(i % 8) / 8.0, 0.55, 0.75))
        var collision := CollisionShape3D.new()
        var capsule := CapsuleShape3D.new()
        capsule.height = 1.7
        capsule.radius = 0.3
        collision.shape = capsule
        collision.position.y = 0.85
        npc.add_child(collision)
        if npc.weapon_capable:
            _add_npc_weapon(npc)
        npc.npc_action.connect(_on_npc_action.bind(npc))

func _add_npc_weapon(npc: SmartNPC) -> void:
    var gun := MeshInstance3D.new()
    gun.name = "NPCWeapon"
    var mesh := BoxMesh.new()
    mesh.size = Vector3(0.1, 0.13, 0.6)
    gun.mesh = mesh
    gun.position = Vector3(0.38, 1.12, -0.34)
    gun.material_override = _mat(Color("#111318"), 0.3)
    npc.add_child(gun)

func _on_npc_action(action: String, npc: SmartNPC) -> void:
    if action == "combat":
        npc.current_action = "jangovar"
    elif action == "fire":
        _draw_tracer(npc.global_position + Vector3.UP * 1.2, npc.target.global_position + Vector3.UP * 1.0)

func _cars() -> void:
    var count := 5 if low_end else 10
    for i in range(count):
        var car := VehicleController.new()
        car.name = "Car_%02d" % i
        car.add_to_group("vehicle")
        car.position = Vector3(randf_range(-110, 110), 0, randf_range(-110, 110))
        car.max_speed = 45.0 + float(i % 5) * 5.0
        add_child(car)
        var paint := _mat(Color.from_hsv(float(i % 10) / 10.0, 0.7, 0.82), 0.28)
        _box(Vector3(2.05, 0.65, 4.2), Vector3(0, 0.55, 0), paint, false, car)
        _box(Vector3(1.55, 0.58, 1.9), Vector3(0, 1.02, 0.15), _mat(Color("#17232d"), 0.2), false, car)
        _car_wheel(car, Vector3(-1.0, 0.38, -1.35))
        _car_wheel(car, Vector3(1.0, 0.38, -1.35))
        _car_wheel(car, Vector3(-1.0, 0.38, 1.35))
        _car_wheel(car, Vector3(1.0, 0.38, 1.35))
        _car_light(car, Vector3(-0.62, 0.65, -2.1), Color("#f8f4d0"))
        _car_light(car, Vector3(0.62, 0.65, -2.1), Color("#f8f4d0"))
        var collision := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = Vector3(2.05, 0.9, 4.2)
        collision.shape = shape
        collision.position.y = 0.55
        car.add_child(collision)

func _car_wheel(car: Node3D, pos: Vector3) -> void:
    var wheel := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.38
    mesh.bottom_radius = 0.38
    mesh.height = 0.24
    mesh.radial_segments = 12
    wheel.mesh = mesh
    wheel.position = pos
    wheel.rotation_degrees = Vector3(90, 0, 0)
    wheel.material_override = _mat(Color("#101216"), 0.85)
    car.add_child(wheel)

func _car_light(car: Node3D, pos: Vector3, color: Color) -> void:
    var lamp := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = Vector3(0.34, 0.18, 0.08)
    lamp.mesh = mesh
    lamp.position = pos
    lamp.material_override = _mat(color, 0.18)
    car.add_child(lamp)

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
    hud.text = "UZBEK LEGENDS | SO‘M | WANTED %d\n%02d AI NPC | %02d AVTO | %s %d km/soat" % [wanted, get_tree().get_nodes_in_group("npc").size(), get_tree().get_nodes_in_group("vehicle").size(), mode, speed]

func _look(delta: Vector2) -> void:
    yaw -= delta.x * 0.18
    pitch = clampf(pitch - delta.y * 0.12, -42.0, 16.0)

func _action(action: String) -> void:
    if action == "enter":
        _toggle_vehicle()
    elif action == "brake" and driving_vehicle != null:
        driving_vehicle.mobile_brake = true
    elif action == "jump" and driving_vehicle == null:
        player.jump()
    elif action == "fire" and driving_vehicle == null:
        _fire_weapon()

func _fire_weapon() -> void:
    if weapon_cooldown > 0.0 or player == null or camera == null:
        return
    weapon_cooldown = 0.22
    wanted = mini(wanted + 1, 5)
    var origin := camera.global_position
    var direction := -camera.global_transform.basis.z
    var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * 120.0)
    query.exclude = [player]
    var hit := get_world_3d().direct_space_state.intersect_ray(query)
    var end_point := origin + direction * 120.0
    if not hit.is_empty():
        end_point = hit["position"]
        var target := hit["collider"]
        if target is SmartNPC:
            target.take_damage(35.0)
        else:
            var parent := target.get_parent()
            if parent is SmartNPC:
                parent.take_damage(35.0)
    _draw_tracer(origin, end_point)
    for node in get_tree().get_nodes_in_group("npc"):
        var npc := node as SmartNPC
        if npc != null and npc.global_position.distance_to(player.global_position) < 55.0:
            npc.react_to_crime(player)
    hud.text = "🔫 O‘Q UZILDI • NPC LAR REAKSIYA QILMOQDA"

func _draw_tracer(from: Vector3, to: Vector3) -> void:
    var line := ImmediateMesh.new()
    line.surface_begin(Mesh.PRIMITIVE_LINES)
    line.surface_set_color(Color("#ffd86b"))
    line.surface_add_vertex(from)
    line.surface_add_vertex(to)
    line.surface_end()
    var mesh_instance := MeshInstance3D.new()
    mesh_instance.mesh = line
    add_child(mesh_instance)
    get_tree().create_timer(0.045).timeout.connect(mesh_instance.queue_free)

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

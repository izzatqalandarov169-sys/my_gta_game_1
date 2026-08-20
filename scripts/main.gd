extends Node3D

var player: CharacterBody3D
var speed := 7.0
var sprint_speed := 11.0
var gravity := 18.0
var money := 1000
var wanted := 0
var spawn_manager: SpawnManager
var driving_vehicle: VehicleController
var interact_was_down := false
var hud_label: Label
var status_label: Label

func _ready() -> void:
    randomize()
    _build_world()
    _spawn_player()
    spawn_manager = SpawnManager.new()
    add_child(spawn_manager)
    spawn_manager.initialize(self, player)
    _build_ui()

func _physics_process(delta: float) -> void:
    if player == null:
        return

    var interact_down := Input.is_key_pressed(KEY_E)
    if interact_down and not interact_was_down:
        _toggle_nearest_vehicle()
    interact_was_down = interact_down

    if driving_vehicle != null:
        player.global_position = driving_vehicle.global_position
        player.rotation.y = driving_vehicle.rotation.y
        _update_hud()
        return

    var input_vec := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var dir := Vector3(input_vec.x, 0, input_vec.y)
    if dir.length() > 0.0:
        dir = dir.normalized()

    var current_speed := sprint_speed if Input.is_key_pressed(KEY_SHIFT) else speed
    player.velocity.x = dir.x * current_speed
    player.velocity.z = dir.z * current_speed
    if not player.is_on_floor():
        player.velocity.y -= gravity * delta
    else:
        player.velocity.y = -0.2
    player.move_and_slide()
    _update_hud()

func _build_world() -> void:
    var env := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color(0.06, 0.10, 0.16)
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color(0.65, 0.7, 0.8)
    environment.ambient_light_energy = 0.8
    env.environment = environment
    add_child(env)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-55, -25, 0)
    sun.light_energy = 1.2
    add_child(sun)

    var ground := StaticBody3D.new()
    ground.name = "OpenWorldGround"
    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = Vector3(800, 1, 800)
    mesh.mesh = box
    mesh.position.y = -0.5
    ground.add_child(mesh)
    var shape := CollisionShape3D.new()
    var collision := BoxShape3D.new()
    collision.size = Vector3(800, 1, 800)
    shape.shape = collision
    shape.position.y = -0.5
    ground.add_child(shape)
    add_child(ground)

    for x in range(-20, 21):
        for z in range(-20, 21):
            if abs(x) % 2 == 0 and abs(z) % 2 == 0:
                _spawn_building(Vector3(x * 18, 0, z * 18))

func _spawn_building(pos: Vector3) -> void:
    var body := StaticBody3D.new()
    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = Vector3(8, randf_range(5, 24), 8)
    mesh.mesh = box
    mesh.position.y = box.size.y / 2.0
    body.add_child(mesh)
    var shape := CollisionShape3D.new()
    var collision := BoxShape3D.new()
    collision.size = box.size
    shape.shape = collision
    shape.position.y = box.size.y / 2.0
    body.add_child(shape)
    body.position = pos
    add_child(body)

func _spawn_player() -> void:
    player = CharacterBody3D.new()
    player.name = "Player"
    var mesh := MeshInstance3D.new()
    var capsule := CapsuleMesh.new()
    capsule.height = 1.8
    capsule.radius = 0.35
    mesh.mesh = capsule
    mesh.position.y = 0.9
    player.add_child(mesh)
    var shape := CollisionShape3D.new()
    var capsule_shape := CapsuleShape3D.new()
    capsule_shape.height = 1.8
    capsule_shape.radius = 0.35
    shape.shape = capsule_shape
    shape.position.y = 0.9
    player.add_child(shape)
    player.position = Vector3(0, 0, 8)
    add_child(player)

    var camera := Camera3D.new()
    camera.name = "ThirdPersonCamera"
    camera.position = Vector3(0, 5.5, 8)
    camera.look_at_from_position(camera.position, player.position + Vector3(0, 1, 0))
    player.add_child(camera)

func _build_ui() -> void:
    var ui := CanvasLayer.new()
    var panel := ColorRect.new()
    panel.color = Color(0.02, 0.03, 0.05, 0.78)
    panel.position = Vector2(18, 18)
    panel.size = Vector2(440, 128)
    ui.add_child(panel)

    hud_label = Label.new()
    hud_label.position = Vector2(32, 28)
    hud_label.add_theme_font_size_override("font_size", 21)
    ui.add_child(hud_label)

    status_label = Label.new()
    status_label.position = Vector2(32, 102)
    status_label.add_theme_font_size_override("font_size", 16)
    ui.add_child(status_label)
    add_child(ui)
    _update_hud()

func _update_hud() -> void:
    if hud_label == null:
        return
    var npc_count := spawn_manager.get_npc_count() if spawn_manager else 0
    var vehicle_count := spawn_manager.get_vehicle_count() if spawn_manager else 0
    var mode := "PIYODA"
    var speed_text := ""
    if driving_vehicle != null:
        mode = "HAYDOVCHI"
        speed_text = " | %d km/soat" % int(driving_vehicle.get_speed_kmh())
    hud_label.text = "UZBEK LEGENDS | $%d | WANTED %d\nNPC %d/%d | AVTO %d | %s%s" % [money, wanted, npc_count, 1000, vehicle_count, mode, speed_text]
    status_label.text = "WASD yurish | SHIFT yugurish | E mashinaga kirish/chiqish | SPACE tormoz"

func _toggle_nearest_vehicle() -> void:
    if driving_vehicle != null:
        var exit_position := driving_vehicle.global_position + driving_vehicle.global_transform.basis.x * 2.5
        driving_vehicle.set_driver_active(false)
        driving_vehicle = null
        player.visible = true
        player.global_position = exit_position
        return

    if spawn_manager == null or spawn_manager.vehicle_parent == null:
        return

    var nearest: VehicleController
    var nearest_distance := 4.5
    for node in spawn_manager.vehicle_parent.get_children():
        if node is VehicleController:
            var distance := player.global_position.distance_to(node.global_position)
            if distance < nearest_distance:
                nearest_distance = distance
                nearest = node

    if nearest == null:
        return

    driving_vehicle = nearest
    driving_vehicle.set_driver_active(true)
    player.visible = false
    player.global_position = driving_vehicle.global_position

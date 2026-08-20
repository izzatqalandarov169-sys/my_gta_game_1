extends Node3D

var player: CharacterBody3D
var speed := 7.0
var gravity := 18.0
var money := 1000
var wanted := 0
var spawn_manager: SpawnManager

func _ready():
    _build_world()
    _spawn_player()
    spawn_manager = SpawnManager.new()
    add_child(spawn_manager)
    spawn_manager.initialize(self, player)
    _build_ui()

func _physics_process(delta):
    if player == null:
        return
    var input_vec = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
    var dir = Vector3(input_vec.x, 0, input_vec.y)
    if dir.length() > 0:
        dir = dir.normalized()
    player.velocity.x = dir.x * speed
    player.velocity.z = dir.z * speed
    if not player.is_on_floor():
        player.velocity.y -= gravity * delta
    else:
        player.velocity.y = -0.2
    player.move_and_slide()

func _build_world():
    var env = WorldEnvironment.new()
    var environment = Environment.new()
    environment.background_mode = Environment.BG_COLOR
    environment.background_color = Color(0.08, 0.12, 0.18)
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color(0.65, 0.7, 0.8)
    environment.ambient_light_energy = 0.8
    env.environment = environment
    add_child(env)

    var sun = DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-55, -25, 0)
    sun.light_energy = 1.2
    add_child(sun)

    # Large open-world foundation: 800 x 800 meters.
    var ground = StaticBody3D.new()
    ground.name = "OpenWorldGround"
    var mesh = MeshInstance3D.new()
    var box = BoxMesh.new()
    box.size = Vector3(800, 1, 800)
    mesh.mesh = box
    mesh.position.y = -0.5
    ground.add_child(mesh)
    var shape = CollisionShape3D.new()
    var collision = BoxShape3D.new()
    collision.size = Vector3(800, 1, 800)
    shape.shape = collision
    shape.position.y = -0.5
    ground.add_child(shape)
    add_child(ground)

    # Procedural city blocks across the open world.
    for x in range(-20, 21):
        for z in range(-20, 21):
            if abs(x) % 2 == 0 and abs(z) % 2 == 0:
                _spawn_building(Vector3(x * 18, 0, z * 18))

func _spawn_building(pos: Vector3):
    var body = StaticBody3D.new()
    var mesh = MeshInstance3D.new()
    var box = BoxMesh.new()
    box.size = Vector3(8, randf_range(5, 24), 8)
    mesh.mesh = box
    mesh.position.y = box.size.y / 2.0
    body.add_child(mesh)
    var shape = CollisionShape3D.new()
    var collision = BoxShape3D.new()
    collision.size = box.size
    shape.shape = collision
    shape.position.y = box.size.y / 2.0
    body.add_child(shape)
    body.position = pos
    add_child(body)

func _spawn_player():
    player = CharacterBody3D.new()
    player.name = "Player"
    var mesh = MeshInstance3D.new()
    var capsule = CapsuleMesh.new()
    capsule.height = 1.8
    capsule.radius = 0.35
    mesh.mesh = capsule
    mesh.position.y = 0.9
    player.add_child(mesh)
    var shape = CollisionShape3D.new()
    var capsule_shape = CapsuleShape3D.new()
    capsule_shape.height = 1.8
    capsule_shape.radius = 0.35
    shape.shape = capsule_shape
    shape.position.y = 0.9
    player.add_child(shape)
    player.position = Vector3(0, 0, 8)
    add_child(player)

    var camera = Camera3D.new()
    camera.position = Vector3(0, 5.5, 8)
    camera.look_at_from_position(camera.position, player.position + Vector3(0, 1, 0))
    player.add_child(camera)

func _build_ui():
    var ui = CanvasLayer.new()
    var label = Label.new()
    label.text = "UZBEKISTAN GALAXY | OPEN WORLD\n$ %d    WANTED: %d\nNPC: 1000    VEHICLES: 80\nWASD — yurish" % [money, wanted]
    label.position = Vector2(25, 25)
    label.add_theme_font_size_override("font_size", 22)
    ui.add_child(label)
    add_child(ui)

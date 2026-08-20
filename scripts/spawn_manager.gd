extends Node3D
class_name SpawnManager

@export var npc_target_count := 120
@export var npc_spawn_radius := 75.0
@export var vehicle_target_count := 30

var npc_count := 0
var vehicle_count := 0
var player: Node3D
var npc_parent: Node3D
var vehicle_parent: Node3D

func configure_for_device(low_end: bool) -> void:
    if low_end:
        npc_target_count = 45
        vehicle_target_count = 14
        npc_spawn_radius = 55.0
    else:
        npc_target_count = 120
        vehicle_target_count = 30
        npc_spawn_radius = 75.0

func initialize(world: Node3D, player_node: Node3D) -> void:
    player = player_node
    npc_parent = Node3D.new()
    npc_parent.name = "NPCs_Active"
    world.add_child(npc_parent)
    vehicle_parent = Node3D.new()
    vehicle_parent.name = "Vehicles"
    world.add_child(vehicle_parent)
    _spawn_initial_npcs()
    _spawn_initial_vehicles()

func _spawn_initial_npcs() -> void:
    for i in range(npc_target_count):
        _spawn_npc(i)

func _spawn_npc(index: int) -> void:
    var npc := SmartNPC.new()
    npc.name = "NPC_%04d" % index
    npc.position = _random_spawn_position()
    npc.setup(
        ["calm", "angry", "clever", "fearful", "brave"][index % 5],
        float(index % 10) / 10.0,
        0.35 + float(index % 6) * 0.1,
        index % 5 == 0
    )
    npc.set_meta("npc_id", index)
    npc.set_meta("population_simulated", 1000)

    var mesh := MeshInstance3D.new()
    var capsule := CapsuleMesh.new()
    capsule.height = 1.7
    capsule.radius = 0.3
    mesh.mesh = capsule
    mesh.position.y = 0.85
    npc.add_child(mesh)

    var collision := CollisionShape3D.new()
    var capsule_shape := CapsuleShape3D.new()
    capsule_shape.height = 1.7
    capsule_shape.radius = 0.3
    collision.shape = capsule_shape
    collision.position.y = 0.85
    npc.add_child(collision)
    npc_parent.add_child(npc)
    npc_count += 1

func _spawn_initial_vehicles() -> void:
    for i in range(vehicle_target_count):
        _spawn_vehicle(i)

func _spawn_vehicle(index: int) -> void:
    var vehicle := VehicleController.new()
    vehicle.name = "Vehicle_%03d" % index
    vehicle.position = _random_spawn_position()
    vehicle.max_speed = 45.0 + float(index % 8) * 4.0
    vehicle.set_meta("vehicle_id", index)
    vehicle.set_meta("type", "moto" if index % 6 == 0 else "car")

    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = Vector3(1.8, 0.7, 3.8)
    mesh.mesh = box
    mesh.position.y = 0.5
    var material := StandardMaterial3D.new()
    material.albedo_color = Color.from_hsv(float(index % 12) / 12.0, 0.55, 0.78)
    material.metallic = 0.15
    material.roughness = 0.42
    mesh.material_override = material
    vehicle.add_child(mesh)

    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = box.size
    shape.position.y = 0.5
    collision.shape = shape
    vehicle.add_child(collision)
    vehicle_parent.add_child(vehicle)
    vehicle_count += 1

func _random_spawn_position() -> Vector3:
    var angle := randf() * TAU
    var radius := sqrt(randf()) * npc_spawn_radius
    return Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)

func get_npc_count() -> int:
    return npc_count

func get_vehicle_count() -> int:
    return vehicle_count

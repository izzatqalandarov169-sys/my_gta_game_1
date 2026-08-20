extends Node3D
class_name VehicleSystem

var vehicles: Array[Dictionary] = []
var vehicle_catalog := [
    {"name":"UzAuto Classic","type":"sedan","price":12000.0,"speed":150.0},
    {"name":"UzAuto Sport","type":"sport","price":28000.0,"speed":220.0},
    {"name":"UzAuto SUV","type":"suv","price":36000.0,"speed":190.0},
    {"name":"Galaxy X","type":"galaxy","price":250000.0,"speed":420.0},
    {"name":"Night Rider","type":"super","price":500000.0,"speed":380.0}
]

func spawn_vehicle(model: Dictionary, pos: Vector3) -> Node3D:
    var body := CharacterBody3D.new()
    body.name = str(model.name).replace(" ", "_")
    body.position = pos
    body.set_meta("price", model.price)
    body.set_meta("max_speed", model.speed)
    body.set_meta("vehicle_type", model.type)
    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = Vector3(2.0, 0.8, 4.2)
    mesh.mesh = box
    mesh.position.y = 0.65
    body.add_child(mesh)
    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = box.size
    shape.position.y = 0.65
    collision.shape = shape
    body.add_child(collision)
    add_child(body)
    vehicles.append(model)
    return body

func get_catalog() -> Array[Dictionary]:
    return vehicle_catalog.duplicate(true)

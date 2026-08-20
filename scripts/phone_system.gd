extends Node
class_name PhoneSystem

signal call_started(number: String, service: String)
signal call_finished()
signal location_found(position: Vector3)

const EMERGENCY_SERVICES := {
    "101": "Yong‘in xizmati",
    "102": "Politsiya",
    "103": "Tez tibbiy yordam"
}

var phone_open := false
var current_model := "Android"
var current_number := ""
var player: Node3D
var world_services: Dictionary = {}

var android_models := ["Galaxy S", "Galaxy Note", "Galaxy A", "Pixel", "Xperia", "Redmi", "OnePlus", "Nothing Phone"]
var ios_models := ["iPhone", "iPhone Pro", "iPhone Pro Max", "iPhone Plus", "iPhone SE"]

func initialize(player_node: Node3D) -> void:
    player = player_node

func set_phone_model(model: String) -> void:
    current_model = model

func get_android_models() -> Array[String]:
    return android_models

func get_ios_models() -> Array[String]:
    return ios_models

func call_number(number: String) -> bool:
    if not EMERGENCY_SERVICES.has(number):
        return false
    current_number = number
    call_started.emit(number, EMERGENCY_SERVICES[number])
    _find_nearest_service(EMERGENCY_SERVICES[number])
    return true

func _find_nearest_service(service: String) -> void:
    if player == null:
        return
    var best_position := player.global_position
    var best_distance := INF
    for key in world_services:
        if world_services[key]["type"] == service:
            var p: Vector3 = world_services[key]["position"]
            var d := player.global_position.distance_squared_to(p)
            if d < best_distance:
                best_distance = d
                best_position = p
    location_found.emit(best_position)

func register_service_location(service: String, position: Vector3) -> void:
    world_services[str(world_services.size())] = {"type": service, "position": position}

func end_call() -> void:
    current_number = ""
    call_finished.emit()

extends Node
class_name PoliceVehicleCatalog

var vehicles: Array[Dictionary] = []

func _ready() -> void:
    var names := [
        "Police Sedan", "Police SUV", "Police Interceptor", "Highway Patrol", "Traffic Unit",
        "Rapid Response", "Police Sport", "Police Wagon", "Police Van", "Police Pickup",
        "Tactical SUV", "Command SUV", "Detective Sedan", "Undercover Sport", "K9 Unit",
        "Prison Transport", "Riot Control Van", "Highway SUV", "Motor Unit", "Patrol Classic",
        "Emergency Response", "Special Response", "Airport Police", "City Patrol", "Rural Patrol"
    ]
    for i in range(names.size()):
        vehicles.append({
            "id": i,
            "name": names[i],
            "type": "police",
            "max_speed": 150.0 + i * 4.0,
            "price": 45000 + i * 7000,
            "emergency_lights": true,
            "siren": true
        })

func get_catalog() -> Array[Dictionary]:
    return vehicles.duplicate(true)

func get_count() -> int:
    return vehicles.size()

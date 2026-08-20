extends Node3D
class_name CitySystem

var locations: Array[Dictionary] = []
var location_types := ["house", "shop", "business", "hospital", "police", "garage", "gas_station", "restaurant", "hotel", "bank"]

func _ready() -> void:
    _generate_locations()

func _generate_locations() -> void:
    var id := 0
    for x in range(-18, 19):
        for z in range(-18, 19):
            if (x + z) % 3 == 0:
                var kind: String = location_types[id % location_types.size()]
                var location := {
                    "id": id,
                    "type": kind,
                    "position": Vector3(x * 45.0, 0, z * 45.0),
                    "price": _price_for(kind),
                    "open": true
                }
                locations.append(location)
                id += 1

func _price_for(kind: String) -> int:
    match kind:
        "house": return 50000
        "shop": return 120000
        "business": return 300000
        "hospital": return 900000
        "police": return 1000000
        "garage": return 180000
        "gas_station": return 250000
        "restaurant": return 160000
        "hotel": return 700000
        "bank": return 2000000
        _: return 10000

func get_locations() -> Array[Dictionary]:
    return locations.duplicate(true)

func get_locations_by_type(kind: String) -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    for location in locations:
        if location["type"] == kind:
            result.append(location)
    return result

func get_location_count() -> int:
    return locations.size()

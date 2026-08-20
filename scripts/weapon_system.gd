extends Node
class_name WeaponSystem

const MAX_WEAPONS := 64
var inventory: Array[Dictionary] = []
var equipped_index := -1

func _ready() -> void:
    inventory = _build_catalog()

func _build_catalog() -> Array[Dictionary]:
    var catalog: Array[Dictionary] = []
    var ordinary := [
        ["Pistol", "ballistic", 12], ["Heavy Pistol", "ballistic", 8], ["SMG", "ballistic", 30],
        ["Shotgun", "ballistic", 6], ["Carbine", "ballistic", 30], ["Rifle", "ballistic", 30],
        ["Sniper", "ballistic", 5], ["Marksman", "ballistic", 10], ["Launcher", "ballistic", 1],
        ["Stun Device", "energy", 1]
    ]
    for item in ordinary:
        catalog.append({"name": item[0], "class": item[1], "ammo": item[2], "damage": 10, "price": 500})

    # Fictional sci-fi weapons: gameplay-only names, not real-world weapon instructions.
    var galaxy_names := [
        "Nova Pulse", "Nebula Ray", "Quantum Arc", "Starfall", "Cosmic Lance",
        "Void Spark", "Solar Burst", "Lunar Beam", "Plasma Halo", "Photon Edge",
        "Gravity Pulse", "Meteor Core", "Aurora Cannon", "Eclipse Ray", "Galaxy Spear",
        "Dark Matter", "Warp Pulse", "Stellar Wave", "Comet Driver", "Supernova",
        "Ion Storm", "Celestial Bolt", "Orbit Breaker", "Astro Beam", "Void Lance",
        "Nebula Storm", "Quantum Nova", "Solar Lance", "Cosmic Rift", "Star Core",
        "Moonflare", "Gravity Nova", "Photon Storm", "Plasma Rift", "Eclipse Core",
        "Meteor Pulse", "Aurora Spear", "Galaxy Wave", "Warp Lance", "Void Nova",
        "Stellar Burst", "Cosmic Pulse", "Quantum Beam", "Nova Lance", "Nebula Core",
        "Solar Rift", "Darkstar", "Hyperion", "Galactic Ray", "Infinity Pulse"
    ]
    for i in range(galaxy_names.size()):
        catalog.append({"name": galaxy_names[i], "class": "fictional_energy", "ammo": 20, "damage": 40 + i, "price": 25000 + i * 5000})
    return catalog

func equip(index: int) -> bool:
    if index < 0 or index >= inventory.size():
        return false
    equipped_index = index
    return true

func get_equipped() -> Dictionary:
    if equipped_index < 0 or equipped_index >= inventory.size():
        return {}
    return inventory[equipped_index]

func upgrade(index: int, level: int) -> bool:
    if index < 0 or index >= inventory.size() or level < 1:
        return false
    inventory[index]["damage"] = int(inventory[index]["damage"]) + level * 5
    return true

func get_weapon_count() -> int:
    return inventory.size()

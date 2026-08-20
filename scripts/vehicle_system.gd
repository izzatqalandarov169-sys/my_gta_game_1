extends Node3D
class_name VehicleSystem

var vehicles: Array[Dictionary] = []
var vehicle_catalog: Array[Dictionary] = []

func _ready() -> void:
    vehicle_catalog = _build_catalog()

func _build_catalog() -> Array[Dictionary]:
    var catalog: Array[Dictionary] = []
    var add_model := func(brand: String, model: String, year_from: int, year_to: int, vehicle_type: String, price: float, speed: float) -> void:
        catalog.append({"brand": brand, "name": model, "year_from": year_from, "year_to": year_to, "type": vehicle_type, "price": price, "speed": speed})

    # Uzbekistan / UzAuto family, spanning the classic 1990s era through current models.
    for m in [
        ["Tico",1996,2001,"hatchback",3500,145], ["Damas",1996,2026,"van",9000,125],
        ["Matiz",2001,2018,"hatchback",5500,150], ["Nexia",1995,2008,"sedan",6000,175],
        ["Nexia 2",2008,2016,"sedan",8500,180], ["Nexia 3",2016,2026,"sedan",12000,185],
        ["Cobalt",2013,2026,"sedan",13500,170], ["Gentra",2013,2026,"sedan",15000,180],
        ["Lacetti",2003,2013,"sedan",9500,175], ["Spark",2010,2026,"hatchback",10500,160],
        ["Malibu",2012,2026,"sedan",27000,220], ["Malibu 2",2016,2026,"sedan",31000,235],
        ["Captiva",2007,2026,"suv",30000,205], ["Tracker",2019,2026,"suv",24000,195],
        ["Equinox",2020,2026,"suv",35000,210], ["Traverse",2020,2026,"suv",50000,210],
        ["Onix",2022,2026,"hatchback",16000,185], ["Monza",2022,2026,"sedan",18000,190]
    ]:
        add_model.call("Uzbekistan", m[0], m[1], m[2], m[3], m[4], m[5])

    # Tesla passenger lineup.
    for m in [
        ["Roadster",2008,2012,"sport",120000,210], ["Model S",2012,2026,"sedan",80000,250],
        ["Model 3",2017,2026,"sedan",40000,225], ["Model X",2015,2026,"suv",90000,240],
        ["Model Y",2020,2026,"crossover",50000,230], ["Cybertruck",2023,2026,"pickup",80000,210],
        ["Semi",2022,2026,"truck",180000,160]
    ]:
        add_model.call("Tesla", m[0], m[1], m[2], m[3], m[4], m[5])

    # Mercedes-Benz families, including the complete G-Class family representation.
    for m in [
        ["A-Class",1997,2026,"hatchback",42000,225], ["B-Class",2005,2026,"mpv",45000,215],
        ["C-Class",1993,2026,"sedan",55000,245], ["E-Class",1993,2026,"sedan",70000,250],
        ["S-Class",1991,2026,"luxury",120000,270], ["CLA",2013,2026,"sedan",50000,235],
        ["CLS",2004,2023,"coupe",75000,250], ["CLE",2023,2026,"coupe",70000,250],
        ["GLA",2013,2026,"suv",55000,225], ["GLB",2019,2026,"suv",58000,220],
        ["GLC",2015,2026,"suv",65000,240], ["GLE",1997,2026,"suv",85000,250],
        ["GLS",2006,2026,"suv",110000,260], ["G-Class",1990,2026,"suv",140000,240],
        ["G 63 AMG",2012,2026,"suv",190000,280], ["G 550",1990,2026,"suv",160000,240],
        ["EQS",2021,2026,"electric_luxury",120000,250], ["EQE",2022,2026,"electric_sedan",80000,245],
        ["EQA",2021,2026,"electric_suv",60000,210], ["EQB",2021,2026,"electric_suv",65000,215],
        ["EQC",2019,2023,"electric_suv",75000,220], ["Sprinter",1995,2026,"van",55000,170]
    ]:
        add_model.call("Mercedes-Benz", m[0], m[1], m[2], m[3], m[4], m[5])

    # Fictional performance vehicles remain available.
    add_model.call("Galaxy", "Galaxy X", 2026, 2026, "hyper", 250000, 420)
    add_model.call("Night", "Night Rider", 2026, 2026, "super", 500000, 380)
    return catalog

func spawn_vehicle(model: Dictionary, pos: Vector3) -> Node3D:
    var body := VehicleController.new()
    body.name = str(model.name).replace(" ", "_")
    body.position = pos
    body.max_speed = float(model.speed) / 3.6
    body.set_meta("brand", model.brand)
    body.set_meta("model", model.name)
    body.set_meta("price", model.price)
    body.set_meta("year_from", model.year_from)
    body.set_meta("year_to", model.year_to)
    body.set_meta("vehicle_type", model.type)

    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = Vector3(2.0, 0.8, 4.2)
    mesh.mesh = box
    mesh.position.y = 0.65
    var material := StandardMaterial3D.new()
    material.metallic = 0.25
    material.roughness = 0.35
    mesh.material_override = material
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

func get_catalog_count() -> int:
    return vehicle_catalog.size()

func find_brand(brand: String) -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    for model in vehicle_catalog:
        if str(model.brand).to_lower() == brand.to_lower():
            result.append(model)
    return result

extends Node3D
class_name VehicleSystem

var vehicles: Array[Dictionary] = []
var vehicle_catalog: Array[Dictionary] = []

func _ready() -> void:
    vehicle_catalog = _build_catalog()

func _build_catalog() -> Array[Dictionary]:
    var catalog: Array[Dictionary] = []
    var add_model := func(brand: String, model: String, year_from: int, year_to: int, vehicle_type: String, price: float, speed: float) -> void:
        catalog.append({"brand": brand, "name": model, "year_from": year_from, "year_to": year_to, "type": vehicle_type, "price": price, "speed": speed, "unlocked": true})

    for m in [["Tico",1996,2001,"hatchback",3500,145],["Damas",1996,2026,"van",9000,125],["Matiz",2001,2018,"hatchback",5500,150],["Nexia",1995,2008,"sedan",6000,175],["Nexia 2",2008,2016,"sedan",8500,180],["Nexia 3",2016,2026,"sedan",12000,185],["Cobalt",2013,2026,"sedan",13500,170],["Gentra",2013,2026,"sedan",15000,180],["Lacetti",2003,2013,"sedan",9500,175],["Spark",2010,2026,"hatchback",10500,160],["Malibu",2012,2026,"sedan",27000,220],["Malibu 2",2016,2026,"sedan",31000,235],["Captiva",2007,2026,"suv",30000,205],["Tracker",2019,2026,"suv",24000,195],["Equinox",2020,2026,"suv",35000,210],["Traverse",2020,2026,"suv",50000,210],["Onix",2022,2026,"hatchback",16000,185],["Monza",2022,2026,"sedan",18000,190]]:
        add_model.call("Uzbekistan",m[0],m[1],m[2],m[3],m[4],m[5])

    for m in [["Roadster",2008,2012,"sport",120000,210],["Model S",2012,2026,"sedan",80000,250],["Model 3",2017,2026,"sedan",40000,225],["Model X",2015,2026,"suv",90000,240],["Model Y",2020,2026,"crossover",50000,230],["Cybertruck",2023,2026,"pickup",80000,210],["Semi",2022,2026,"truck",180000,160]]:
        add_model.call("Tesla",m[0],m[1],m[2],m[3],m[4],m[5])

    for m in [["1 Series",2004,2026,"hatchback",45000,240],["2 Series",2014,2026,"coupe",50000,245],["3 Series",1975,2026,"sedan",55000,250],["4 Series",2013,2026,"coupe",60000,250],["5 Series",1972,2026,"sedan",70000,255],["6 Series",1976,2026,"coupe",85000,260],["7 Series",1977,2026,"luxury",110000,270],["8 Series",1990,2026,"coupe",120000,280],["X1",2009,2026,"suv",50000,225],["X2",2018,2026,"suv",55000,230],["X3",2003,2026,"suv",65000,240],["X4",2014,2026,"suv",70000,240],["X5",1999,2026,"suv",80000,250],["X6",2008,2026,"suv",90000,255],["X7",2018,2026,"suv",110000,260],["XM",2022,2026,"performance_suv",160000,270],["Z4",2002,2026,"roadster",65000,250]]:
        add_model.call("BMW",m[0],m[1],m[2],m[3],m[4],m[5])

    for m in [["Phantom",2003,2026,"luxury",500000,250],["Ghost",2009,2026,"luxury",350000,250],["Wraith",2013,2022,"coupe",400000,250],["Dawn",2015,2022,"convertible",420000,250],["Cullinan",2018,2026,"luxury_suv",450000,240],["Spectre",2023,2026,"electric_luxury",450000,250]]:
        add_model.call("Rolls-Royce",m[0],m[1],m[2],m[3],m[4],m[5])

    for m in [["Huracan",2014,2026,"supercar",250000,325],["Aventador",2011,2022,"supercar",400000,350],["Revuelto",2023,2026,"supercar",550000,350],["Urus",2018,2026,"suv",250000,305],["Temerario",2024,2026,"supercar",300000,340],["Countach",1974,1990,"supercar",500000,295],["Countach LPI",2021,2022,"supercar",300000,355],["Sian",2019,2022,"hypercar",350000,350]]:
        add_model.call("Lamborghini",m[0],m[1],m[2],m[3],m[4],m[5])

    for m in [["718 Cayman",2016,2026,"sports",80000,275],["718 Boxster",2016,2026,"sports",85000,275],["911",1964,2026,"sports",120000,310],["Taycan",2019,2026,"electric_sports",110000,260],["Panamera",2009,2026,"luxury_sports",100000,300],["Macan",2014,2026,"suv",75000,270],["Cayenne",2002,2026,"suv",90000,285],["918 Spyder",2013,2015,"hypercar",900000,345],["Carrera GT",2004,2006,"hypercar",1000000,330]]:
        add_model.call("Porsche",m[0],m[1],m[2],m[3],m[4],m[5])

    for m in [["360 Modena",1999,2005,"supercar",180000,295],["F430",2004,2009,"supercar",220000,315],["458 Italia",2009,2015,"supercar",250000,325],["488 GTB",2015,2019,"supercar",300000,330],["F8 Tributo",2019,2023,"supercar",350000,340],["Roma",2019,2026,"grand_tourer",250000,320],["Portofino",2017,2023,"convertible",220000,320],["812 Superfast",2017,2024,"supercar",400000,340],["SF90 Stradale",2019,2026,"hybrid_hypercar",550000,340],["296 GTB",2021,2026,"hybrid_supercar",350000,330],["LaFerrari",2013,2018,"hypercar",1500000,350]]:
        add_model.call("Ferrari",m[0],m[1],m[2],m[3],m[4],m[5])

    for m in [["A-Class",1997,2026,"hatchback",42000,225],["C-Class",1993,2026,"sedan",55000,245],["E-Class",1993,2026,"sedan",70000,250],["S-Class",1991,2026,"luxury",120000,270],["GLC",2015,2026,"suv",65000,240],["GLE",1997,2026,"suv",85000,250],["GLS",2006,2026,"suv",110000,260],["G-Class",1990,2026,"suv",140000,240],["G 63 AMG",2012,2026,"suv",190000,280],["G 550",1990,2026,"suv",160000,240],["EQS",2021,2026,"electric_luxury",120000,250]]:
        add_model.call("Mercedes-Benz",m[0],m[1],m[2],m[3],m[4],m[5])

    # Fictional / superhero-style vehicles are intentionally separate from real brands.
    for m in [["Batmobile Classic",2026,2026,"hero",0,380],["Batmobile Tumbler",2026,2026,"armored_hero",0,300],["Batmobile Future",2026,2026,"hero_hyper",0,450],["Galaxy X",2026,2026,"hyper",0,420],["Night Rider",2026,2026,"super",0,380],["Cyber Phantom",2026,2026,"fictional",0,500]]:
        add_model.call("Super Vehicles",m[0],m[1],m[2],m[3],m[4],m[5])
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

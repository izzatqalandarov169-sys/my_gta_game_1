extends Node
class_name ClothingCatalog

const TOTAL_ITEMS := 1200
var items: Array[Dictionary] = []

func _ready() -> void:
    _build_catalog()

func _build_catalog() -> void:
    var categories := ["shirt", "pants", "jacket", "hoodie", "suit", "dress", "shoes", "hat", "mask", "glasses", "accessory", "uniform"]
    var styles := ["casual", "sport", "classic", "street", "luxury", "formal", "tactical", "traditional", "futuristic", "summer"]
    for i in range(TOTAL_ITEMS):
        items.append({
            "id": i,
            "name": "Clothing_%04d" % (i + 1),
            "category": categories[i % categories.size()],
            "style": styles[(i / categories.size()) as int % styles.size()],
            "price": 50 + (i % 100) * 25
        })

func get_items() -> Array[Dictionary]:
    return items.duplicate(true)

func get_item_count() -> int:
    return items.size()

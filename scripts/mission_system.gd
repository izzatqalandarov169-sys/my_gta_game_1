extends Node
class_name MissionSystem

var missions: Array[Dictionary] = []
var active_id := -1
var completed: Dictionary = {}

func _ready() -> void:
    missions = [
        {"id":0,"title":"Birinchi topshiriq","reward":500,"type":"delivery"},
        {"id":1,"title":"Shahar poygasi","reward":1200,"type":"race"},
        {"id":2,"title":"Qutqaruv","reward":900,"type":"rescue"},
        {"id":3,"title":"Politsiya chaqiruvi","reward":1500,"type":"police"},
        {"id":4,"title":"Maxsus transport","reward":2000,"type":"vehicle"},
        {"id":5,"title":"Tungi topshiriq","reward":1800,"type":"night"},
        {"id":6,"title":"Yomg‘irli kun","reward":2200,"type":"weather"},
        {"id":7,"title":"Katta poyga","reward":5000,"type":"race"}
    ]

func start_mission(id: int) -> bool:
    if id < 0 or id >= missions.size():
        return false
    active_id = id
    return true

func complete_active() -> int:
    if active_id < 0:
        return 0
    var reward := int(missions[active_id]["reward"])
    completed[active_id] = true
    active_id = -1
    return reward

func get_active() -> Dictionary:
    if active_id < 0:
        return {}
    return missions[active_id]

extends Node
class_name PhoneApps

var apps := [
    {"id":"contacts","name":"Kontaktlar"},
    {"id":"messages","name":"Xabarlar"},
    {"id":"maps","name":"Xarita"},
    {"id":"camera","name":"Kamera"},
    {"id":"bank","name":"Bank"},
    {"id":"taxi","name":"Taxi"},
    {"id":"jobs","name":"Ishlar"},
    {"id":"garage","name":"Garaj"},
    {"id":"market","name":"Market"},
    {"id":"settings","name":"Sozlamalar"}
]

func list_apps() -> Array[Dictionary]:
    return apps.duplicate(true)

func open_app(id: String) -> bool:
    for app in apps:
        if app["id"] == id:
            return true
    return false

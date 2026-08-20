extends Node
class_name PresidentialSystem

signal president_changed(name: String)

var presidents := [
    "President Alpha", "President Beta", "President Gamma", "President Delta",
    "President Epsilon", "President Zeta", "President Eta", "President Theta"
]
var current_index := 0
var term_days := 30
var days_elapsed := 0
var security_count := 8
var motorcade_size := 5

func get_current_president() -> String:
    return presidents[current_index]

func advance_day() -> void:
    days_elapsed += 1
    if days_elapsed >= term_days:
        change_president()

func change_president() -> void:
    days_elapsed = 0
    current_index = (current_index + 1) % presidents.size()
    president_changed.emit(get_current_president())

func get_motorcade() -> Dictionary:
    return {
        "president": get_current_president(),
        "security": security_count,
        "vehicles": motorcade_size
    }

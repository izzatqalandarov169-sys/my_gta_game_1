extends Node3D
class_name PerformanceLOD

@export var high_distance := 80.0
@export var medium_distance := 180.0
@export var low_distance := 400.0
@export var update_interval := 0.2
var timer := 0.0
var player: Node3D

func set_player(node: Node3D) -> void:
    player = node

func _process(delta: float) -> void:
    if player == null:
        return
    timer += delta
    if timer < update_interval:
        return
    timer = 0.0
    _update_lod()

func _update_lod() -> void:
    for child in get_children():
        if not (child is Node3D):
            continue
        var distance := player.global_position.distance_to(child.global_position)
        var lod := 0
        if distance > low_distance:
            lod = 3
        elif distance > medium_distance:
            lod = 2
        elif distance > high_distance:
            lod = 1
        child.set_meta("lod_level", lod)
        child.set_meta("stream_priority", 0 if lod >= 3 else 1)

func get_lod_for_distance(distance: float) -> int:
    if distance > low_distance:
        return 3
    if distance > medium_distance:
        return 2
    if distance > high_distance:
        return 1
    return 0

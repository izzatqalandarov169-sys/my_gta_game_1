extends CharacterBody3D
class_name NPCLifeAI

@export var walk_speed := 2.5
@export var job := "citizen"
@export var personality := "calm"
@export var has_weapon := false
@export var aggression := 0.2

var home := Vector3.ZERO
var destination := Vector3.ZERO
var state := "routine"
var routine_timer := 0.0
var target: Node3D

var jobs := ["citizen", "driver", "taxi", "mechanic", "shopkeeper", "doctor", "teacher", "security", "worker", "police"]
var personalities := ["calm", "clever", "angry", "brave", "fearful"]

func initialize(index: int) -> void:
    job = jobs[index % jobs.size()]
    personality = personalities[index % personalities.size()]
    aggression = float(index % 10) / 20.0
    has_weapon = job == "security" or job == "police" or index % 7 == 0
    home = global_position
    destination = home

func _physics_process(delta: float) -> void:
    routine_timer += delta
    if routine_timer > 4.0:
        routine_timer = 0.0
        _choose_routine()
    if state == "flee" and target:
        destination = global_position + (global_position - target.global_position).normalized() * 25.0
    var direction := destination - global_position
    direction.y = 0
    if direction.length() > 1.5:
        direction = direction.normalized()
        velocity.x = direction.x * walk_speed
        velocity.z = direction.z * walk_speed
    else:
        velocity.x = move_toward(velocity.x, 0.0, walk_speed)
        velocity.z = move_toward(velocity.z, 0.0, walk_speed)
    move_and_slide()

func _choose_routine() -> void:
    var angle := randf() * TAU
    var distance := randf_range(8.0, 40.0)
    destination = home + Vector3(cos(angle) * distance, 0, sin(angle) * distance)
    state = "routine"

func react_to_danger(source: Node3D) -> void:
    target = source
    if personality == "brave" or aggression > 0.65:
        state = "confront"
    else:
        state = "flee"

func get_job() -> String:
    return job

func get_dialogue_style() -> String:
    return "uzbek_" + personality

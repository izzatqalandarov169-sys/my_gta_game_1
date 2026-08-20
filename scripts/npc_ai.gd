extends CharacterBody3D
class_name SmartNPC

@export var personality := "calm"
@export var aggression := 0.25
@export var cleverness := 0.5
@export var weapon_capable := false
var target: Node3D
var state := "wander"
var speed := 2.2
var home_position := Vector3.ZERO

func setup(kind: String, aggressive: float, smart: float, has_weapon: bool) -> void:
    personality = kind
    aggression = aggressive
    cleverness = smart
    weapon_capable = has_weapon
    home_position = global_position

func _physics_process(delta: float) -> void:
    if state == "wander":
        var offset := Vector3(sin(Time.get_ticks_msec() * 0.0003 + get_instance_id()), 0, cos(Time.get_ticks_msec() * 0.0002 + get_instance_id()))
        velocity.x = offset.x * speed
        velocity.z = offset.z * speed
    elif state == "flee" and target:
        var away := global_position - target.global_position
        away.y = 0
        if away.length() > 0.1:
            away = away.normalized()
            velocity.x = away.x * (speed + 1.0)
            velocity.z = away.z * (speed + 1.0)
    else:
        velocity.x = move_toward(velocity.x, 0.0, speed * delta * 2.0)
        velocity.z = move_toward(velocity.z, 0.0, speed * delta * 2.0)
    move_and_slide()

func react_to_crime(player: Node3D) -> String:
    target = player
    if aggression > 0.65:
        state = "flee" if cleverness < 0.45 else "report"
        return state
    state = "report"
    return "report"

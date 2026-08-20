extends CharacterBody3D
class_name SmartNPC

@export var personality := "calm"
@export var aggression := 0.25
@export var cleverness := 0.5
@export var weapon_capable := false
@export var health := 100.0
@export var can_drive := true
@export var can_use_weapons := true

var target: Node3D
var state := "wander"
var speed := 2.2
var home_position := Vector3.ZERO
var current_action := "idle"
var ammo := 30
var weapon_damage := 18.0
var action_cooldown := 0.0

signal npc_action(action: String)
signal weapon_fired(origin: Vector3, direction: Vector3, damage: float)
signal npc_defeated(npc: Node)

func setup(kind: String, aggressive: float, smart: float, has_weapon: bool) -> void:
    personality = kind
    aggression = aggressive
    cleverness = smart
    weapon_capable = has_weapon
    home_position = global_position
    can_use_weapons = has_weapon

func _physics_process(delta: float) -> void:
    action_cooldown = maxf(0.0, action_cooldown - delta)
    if state == "wander":
        var offset := Vector3(sin(Time.get_ticks_msec() * 0.0003 + get_instance_id()), 0, cos(Time.get_ticks_msec() * 0.0002 + get_instance_id()))
        velocity.x = offset.x * speed
        velocity.z = offset.z * speed
        current_action = "walking"
    elif state == "flee" and target:
        var away := global_position - target.global_position
        away.y = 0
        if away.length() > 0.1:
            away = away.normalized()
            velocity.x = away.x * (speed + 1.0)
            velocity.z = away.z * (speed + 1.0)
        current_action = "fleeing"
    elif state == "combat" and target:
        velocity.x = 0.0
        velocity.z = 0.0
        current_action = "aiming"
        if weapon_capable and action_cooldown <= 0.0 and ammo > 0:
            fire_at(target)
    elif state == "drive":
        velocity.x = sin(Time.get_ticks_msec() * 0.0005) * 4.0
        velocity.z = cos(Time.get_ticks_msec() * 0.0005) * 4.0
        current_action = "driving"
    else:
        velocity.x = move_toward(velocity.x, 0.0, speed * delta * 2.0)
        velocity.z = move_toward(velocity.z, 0.0, speed * delta * 2.0)
        current_action = "idle"
    move_and_slide()

func react_to_crime(player: Node3D) -> String:
    target = player
    if aggression > 0.65 and weapon_capable:
        state = "combat"
        current_action = "combat"
        npc_action.emit("combat")
        return "combat"
    if aggression > 0.65:
        state = "flee" if cleverness < 0.45 else "report"
        npc_action.emit(state)
        return state
    state = "report"
    npc_action.emit("report")
    return "report"

func fire_at(enemy: Node3D) -> bool:
    if not weapon_capable or ammo <= 0 or enemy == null:
        return false
    var origin := global_position + Vector3.UP * 1.2
    var direction := (enemy.global_position + Vector3.UP - origin).normalized()
    ammo -= 1
    action_cooldown = 0.55
    weapon_fired.emit(origin, direction, weapon_damage)
    npc_action.emit("fire")
    return true

func enter_vehicle() -> bool:
    if not can_drive:
        return false
    state = "drive"
    current_action = "driving"
    npc_action.emit("enter_vehicle")
    return true

func exit_vehicle() -> void:
    state = "wander"
    current_action = "walking"
    npc_action.emit("exit_vehicle")

func interact(action: String) -> void:
    current_action = action
    npc_action.emit(action)

func take_damage(amount: float) -> bool:
    health -= maxf(0.0, amount)
    if health <= 0.0:
        npc_defeated.emit(self)
        queue_free()
        return true
    return false

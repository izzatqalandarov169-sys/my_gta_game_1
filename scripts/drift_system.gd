extends Node
class_name DriftSystem

@export var drift_force: float = 9.0
@export var lateral_grip: float = 5.0
@export var handbrake_grip: float = 1.8
@export var drift_angle_limit: float = 55.0

var enabled: bool = true
var score: float = 0.0
var combo: float = 0.0

func calculate_drift(vehicle: CharacterBody3D, throttle: float, steering: float, handbrake: bool, delta: float) -> Dictionary:
    if vehicle == null or not enabled:
        return {"drifting": false, "angle": 0.0, "score": 0.0}

    var local_velocity: Vector3 = vehicle.global_transform.basis.inverse() * vehicle.velocity
    var forward_speed: float = abs(local_velocity.z)
    var lateral_speed: float = abs(local_velocity.x)
    var angle: float = rad_to_deg(atan2(lateral_speed, max(forward_speed, 0.1)))
    var drifting: bool = forward_speed > 4.0 and angle > 8.0 and (abs(steering) > 0.15 or handbrake)

    if drifting:
        var grip: float = handbrake_grip if handbrake else lateral_grip
        local_velocity.x = move_toward(local_velocity.x, -steering * forward_speed * 0.75, grip * delta)
        vehicle.velocity = vehicle.global_transform.basis * local_velocity
        combo += delta * (1.0 + angle / 20.0)
        score += delta * forward_speed * max(angle, 1.0)
    else:
        combo = max(combo - delta * 2.0, 0.0)

    return {"drifting": drifting, "angle": angle, "score": score, "combo": combo}

func reset_score() -> void:
    score = 0.0
    combo = 0.0

extends CharacterBody3D
class_name VehicleController

@export var max_speed: float = 55.0
@export var acceleration: float = 24.0
@export var braking: float = 38.0
@export var steering_strength: float = 1.7
@export var traction: float = 7.0
@export var handbrake_traction: float = 1.8
@export var reverse_speed: float = 18.0

var throttle: float = 0.0
var steering: float = 0.0
var handbrake: bool = false
var tuning: Dictionary = {"engine": 0, "brakes": 0, "tires": 0, "turbo": 0}

func _physics_process(delta: float) -> void:
    throttle = Input.get_axis("move_back", "move_forward")
    steering = Input.get_axis("move_left", "move_right")
    handbrake = Input.is_action_pressed("ui_accept")

    var forward: Vector3 = -global_transform.basis.z
    var target_speed: float = max_speed * (1.0 + float(tuning["engine"]) * 0.08 + float(tuning["turbo"]) * 0.15)
    if throttle < 0.0:
        target_speed = reverse_speed

    var desired: Vector3 = forward * throttle * target_speed
    var rate: float = acceleration if abs(throttle) > 0.05 else braking
    velocity.x = move_toward(velocity.x, desired.x, rate * delta)
    velocity.z = move_toward(velocity.z, desired.z, rate * delta)

    var speed_factor: float = clampf(Vector2(velocity.x, velocity.z).length() / 10.0, 0.0, 1.0)
    rotate_y(-steering * steering_strength * speed_factor * delta)

    var grip: float = handbrake_traction if handbrake else traction + float(tuning["tires"])
    var local: Vector3 = global_transform.basis.inverse() * velocity
    local.x = move_toward(local.x, 0.0, grip * delta)
    velocity = global_transform.basis * local
    move_and_slide()

func apply_tuning(part: String) -> bool:
    if not tuning.has(part):
        return false
    tuning[part] = mini(int(tuning[part]) + 1, 5)
    return true

func get_speed_kmh() -> float:
    return Vector2(velocity.x, velocity.z).length() * 3.6

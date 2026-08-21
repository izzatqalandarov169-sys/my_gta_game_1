extends CharacterBody3D
class_name VehicleController

@export var max_speed: float = 55.0
@export var acceleration: float = 24.0
@export var braking: float = 38.0
@export var steering_strength: float = 1.7
@export var traction: float = 7.0
@export var handbrake_traction: float = 1.8
@export var reverse_speed: float = 18.0

var throttle := 0.0
var steering := 0.0
var handbrake := false
var mobile_brake := false
var tuning: Dictionary = {"engine": 0, "brakes": 0, "tires": 0, "turbo": 0}
var driver_active := false

func set_driver_active(active: bool) -> void:
    driver_active = active
    if not active:
        throttle = 0.0
        steering = 0.0
        velocity.x = 0.0
        velocity.z = 0.0

func _physics_process(delta: float) -> void:
    if not driver_active:
        return

    var mobile := get_tree().get_first_node_in_group("mobile_controls") as MobileControls
    if mobile != null:
        throttle = -mobile.move_vector.y
        steering = mobile.move_vector.x
    else:
        throttle = 0.0
        steering = 0.0
    handbrake = mobile_brake

    var forward := -global_transform.basis.z
    var target_speed := max_speed * (1.0 + float(tuning["engine"]) * 0.08 + float(tuning["turbo"]) * 0.15)
    if throttle < 0.0:
        target_speed = reverse_speed

    var desired := forward * throttle * target_speed
    var rate := acceleration if abs(throttle) > 0.05 else braking
    if handbrake:
        rate = braking * 1.6
    velocity.x = move_toward(velocity.x, desired.x, rate * delta)
    velocity.z = move_toward(velocity.z, desired.z, rate * delta)

    var speed_factor := clampf(Vector2(velocity.x, velocity.z).length() / 10.0, 0.0, 1.0)
    rotate_y(-steering * steering_strength * speed_factor * delta)

    var grip := handbrake_traction if handbrake else traction + float(tuning["tires"])
    var local := global_transform.basis.inverse() * velocity
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

extends CharacterBody3D
class_name PlayerController

@export var walk_speed := 5.2
@export var run_speed := 7.4
@export var jump_velocity := 7.0

var move_input := Vector2.ZERO
var camera_yaw := 0.0
var enabled := true
var _time := 0.0
var _left_leg: Node3D
var _right_leg: Node3D
var _left_arm: Node3D
var _right_arm: Node3D

func _ready() -> void:
    _left_leg = get_node_or_null("LeftLeg")
    _right_leg = get_node_or_null("RightLeg")
    _left_arm = get_node_or_null("LeftArm")
    _right_arm = get_node_or_null("RightArm")

func set_move_input(value: Vector2) -> void:
    move_input = value.limit_length(1.0)

func set_camera_yaw(value: float) -> void:
    camera_yaw = value

func jump() -> void:
    if enabled and is_on_floor():
        velocity.y = jump_velocity

func _physics_process(delta: float) -> void:
    if not enabled:
        return
    _time += delta
    var direction := Vector3(move_input.x, 0.0, move_input.y)
    if direction.length_squared() > 0.01:
        direction = Basis(Vector3.UP, camera_yaw) * direction.normalized()
        var speed := run_speed if move_input.length() > 0.82 else walk_speed
        velocity.x = move_toward(velocity.x, direction.x * speed, 24.0 * delta)
        velocity.z = move_toward(velocity.z, direction.z * speed, 24.0 * delta)
        rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), minf(1.0, 10.0 * delta))
    else:
        velocity.x = move_toward(velocity.x, 0.0, 28.0 * delta)
        velocity.z = move_toward(velocity.z, 0.0, 28.0 * delta)

    if not is_on_floor():
        velocity.y -= 18.0 * delta
    else:
        velocity.y = -0.2
    move_and_slide()
    _animate_body(delta)

func _animate_body(_delta: float) -> void:
    var speed := Vector2(velocity.x, velocity.z).length()
    var moving := speed > 0.25
    var swing := sin(_time * (7.0 if speed < 6.0 else 9.0)) * 0.45 if moving else 0.0
    if _left_leg:
        _left_leg.rotation.x = swing
    if _right_leg:
        _right_leg.rotation.x = -swing
    if _left_arm:
        _left_arm.rotation.x = -swing * 0.7
    if _right_arm:
        _right_arm.rotation.x = swing * 0.7

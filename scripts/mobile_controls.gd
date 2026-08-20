extends CanvasLayer
class_name MobileControls

signal move_changed(direction: Vector2)
signal action_pressed(action: String)

var move_vector := Vector2.ZERO

func set_move(direction: Vector2) -> void:
    move_vector = direction.limit_length(1.0)
    move_changed.emit(move_vector)

func press_action(action: String) -> void:
    action_pressed.emit(action)

func release_move() -> void:
    set_move(Vector2.ZERO)

extends Node
class_name AntiCheat

var violation_count := 0
var banned := false
var server_authoritative := true

func report_violation(reason: String) -> void:
    if reason.is_empty() or banned:
        return
    violation_count += 1
    if violation_count >= 3:
        banned = true

func validate_money(old_value: int, new_value: int) -> bool:
    if new_value < 0:
        report_violation("negative money")
        return false
    if new_value > old_value + 1000000:
        report_violation("impossible money increase")
        return false
    return true

func validate_player_action(action: String) -> bool:
    if banned or action.is_empty():
        return false
    return true

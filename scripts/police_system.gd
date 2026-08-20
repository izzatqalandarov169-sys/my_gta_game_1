extends Node
class_name PoliceSystem

signal wanted_changed(level: int)
signal arrested(jail_seconds: int)

@export var max_wanted: int = 5
@export var max_jail_seconds: int = 300
var wanted_level: int = 0
var jail_remaining: float = 0.0
var arrest_fee: int = 500
var active_chases: int = 0

func commit_crime(severity: int = 1) -> void:
    wanted_level = clampi(wanted_level + maxi(severity, 1), 0, max_wanted)
    wanted_changed.emit(wanted_level)

func reduce_wanted(amount: int = 1) -> void:
    wanted_level = maxi(wanted_level - maxi(amount, 1), 0)
    wanted_changed.emit(wanted_level)

func can_police_chase() -> bool:
    return wanted_level > 0

func start_chase() -> void:
    if wanted_level > 0:
        active_chases += 1

func stop_chase() -> void:
    active_chases = maxi(active_chases - 1, 0)

func arrest() -> void:
    jail_remaining = float(clampi(wanted_level * 60, 60, max_jail_seconds))
    wanted_level = 0
    active_chases = 0
    arrested.emit(int(ceil(jail_remaining)))

func tick_jail(delta: float) -> bool:
    if jail_remaining <= 0.0:
        return true
    jail_remaining = maxf(jail_remaining - delta, 0.0)
    return jail_remaining <= 0.0

func pay_release(player_money: int) -> Dictionary:
    if jail_remaining <= 0.0:
        return {"success": true, "cost": 0}
    var cost: int = mini(arrest_fee + wanted_level * 250, 5000)
    if player_money < cost:
        return {"success": false, "cost": cost}
    jail_remaining = 0.0
    wanted_level = 0
    return {"success": true, "cost": cost}

func get_jail_remaining() -> int:
    return int(ceil(jail_remaining))

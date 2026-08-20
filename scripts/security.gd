extends Node
class_name SecuritySystem

enum PlayerStatus { NORMAL, FLAGGED, SUSPENDED, BANNED }
var player_status := PlayerStatus.NORMAL
var flags: Array[String] = []

func flag(reason: String) -> void:
    if reason.is_empty():
        return
    flags.append(reason)
    if flags.size() >= 3:
        player_status = PlayerStatus.FLAGGED

func clear_flags() -> void:
    flags.clear()
    player_status = PlayerStatus.NORMAL

func suspend() -> void:
    player_status = PlayerStatus.SUSPENDED

func ban() -> void:
    player_status = PlayerStatus.BANNED

func is_banned() -> bool:
    return player_status == PlayerStatus.BANNED

# NPC entities never enter this system; moderation is player-only.

extends Node
class_name ServerAuthority

var player_states: Dictionary = {}
var server_money: Dictionary = {}
var banned_players: Dictionary = {}

func register_player(peer_id: int) -> void:
    if not server_money.has(peer_id):
        server_money[peer_id] = 1000
    player_states[peer_id] = {"connected": true}

func unregister_player(peer_id: int) -> void:
    if player_states.has(peer_id):
        player_states[peer_id]["connected"] = false

func validate_money_change(peer_id: int, old_value: int, new_value: int) -> bool:
    if banned_players.has(peer_id) or new_value < 0:
        return false
    if new_value > old_value + 1000000:
        flag_player(peer_id, "impossible money change")
        return false
    server_money[peer_id] = new_value
    return true

func flag_player(peer_id: int, reason: String) -> void:
    var state = player_states.get(peer_id, {})
    state["last_violation"] = reason
    state["violations"] = int(state.get("violations", 0)) + 1
    player_states[peer_id] = state
    if state["violations"] >= 3:
        ban_player(peer_id, reason)

func ban_player(peer_id: int, reason: String) -> void:
    banned_players[peer_id] = {"reason": reason}

func is_banned(peer_id: int) -> bool:
    return banned_players.has(peer_id)

func npc_is_bannable() -> bool:
    return false

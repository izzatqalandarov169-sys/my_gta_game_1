extends Node
class_name AuthoritativeBackend

const STATE_PATH := "user://authoritative_state.json"
const STARTING_BALANCE_UZS := 100000
const MAX_REWARD_UZS := 1000000

var balances_uzs: Dictionary = {}
var players: Dictionary = {}
var bans: Dictionary = {}
var unlocked_vehicles: Dictionary = {}
var unlocked_weapons: Dictionary = {}

func _ready() -> void:
    load_state()

func register_player(player_id: String) -> void:
    if bans.has(player_id):
        return
    if not balances_uzs.has(player_id):
        balances_uzs[player_id] = STARTING_BALANCE_UZS
    players[player_id] = {"connected": true, "violations": int(players.get(player_id, {}).get("violations", 0))}
    save_state()

func get_balance_uzs(player_id: String) -> int:
    return int(balances_uzs.get(player_id, 0))

func grant_uzs(player_id: String, amount_uzs: int, reason: String = "reward") -> bool:
    if amount_uzs <= 0 or amount_uzs > MAX_REWARD_UZS or bans.has(player_id):
        flag_player(player_id, "invalid reward")
        return false
    balances_uzs[player_id] = get_balance_uzs(player_id) + amount_uzs
    players.setdefault(player_id, {"connected": true, "violations": 0})
    players[player_id]["last_reward"] = reason
    save_state()
    return true

func spend_uzs(player_id: String, amount_uzs: int, reason: String = "purchase") -> bool:
    if amount_uzs < 0 or bans.has(player_id) or get_balance_uzs(player_id) < amount_uzs:
        return false
    balances_uzs[player_id] = get_balance_uzs(player_id) - amount_uzs
    players.setdefault(player_id, {"connected": true, "violations": 0})
    players[player_id]["last_purchase"] = reason
    save_state()
    return true

func unlock_item(player_id: String, item_type: String, item_id: String, reason: String = "reward") -> bool:
    if bans.has(player_id) or item_id.strip_edges().is_empty():
        return false
    var target: Dictionary
    if item_type == "vehicle":
        target = unlocked_vehicles
    elif item_type == "weapon":
        target = unlocked_weapons
    else:
        return false
    if not target.has(player_id):
        target[player_id] = {}
    target[player_id][item_id] = {"unlocked": true, "reason": reason, "time": Time.get_unix_time_from_system()}
    save_state()
    return true

func has_item(player_id: String, item_type: String, item_id: String) -> bool:
    if item_type == "vehicle":
        return unlocked_vehicles.get(player_id, {}).has(item_id)
    if item_type == "weapon":
        return unlocked_weapons.get(player_id, {}).has(item_id)
    return false

func flag_player(player_id: String, reason: String) -> void:
    var state: Dictionary = players.get(player_id, {"connected": true, "violations": 0})
    state["violations"] = int(state.get("violations", 0)) + 1
    state["last_violation"] = reason
    players[player_id] = state
    if int(state["violations"]) >= 3:
        bans[player_id] = {"reason": reason, "time": Time.get_unix_time_from_system()}
    save_state()

func is_banned(player_id: String) -> bool:
    return bans.has(player_id)

func save_state() -> void:
    var file := FileAccess.open(STATE_PATH, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify({"balances_uzs": balances_uzs, "players": players, "bans": bans, "unlocked_vehicles": unlocked_vehicles, "unlocked_weapons": unlocked_weapons}))
        file.close()

func load_state() -> void:
    if not FileAccess.file_exists(STATE_PATH):
        return
    var file := FileAccess.open(STATE_PATH, FileAccess.READ)
    if not file:
        return
    var parsed = JSON.parse_string(file.get_as_text())
    file.close()
    if typeof(parsed) == TYPE_DICTIONARY:
        balances_uzs = parsed.get("balances_uzs", {})
        players = parsed.get("players", {})
        bans = parsed.get("bans", {})
        unlocked_vehicles = parsed.get("unlocked_vehicles", {})
        unlocked_weapons = parsed.get("unlocked_weapons", {})

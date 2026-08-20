extends Node
class_name PromoCodeSystem

const DB_PATH := "user://promo_codes.json"

var promo_codes: Dictionary = {}
var redeemed_codes: Dictionary = {}

signal promo_applied(code: String, reward: Dictionary)
signal promo_rejected(code: String, reason: String)

func _ready() -> void:
    load_database()

func create_promo(name: String, expires_at_unix: int, price_uzs: int, reward: Dictionary = {}) -> bool:
    var normalized := name.strip_edges().to_upper()
    if normalized.is_empty() or expires_at_unix <= 0 or price_uzs < 0:
        return false
    promo_codes[normalized] = {"name": normalized, "expires_at": expires_at_unix, "price_uzs": price_uzs, "reward": reward.duplicate(true)}
    save_database()
    return true

func redeem_promo(code: String, player_id: String = "local") -> Dictionary:
    var normalized := code.strip_edges().to_upper()
    if not promo_codes.has(normalized):
        promo_rejected.emit(normalized, "not_found")
        return {"ok": false, "reason": "not_found"}
    var promo: Dictionary = promo_codes[normalized]
    if int(promo.get("expires_at", 0)) < int(Time.get_unix_time_from_system()):
        promo_rejected.emit(normalized, "expired")
        return {"ok": false, "reason": "expired"}
    var key := player_id + ":" + normalized
    if redeemed_codes.has(key):
        promo_rejected.emit(normalized, "already_used")
        return {"ok": false, "reason": "already_used"}
    redeemed_codes[key] = true
    save_database()
    var reward: Dictionary = promo.get("reward", {}).duplicate(true)
    reward["promo_name"] = promo.get("name", normalized)
    reward["promo_price_uzs"] = int(promo.get("price_uzs", 0))
    reward["expires_at"] = int(promo.get("expires_at", 0))
    promo_applied.emit(normalized, reward)
    return {"ok": true, "reward": reward}

func get_promo(name: String) -> Dictionary:
    var normalized := name.strip_edges().to_upper()
    if not promo_codes.has(normalized):
        return {}
    return promo_codes[normalized].duplicate(true)

func list_promos() -> Array:
    var result: Array = []
    for key in promo_codes.keys():
        result.append(promo_codes[key].duplicate(true))
    return result

func remove_promo(name: String) -> bool:
    var normalized := name.strip_edges().to_upper()
    if not promo_codes.has(normalized):
        return false
    promo_codes.erase(normalized)
    save_database()
    return true

func save_database() -> void:
    var data := {"promo_codes": promo_codes, "redeemed_codes": redeemed_codes}
    var file := FileAccess.open(DB_PATH, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(data))
        file.close()

func load_database() -> void:
    if not FileAccess.file_exists(DB_PATH):
        return
    var file := FileAccess.open(DB_PATH, FileAccess.READ)
    if not file:
        return
    var parsed = JSON.parse_string(file.get_as_text())
    file.close()
    if typeof(parsed) != TYPE_DICTIONARY:
        return
    promo_codes = parsed.get("promo_codes", {})
    redeemed_codes = parsed.get("redeemed_codes", {})

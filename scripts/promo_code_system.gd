extends Node
class_name PromoCodeSystem

var promo_codes: Dictionary = {}
var redeemed_codes: Dictionary = {}

signal promo_applied(code: String, reward: Dictionary)
signal promo_rejected(code: String, reason: String)

func create_promo(name: String, expires_at_unix: int, price: float, reward: Dictionary = {}) -> bool:
    var normalized := name.strip_edges().to_upper()
    if normalized.is_empty() or expires_at_unix <= 0 or price < 0.0:
        return false
    promo_codes[normalized] = {
        "name": normalized,
        "expires_at": expires_at_unix,
        "price": price,
        "reward": reward.duplicate(true)
    }
    return true

func redeem_promo(code: String, player_id: String = "local") -> Dictionary:
    var normalized := code.strip_edges().to_upper()
    if not promo_codes.has(normalized):
        promo_rejected.emit(normalized, "not_found")
        return {"ok": false, "reason": "not_found"}
    var promo: Dictionary = promo_codes[normalized]
    if int(promo.expires_at) < int(Time.get_unix_time_from_system()):
        promo_rejected.emit(normalized, "expired")
        return {"ok": false, "reason": "expired"}
    var key := player_id + ":" + normalized
    if redeemed_codes.has(key):
        promo_rejected.emit(normalized, "already_used")
        return {"ok": false, "reason": "already_used"}
    redeemed_codes[key] = true
    var reward: Dictionary = promo.reward.duplicate(true)
    reward["promo_name"] = promo.name
    reward["promo_price"] = promo.price
    reward["expires_at"] = promo.expires_at
    promo_applied.emit(normalized, reward)
    return {"ok": true, "reward": reward}

func get_promo(name: String) -> Dictionary:
    var normalized := name.strip_edges().to_upper()
    if not promo_codes.has(normalized):
        return {}
    return promo_codes[normalized].duplicate(true)

func remove_promo(name: String) -> bool:
    var normalized := name.strip_edges().to_upper()
    if not promo_codes.has(normalized):
        return false
    promo_codes.erase(normalized)
    return true

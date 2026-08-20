extends Node
class_name GameServices

var backend: AuthoritativeBackend
var promos: PromoCodeSystem

func _ready() -> void:
    backend = AuthoritativeBackend.new()
    add_child(backend)
    promos = PromoCodeSystem.new()
    add_child(promos)

func register_player(player_id: String) -> void:
    backend.register_player(player_id)

func redeem_promo(player_id: String, code: String) -> Dictionary:
    if backend.is_banned(player_id):
        return {"ok": false, "reason": "banned"}
    var result := promos.redeem_promo(code, player_id)
    if not bool(result.get("ok", false)):
        return result
    var reward: Dictionary = result.get("reward", {})
    var reward_type := str(reward.get("type", "")).to_lower()
    var reward_value := str(reward.get("value", ""))

    if reward_type == "uzs":
        var amount := int(reward_value)
        if not backend.grant_uzs(player_id, amount, "promo:" + code):
            return {"ok": false, "reason": "reward_rejected"}
    elif reward_type == "vehicle" or reward_type == "weapon":
        backend.unlock_item(player_id, reward_type, reward_value, "promo:" + code)

    reward["player_id"] = player_id
    reward["balance_uzs"] = backend.get_balance_uzs(player_id)
    return {"ok": true, "reward": reward}

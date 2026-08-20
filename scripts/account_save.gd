extends Node
class_name AccountSave

const SAVE_PATH := "user://player_save.json"
var account_id := ""
var data := {"money":1000,"level":1,"inventory":[],"vehicles":[],"clothes":[],"missions":[],"banned":false}

func create_account(id: String) -> void:
    account_id = id
    load_account()

func save_account() -> bool:
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(JSON.stringify({"account_id":account_id,"data":data}))
    return true

func load_account() -> bool:
    if not FileAccess.file_exists(SAVE_PATH):
        return save_account()
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        return false
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        return false
    account_id = str(parsed.get("account_id", account_id))
    data = parsed.get("data", data)
    return true

func set_money(value: int) -> void:
    data["money"] = max(value, 0)

func get_money() -> int:
    return int(data["money"])

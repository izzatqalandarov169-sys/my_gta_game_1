extends Node
class_name EconomySystem

const CURRENCY := "UZS"
const CURRENCY_NAME := "so‘m"

var balance: int = 100000
var owned_vehicles: Array[String] = []
var owned_businesses: Array[String] = []

var jobs := {
    "taxi": 150000,
    "delivery": 220000,
    "bus_driver": 260000,
    "mechanic": 320000,
    "cargo": 500000,
    "racing": 750000,
    "farm": 180000,
    "security": 300000
}

func format_uzs(amount: int) -> String:
    var text := str(amount)
    var result := ""
    while text.length() > 3:
        result = " " + text.substr(text.length() - 3, 3) + result
        text = text.substr(0, text.length() - 3)
    return text + result + " so‘m"

func can_afford(price_uzs: int) -> bool:
    return price_uzs >= 0 and balance >= price_uzs

func earn(amount_uzs: int) -> void:
    if amount_uzs > 0:
        balance += amount_uzs

func spend(amount_uzs: int) -> bool:
    if amount_uzs < 0 or balance < amount_uzs:
        return false
    balance -= amount_uzs
    return true

func buy_vehicle(vehicle_name: String, price_uzs: int) -> bool:
    if owned_vehicles.has(vehicle_name) or not spend(price_uzs):
        return false
    owned_vehicles.append(vehicle_name)
    return true

func do_job(job_name: String) -> int:
    if not jobs.has(job_name):
        return 0
    var reward_uzs: int = jobs[job_name]
    earn(reward_uzs)
    return reward_uzs

extends Node
class_name EconomySystem

var balance: int = 1000
var owned_vehicles: Array[String] = []
var owned_businesses: Array[String] = []

var jobs := {
    "taxi": 150,
    "delivery": 220,
    "bus_driver": 260,
    "mechanic": 320,
    "cargo": 500,
    "racing": 750,
    "farm": 180,
    "security": 300
}

func can_afford(price: int) -> bool:
    return balance >= price

func earn(amount: int) -> void:
    if amount > 0:
        balance += amount

func spend(amount: int) -> bool:
    if amount < 0 or balance < amount:
        return false
    balance -= amount
    return true

func buy_vehicle(vehicle_name: String, price: int) -> bool:
    if not spend(price):
        return false
    owned_vehicles.append(vehicle_name)
    return true

func do_job(job_name: String) -> int:
    if not jobs.has(job_name):
        return 0
    var reward: int = jobs[job_name]
    earn(reward)
    return reward

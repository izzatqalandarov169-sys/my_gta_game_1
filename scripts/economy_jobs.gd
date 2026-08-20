extends Node
class_name EconomyJobs

var jobs := {
    "taxi_driver": {"reward": 180, "risk": 0}, "delivery_driver": {"reward": 240, "risk": 0},
    "truck_driver": {"reward": 420, "risk": 1}, "bus_driver": {"reward": 300, "risk": 0},
    "mechanic": {"reward": 350, "risk": 0}, "construction": {"reward": 380, "risk": 1},
    "security": {"reward": 450, "risk": 1}, "doctor": {"reward": 500, "risk": 0},
    "teacher": {"reward": 280, "risk": 0}, "shopkeeper": {"reward": 320, "risk": 0},
    "farmer": {"reward": 260, "risk": 0}, "miner": {"reward": 520, "risk": 2},
    "fisher": {"reward": 290, "risk": 0}, "racer": {"reward": 800, "risk": 2},
    "courier": {"reward": 260, "risk": 0}, "photographer": {"reward": 220, "risk": 0},
    "tour_guide": {"reward": 340, "risk": 0}, "pilot": {"reward": 700, "risk": 1},
    "warehouse": {"reward": 360, "risk": 1}, "restaurant": {"reward": 300, "risk": 0},
    "software": {"reward": 650, "risk": 0}, "repair": {"reward": 390, "risk": 0},
    "cleaning": {"reward": 180, "risk": 0}, "gardener": {"reward": 210, "risk": 0},
    "farrier": {"reward": 330, "risk": 0}, "electrician": {"reward": 440, "risk": 1},
    "plumber": {"reward": 430, "risk": 1}, "builder": {"reward": 470, "risk": 1},
    "journalist": {"reward": 360, "risk": 1}, "musician": {"reward": 250, "risk": 0},
    "actor": {"reward": 400, "risk": 0}, "athlete": {"reward": 600, "risk": 1},
    "trainer": {"reward": 350, "risk": 0}, "security_guard": {"reward": 420, "risk": 1},
    "dispatcher": {"reward": 300, "risk": 0}, "firefighter": {"reward": 620, "risk": 3},
    "paramedic": {"reward": 580, "risk": 2}, "pilot_helper": {"reward": 380, "risk": 0},
    "car_dealer": {"reward": 700, "risk": 0}, "property_agent": {"reward": 750, "risk": 0},
    "warehouse_manager": {"reward": 680, "risk": 1}, "farmer_market": {"reward": 340, "risk": 0},
    "street_vendor": {"reward": 280, "risk": 1}, "barista": {"reward": 240, "risk": 0},
    "chef": {"reward": 420, "risk": 0}, "courier_express": {"reward": 500, "risk": 1},
    "drone_operator": {"reward": 550, "risk": 0}, "researcher": {"reward": 720, "risk": 0},
    "engineer": {"reward": 800, "risk": 1}, "designer": {"reward": 620, "risk": 0},
    "developer": {"reward": 900, "risk": 0}, "streamer": {"reward": 450, "risk": 0},
    "content_creator": {"reward": 480, "risk": 0}, "rental_manager": {"reward": 650, "risk": 0},
    "hotel_worker": {"reward": 320, "risk": 0}, "security_consultant": {"reward": 780, "risk": 1},
    "rescue_worker": {"reward": 600, "risk": 2}, "race_mechanic": {"reward": 720, "risk": 1},
    "test_driver": {"reward": 850, "risk": 2}, "transport_manager": {"reward": 740, "risk": 1},
    "business_owner": {"reward": 1000, "risk": 1}, "investor": {"reward": 1200, "risk": 3},
    "freelancer": {"reward": 520, "risk": 0}, "translator": {"reward": 360, "risk": 0},
    "artist": {"reward": 380, "risk": 0}, "craftsman": {"reward": 460, "risk": 0},
    "explorer": {"reward": 700, "risk": 2}, "adventurer": {"reward": 900, "risk": 3},
    "rally_driver": {"reward": 1000, "risk": 3}, "stunt_driver": {"reward": 1100, "risk": 3},
    "security_escort": {"reward": 800, "risk": 2}, "event_worker": {"reward": 350, "risk": 0},
    "festival_vendor": {"reward": 430, "risk": 1}, "market_trader": {"reward": 600, "risk": 1},
    "real_estate_investor": {"reward": 1400, "risk": 3}, "business_manager": {"reward": 1100, "risk": 2},
    "night_worker": {"reward": 500, "risk": 2}, "specialist": {"reward": 900, "risk": 1}
}

func get_job_count() -> int:
    return jobs.size()

func get_reward(job_name: String) -> int:
    if not jobs.has(job_name):
        return 0
    return int(jobs[job_name]["reward"])

func complete_job(job_name: String) -> int:
    return get_reward(job_name)

extends Node
class_name WorldEnvironmentSystem

signal weather_changed(weather: String)
signal time_changed(hour: float)

var hour := 12.0
var day_speed := 0.08
var weather := "clear"
var weather_types := ["clear", "cloudy", "rain", "storm", "fog", "snow"]

func _process(delta: float) -> void:
    hour = fmod(hour + delta * day_speed, 24.0)
    time_changed.emit(hour)

func set_weather(new_weather: String) -> bool:
    if new_weather not in weather_types:
        return false
    weather = new_weather
    weather_changed.emit(weather)
    return true

func random_weather() -> String:
    weather = weather_types[randi() % weather_types.size()]
    weather_changed.emit(weather)
    return weather

func get_time_text() -> String:
    var h := int(hour)
    var m := int((hour - h) * 60.0)
    return "%02d:%02d" % [h, m]

func is_night() -> bool:
    return hour < 6.0 or hour >= 20.0

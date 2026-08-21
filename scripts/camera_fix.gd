extends Node

func _ready() -> void:
    call_deferred("_fix_cameras")

func _fix_cameras() -> void:
    await get_tree().process_frame
    await get_tree().process_frame
    var scene := get_tree().current_scene
    if scene == null:
        return
    var cameras := scene.find_children("*", "Camera3D", true, false)
    for node in cameras:
        if node is Camera3D:
            node.rotation_degrees = Vector3(-12.0, 0.0, 0.0)
    var player_camera := scene.find_child("Camera3D", true, false)
    if player_camera is Camera3D:
        player_camera.current = true
    elif not cameras.is_empty() and cameras[0] is Camera3D:
        cameras[0].current = true

extends Node3D
class_name WorldStreamer

# Master-world target: 1200 km x 1200 km.
# We never create the entire world as one scene. Chunks are loaded around the player.
const WORLD_SIZE_KM := 1200.0
const WORLD_SIZE_METERS := WORLD_SIZE_KM * 1000.0
const CHUNK_SIZE_METERS := 1000.0
@export var active_radius_chunks := 2

var loaded_chunks: Dictionary = {}
var player: Node3D

func initialize(player_node: Node3D) -> void:
    player = player_node
    update_streaming()

func _process(_delta: float) -> void:
    if player:
        update_streaming()

func update_streaming() -> void:
    var center := _world_to_chunk(player.global_position)
    for x in range(center.x - active_radius_chunks, center.x + active_radius_chunks + 1):
        for z in range(center.y - active_radius_chunks, center.y + active_radius_chunks + 1):
            var key := Vector2i(x, z)
            if _inside_world(key) and not loaded_chunks.has(key):
                _load_chunk(key)

    for key in loaded_chunks.keys():
        if abs(key.x - center.x) > active_radius_chunks or abs(key.y - center.y) > active_radius_chunks:
            _unload_chunk(key)

func _world_to_chunk(pos: Vector3) -> Vector2i:
    return Vector2i(floor(pos.x / CHUNK_SIZE_METERS), floor(pos.z / CHUNK_SIZE_METERS))

func _inside_world(chunk: Vector2i) -> bool:
    var half := int(WORLD_SIZE_METERS / CHUNK_SIZE_METERS / 2.0)
    return chunk.x >= -half and chunk.x < half and chunk.y >= -half and chunk.y < half

func _load_chunk(key: Vector2i) -> void:
    var chunk := Node3D.new()
    chunk.name = "Chunk_%d_%d" % [key.x, key.y]
    chunk.position = Vector3(key.x * CHUNK_SIZE_METERS, 0, key.y * CHUNK_SIZE_METERS)
    add_child(chunk)
    loaded_chunks[key] = chunk

func _unload_chunk(key: Vector2i) -> void:
    var chunk: Node3D = loaded_chunks[key]
    if is_instance_valid(chunk):
        chunk.queue_free()
    loaded_chunks.erase(key)

func get_world_size_km() -> float:
    return WORLD_SIZE_KM

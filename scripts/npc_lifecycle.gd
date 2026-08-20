extends Node
class_name NPCLifecycle

@export var max_active_npcs := 1000
@export var simulation_distance := 90.0

func should_simulate(npc: Node3D, player: Node3D) -> bool:
    if npc == null or player == null:
        return false
    return npc.global_position.distance_to(player.global_position) <= simulation_distance

func configure_npc(npc: Node3D, index: int) -> void:
    npc.set_meta("npc_id", index)
    npc.set_meta("ban_eligible", false)
    npc.set_meta("is_npc", true)
    npc.set_meta("alive", true)
    npc.set_meta("daily_routine", true)

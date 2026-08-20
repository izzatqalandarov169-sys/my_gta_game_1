extends Node
class_name MultiplayerSystem

@export var max_players := 32
var peer: ENetMultiplayerPeer
var connected_players: Dictionary = {}

func host(port: int = 24500) -> int:
    peer = ENetMultiplayerPeer.new()
    var error := peer.create_server(port, max_players)
    if error == OK:
        multiplayer.multiplayer_peer = peer
    return error

func join(address: String, port: int = 24500) -> int:
    peer = ENetMultiplayerPeer.new()
    var error := peer.create_client(address, port)
    if error == OK:
        multiplayer.multiplayer_peer = peer
    return error

func disconnect_session() -> void:
    multiplayer.multiplayer_peer = null
    connected_players.clear()

extends Node

var IPAddress = "127.0.0.1"
var port = 8910
var peer
@export var player_scene : PackedScene
func _ready():
	multiplayer.peer_connected.connect(Peer)
	multiplayer.peer_disconnected.connect(Peer)
	multiplayer.connected_to_server.connect(PrintTest)
	multiplayer.connection_failed.connect(PrintTest)

#server only
func Peer(id):
	print("Peer Interaction"+str(id))

#client only	
func PrintTest():
	print("YES")
	
func host():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port,5)
	if error!=OK:
		print("FAIL")
		return
	print("PLAYERS?")
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	#multiplayer.peer_connected.connect(PrintTest)
	#printTest()

func join():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(IPAddress,port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	
func add_mock_player(id = 1):
	var player = player_scene.instantiate()

func setup():
	

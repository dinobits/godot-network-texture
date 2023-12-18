class_name UDPImageServer
extends NetworkTextureServer
## Note that UDP does not allow big packages and should not be used
## for huge file transfer. Check your max packet size and make sure that image
## received is less then that.

@export var port := 9081
@export var config: CodeConfig

var server := UDPServer.new()
var peers: Array[PacketPeerUDP] = []

var _cache: PackedByteArray

func _ready():
	server.listen(port)
	NetworkTextureServerManager.register_server_callback(
		config.code,
		func (code: String) -> Image:
			return config.decoder.decode(_cache)
	)

func _process(delta):
	server.poll()
	if server.is_connection_available():
		var peer: PacketPeerUDP = server.take_connection()
		while peer.get_available_packet_count() > 0:
			_cache = peer.get_packet()
			print(_cache)

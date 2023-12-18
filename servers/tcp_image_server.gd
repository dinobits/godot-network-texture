class_name TCPImageServer
extends NetworkTextureServer
## Self protocol. Every image begins with first 4 bytes being its size in bytes.
## Basically it's how many bytes to read.

@export var port := 9082
@export var config: CodeConfig

var server := TCPServer.new()
var peers: Array[StreamPeerTCP] = []

var _cache: PackedByteArray

func _ready():
	server.listen(port)
	NetworkTextureServerManager.register_server_callback(
		config.code,
		func (code: String) -> Image:
			return config.decoder.decode(_cache)
	)

func _process(delta):
	if server.is_connection_available():
		var peer: StreamPeerTCP = server.take_connection()
		print("New peer! Status: %s" %peer.get_status())
		peers.append(peer)

	for peer in peers:
		peer.poll()
		match peer.get_status():
			StreamPeerTCP.STATUS_NONE:
				var index = peers.find(peer)
				peers.pop_at(index)
				peer.disconnect_from_host()
				print("Removed peer! Current cout: %d" %peers.size())
				continue
			StreamPeerTCP.STATUS_CONNECTED:
				var size = peer.get_32()
				var image_data = peer.get_data(size)
				if image_data[0] == 0:
					_cache = image_data[1]
				else:
					printerr(
						"Error receiving image! Error: %d; Image size: %d"
						%[image_data[0], size]
					)

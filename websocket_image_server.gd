extends Node

signal image_data_received(code: String, byte_array: PackedByteArray)

var _sockets: Dictionary = {}


const PORT = 9080
var _server = TCPServer.new()


func _ready():
	if _server.listen(PORT) != OK:
		printerr("Could not start the server")
		set_process(false)
	else:
		print("Server should be started")

func _process(_delta):
	_check_connection()

	for socket in _sockets.keys():
		_poll(socket)
		
func _check_connection():
	while _server.is_connection_available():
		print("Receiving the connection")
		var conn: StreamPeerTCP = _server.take_connection()
		assert(conn != null)
		var socket = WebSocketPeer.new()
		socket.inbound_buffer_size = 65535 * 8
		socket.accept_stream(conn)
		_add_socket(socket)


func _poll(socket: WebSocketPeer):
	socket.poll()
	var count = socket.get_available_packet_count()
	if count > 1:
		print("Packet count is bigger than 1 (%d). Max packets: %d"
				%[count, socket.max_queued_packets])
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		var packet: PackedByteArray
		while socket.get_available_packet_count():
			packet = socket.get_packet()

		if (packet):
			image_data_received.emit(_sockets[socket], packet)
	else:
		if _sockets.has(socket):
			_sockets.erase(socket)
		else:
			printerr("socket was not added to the list")
		printerr("Socket is not OPEN")

func _add_socket(socket: WebSocketPeer, count: int = 0) -> void:
	socket.poll()
	var state = socket.get_ready_state()
	print("Add socket: state: %d %d" %[socket.get_ready_state(), count])
	if (state == WebSocketPeer.STATE_CONNECTING):
		call_deferred("_add_socket", socket, count + 1)
		return

	var url = socket.get_requested_url()
	if url == "":
		print("Url not set yet ... %s" %url)
		call_deferred("_add_socket", socket, count + 1)
		return
	print("Adding socket with URL: %s" %url)
	_sockets[socket] = _get_code(url)

func _get_code(url: String) -> String:
	var i = url.find("/", 7)
	return url.substr(i+1)

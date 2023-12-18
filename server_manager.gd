extends Node

signal image_data_received(code: String, byte_array: PackedByteArray)


var servers: Dictionary = {}
var _textures: Array[NetworkTexture] = []
var _codes: Dictionary = {}

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	# Every frame update all network pictures from buffer
	for texture in _textures:
		var code = texture.image_code
		if _codes.has(code):
			var image = _codes[code].call(code)
			if image:
				texture.set_image(image)


func register_server_callback(code: String, create_image: Callable) -> void:
	_codes[code] = create_image

func register_texture(texture: NetworkTexture) -> void:
	_textures.push_back(texture)

class_name NetworkTexture
extends ImageTexture

enum ReceivingImageType {PNG, JPEG, AUTO}
@export var receiving_image_type: ReceivingImageType
@export var is_base64_encoded: bool = true
@export var default: Texture2D
## Texture code to be updated with
@export var image_code: String

var _create_image_from_any: Callable
var _base64_prefix: String = "data:image/png;base64,"
var _image: Image


func _init() -> void:
	call_deferred("_ready") # To have default image shown. Othervise pink

func _ready() -> void:
	print("Network texture initialized: %s; 
		Type: %s;
		Is base64: %s" %[
				image_code,
				ReceivingImageType.keys()[receiving_image_type],
				is_base64_encoded
		]
	)
	NetworkTextureServerManager.register_texture(self)
	_set_image()
#var _first = true
#func update(image: Image) -> void:
	##if not _first:
		##super.update(image)
		##return
	##_first = false
	#print(get_size())
	#super.set_image(image)

func _set_image():
	_image = Image.new()
	var create_image: Callable
	match receiving_image_type:
		ReceivingImageType.PNG:
			create_image = func (byte_array: PackedByteArray) -> void:
				var error = _image.load_png_from_buffer(byte_array)
				if error != OK:
					printerr("ERROR: %s" %error)
			_base64_prefix = "data:image/png;base64,"
		ReceivingImageType.JPEG:
			create_image =  func (byte_array: PackedByteArray) -> void:
				var error = _image.load_jpg_from_buffer(byte_array)
				if error != OK:
					printerr("ERROR: %s" %error)
			_base64_prefix = "data:image/jpeg;base64,"
		_:
			create_image =  func (byte_array: PackedByteArray) -> void:
				var jpg := PackedByteArray([255,216,255,224])
				var png := PackedByteArray([137,80,78,71])
				var webp := PackedByteArray([82,73,70,70])
				var buffer = byte_array.slice(0, 3)
				match buffer:
					jpg:
						_image.load_jpg_from_buffer(byte_array)
					png:
						_image.load_png_from_buffer(byte_array)
					webp:
						_image.load_webp_from_buffer(byte_array)
					_:
						printerr("Could not guess image type")

	if is_base64_encoded:
		_create_image_from_any = func (byte_array: PackedByteArray):
			var base64 = byte_array.get_string_from_ascii()
			create_image.call(_base64_to_byte_array(base64))
	else:
		_create_image_from_any = create_image

	if default:
		set_image(default.get_image())

	NetworkTextureServerManager.image_data_received.connect(_on_image_received_first_time)

func _on_image_received_first_time(code: String, byte_array: PackedByteArray) -> void:
	if not _update_image_cache(code, byte_array):
		return
	set_image(_image)
	NetworkTextureServerManager.image_data_received.disconnect(_on_image_received_first_time)
	NetworkTextureServerManager.image_data_received.connect(_on_image_received)


func _on_image_received(code: String, byte_array: PackedByteArray) -> void:
	print(image_code + "image received not first")
	_update_image_cache(code, byte_array)
#	_image.save_png("res://assets/" + image_code + ".png")
	update(_image)


func _update_image_cache(code: String, byte_array: PackedByteArray) -> bool:
	print("Image code: %s; Code received: %s" %[image_code, code])
	if image_code != code:
		return false
	_create_image_from_any.call(byte_array)
	return true


func _base64_to_byte_array(base64: String) -> PackedByteArray:
	var str = base64.trim_prefix(_base64_prefix)
	return Marshalls.base64_to_raw(str)

class_name ImageDecoder
extends Resource


## prefix for base64 encoded image # TODO: Add link to wiki
const BASE64_PREFIX_PNG: String = "data:image/png;base64,"
const BASE64_PREFIX_JPEG: String = "data:image/png;base64,"

enum ImageType {PNG, JPEG, AUTO}

@export var image_type: ImageType:
	set(value):
		image_type = value
		_ready()
@export var is_base64_encoded: bool = true:
	set(value):
		is_base64_encoded = value
		_ready()
@export var default: Texture2D:
	set(value):
		default = value
		_ready()

var _prefix = ''
var _callable: Callable


func _init() -> void:
	call_deferred("_ready")

func _ready() -> void:
	_callable = _build_pipe()

func decode(byte_array: PackedByteArray) -> Image:
	if not byte_array:
		return default.get_image() if default else null
	return _callable.call(byte_array)

func _build_pipe() -> Callable:
	var decoder := _build_decoder(image_type)
	if is_base64_encoded:
		_prefix = _get_prefix_for_type(image_type)
		_callable = func (byte_array: PackedByteArray) -> Image:
			var base64 = byte_array.get_string_from_ascii()
			var trimmed_byte_array = _base64_to_byte_array(base64)
			return decoder.call(trimmed_byte_array)
	else:
		_callable = func (byte_array: PackedByteArray) -> Image:
			return decoder.call(byte_array)
	return _callable

func _build_decoder(type: ImageType) -> Callable:
	var image = Image.new()
	match type:
		ImageType.PNG:
			return func (byte_array: PackedByteArray) -> Image:
				var error = image.load_png_from_buffer(byte_array)
				if error != OK:
					printerr("ERROR: %s" %error)
				return image
		ImageType.JPEG:
			return func (byte_array: PackedByteArray) -> Image:
				var error = image.load_jpg_from_buffer(byte_array)
				if error != OK:
					printerr("ERROR: %s" %error)
				return image
		_:
			return func (byte_array: PackedByteArray) -> Image:
				var jpg := PackedByteArray([255,216,255,224])
				var png := PackedByteArray([137,80,78,71])
				var webp := PackedByteArray([82,73,70,70])
				var buffer = byte_array.slice(0, 3)
				match buffer:
					jpg:
						image.load_jpg_from_buffer(byte_array)
					png:
						image.load_png_from_buffer(byte_array)
					webp:
						image.load_webp_from_buffer(byte_array)
					_:
						printerr("Could not guess image type")
				return image

func _get_prefix_for_type(type: ImageType) -> String:
	match type:
		ImageType.PNG:
			return BASE64_PREFIX_PNG
		ImageType.JPEG:
			return BASE64_PREFIX_JPEG
		_:
			return ''

func _base64_to_byte_array(base64: String) -> PackedByteArray:
	var str = base64.trim_prefix(_prefix)
	return Marshalls.base64_to_raw(str)

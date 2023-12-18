extends RefCounted

enum Type{PNG, JPEG, AUTO}

var byte_array: PackedByteArray = []
var is_base64: bool = false
var type: Type = Type.AUTO

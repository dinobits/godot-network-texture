@tool
extends EditorPlugin


const AUTOLOAD_NAME = "NetworkTextureServerManager"


func _enter_tree():
	add_custom_type(
			"NetworkTexture",
			"ImageTexture",
			preload("res://addons/network_texture/network_texture.gd"),
			null)
	add_autoload_singleton(
			AUTOLOAD_NAME,
			"res://addons/network_texture/server_manager.gd"
		)


func _exit_tree():
	remove_autoload_singleton(AUTOLOAD_NAME)
	remove_custom_type("NetworkTexture")

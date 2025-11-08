extends Control

@onready var host_button: Button = $HBoxContainer/HostButton
@onready var join_button: Button = $HBoxContainer/JoinButton

const main_scene: PackedScene = preload("uid://q6hvr2r8w212")
const PORT := 4242

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	host_button.pressed.connect(_on_host_button_pressed)
	join_button.pressed.connect(_on_join_button_pressed)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	

func _on_host_button_pressed() -> void:
	print("Host button pressed")
	var server_peer := ENetMultiplayerPeer.new()
	server_peer.create_server(PORT)
	multiplayer.multiplayer_peer = server_peer
	get_tree().change_scene_to_packed(main_scene)

func _on_join_button_pressed() -> void:
	print("Join button pressed")
	var client_peer := ENetMultiplayerPeer.new()
	client_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = client_peer

func _on_connected_to_server() -> void:
	get_tree().change_scene_to_packed(main_scene)

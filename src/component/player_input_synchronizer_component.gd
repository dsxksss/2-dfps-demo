class_name PlayerInputSynchronizerComponent
extends MultiplayerSynchronizer

@export var aim_root: Node2D

var movement_vector: Vector2 = Vector2.ZERO
var aim_vector: Vector2 = Vector2.RIGHT

func _process(_delta: float) -> void:
	if is_multiplayer_authority():
		gather_input()

func gather_input() -> void:
	movement_vector = Input.get_vector("player_left", "player_right", "player_up", "player_down")
	aim_vector = aim_root.global_position.direction_to(aim_root.get_global_mouse_position())
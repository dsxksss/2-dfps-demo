class_name PlayerInputSynchronizerComponent
extends MultiplayerSynchronizer

var movement_vector: Vector2 = Vector2.ZERO

func _process(_delta: float) -> void:
	if is_multiplayer_authority():
		gather_input()

func gather_input() -> void:
	movement_vector = Input.get_vector("player_left", "player_right", "player_up", "player_down")

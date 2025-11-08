extends CharacterBody2D

const SPEED = 300.0

func _physics_process(delta: float) -> void:
	var movement_vector = Input.get_vector("player_left", "player_right", "player_up", "player_down")
	velocity = movement_vector * SPEED
	move_and_slide()

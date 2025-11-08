class_name Player
extends CharacterBody2D

@onready var player_input_synchronizer_component: PlayerInputSynchronizerComponent = $PlayerInputSynchronizerComponent

var input_multiplayer_authority: int

const SPEED = 300.0

func _ready() -> void:
	player_input_synchronizer_component.set_multiplayer_authority(input_multiplayer_authority)
	set_process(is_multiplayer_authority())

func _process(_delta: float) -> void:
	velocity = player_input_synchronizer_component.movement_vector * SPEED
	move_and_slide()

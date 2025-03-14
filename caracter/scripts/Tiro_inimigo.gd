extends Area2D

var direcao = Vector2.ZERO
@export var velocidade = 800
var dano = 1

func _ready() -> void:
	set_process(true)

func _process(delta: float) -> void:
	global_position += direcao.normalized() * velocidade * delta

func _on_Tiro_inimigo_body_entered(body: Node2D) -> void:
	if body.name == "Charizard":
		body.player_damage()
	

func _on_VisibilityNotifier2D_screen_exited() -> void:
	queue_free()

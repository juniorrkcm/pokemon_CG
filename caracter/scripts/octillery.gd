extends CharacterBody2D
class_name Octillery

@export var _animation: AnimationPlayer = null
@export var velocidade = 20
@export var velocidade_tiro = 10
@export var dano = 1
var direcao = Vector2.ZERO
var andando = true
var pode_atirar = true
var player_ref = null

# Variáveis para controle de dano e direção
var _is_hurt: bool = false
var _last_direction: Vector2 = Vector2.ZERO

var direcoes_possiveis = [
	Vector2(0, 1),    # baixo
	Vector2(0, -1),   # cima
	Vector2(-1, 0),   # esquerda
	Vector2(1, 0),    # direita
	Vector2(1, 1),    # baixo-direita
	Vector2(-1, 1),   # baixo-esquerda
	Vector2(1, -1),   # cima-direita
	Vector2(-1, -1),  # cima-esquerda
]

var tiro = preload("res://caracter/scenes/Tiro_inimigo.tscn")

func _ready() -> void:
	# Adiciona o Octillery ao grupo "enemy" para ser reconhecido pelo Charizard
	add_to_group("enemy")
	set_physics_process(true)
	escolher_nova_direcao()

func _physics_process(delta: float) -> void:
	# Se o inimigo está em hurt, não faz nada de animação/movimento
	if _is_hurt:
		return

	if player_ref:
		velocity = Vector2.ZERO
		if pode_atirar:
			atirar()
	else:
		velocity = direcao.normalized() * velocidade
		_last_direction = direcao.normalized()
		move_and_slide()
	
	_set_animation()

func escolher_nova_direcao() -> void:
	direcao = direcoes_possiveis.pick_random()
	andando = true
	$Timer_para_andar.start(randf_range(1.0, 3.0))

func _set_animation():
	var anim = "walk_down"

	if player_ref:
		var direction = global_position.direction_to(player_ref.global_position)
		anim = get_attack_animation(direction)
	else:
		anim = get_walk_animation(direcao)

	if $Animation.assigned_animation != anim:
		$Animation.play(anim)

func get_walk_animation(direction: Vector2) -> String:
	if direction == Vector2(0, 1): return "walk_down"
	elif direction == Vector2(0, -1): return "walk_up"
	elif direction == Vector2(-1, 0): return "walk_left"
	elif direction == Vector2(1, 0): return "walk_right"
	elif direction == Vector2(1, 1): return "walk_down_right"
	elif direction == Vector2(-1, 1): return "walk_down_left"
	elif direction == Vector2(1, -1): return "walk_up_right"
	elif direction == Vector2(-1, -1): return "walk_up_left"
	return "walk_down"

func get_attack_animation(direction: Vector2) -> String:
	if direction.x > 0.5 and abs(direction.y) < 0.5: return "attack_right"
	elif direction.x < -0.5 and abs(direction.y) < 0.5: return "attack_left"
	elif direction.y > 0.5 and abs(direction.x) < 0.5: return "attack_down"
	elif direction.y < -0.5 and abs(direction.x) < 0.5: return "attack_up"
	elif direction.x > 0.5 and direction.y > 0.5: return "attack_down_right"
	elif direction.x < -0.5 and direction.y > 0.5: return "attack_down_left"
	elif direction.x > 0.5 and direction.y < -0.5: return "attack_up_right"
	elif direction.x < -0.5 and direction.y < -0.5: return "attack_up_left"
	return "attack_down"

func atirar():
	var tiro_instance = tiro.instantiate()
	get_parent().add_child(tiro_instance)
	
	tiro_instance.global_position = global_position
	tiro_instance.direcao = global_position.direction_to(player_ref.global_position)
	tiro_instance.velocidade = velocidade_tiro
	tiro_instance.dano = dano

	pode_atirar = false
	$Tiro_Delay.start()

# Detecção do Charizard para definir o player_ref
func _on_DetectionArea_body_entered(body: Node2D) -> void:
	if body.name == "Charizard":
		player_ref = body

func _on_DetectionArea_body_exited(body: Node2D) -> void:
	if body.name == "Charizard":
		player_ref = null

func _on_timer_para_andar_timeout() -> void:
	escolher_nova_direcao()

func _on_Tiro_Delay_timeout() -> void:
	pode_atirar = true

# Função para receber dano do Charizard
func update_health() -> void:
	_is_hurt = true
	
	var direction = _last_direction.normalized()
	
	if direction.x > 0.5 and abs(direction.y) < 0.5:
		_animation.play("hurt_right")
	elif direction.x < -0.5 and abs(direction.y) < 0.5:
		_animation.play("hurt_left")
	elif direction.y > 0.5 and abs(direction.x) < 0.5:
		_animation.play("hurt_down")
	elif direction.y < -0.5 and abs(direction.x) < 0.5:
		_animation.play("hurt_up")
	elif direction.x > 0.5 and direction.y > 0.5:
		_animation.play("hurt_down_right")
	elif direction.x < -0.5 and direction.y > 0.5:
		_animation.play("hurt_down_left")
	elif direction.x > 0.5 and direction.y < -0.5:
		_animation.play("hurt_up_right")
	elif direction.x < -0.5 and direction.y < -0.5:
		_animation.play("hurt_up_left")

func _on_animation_finished(anim: String) -> void:
	queue_free()

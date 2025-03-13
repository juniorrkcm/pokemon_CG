extends CharacterBody2D
class_name Wurmple

var _is_hurt: bool = false
var _player_ref = null
var _last_direction := Vector2.ZERO  # Direção padrão inicial
var _can_attack: bool = true  # Para evitar que o inimigo ataque infinitamente

@export_category("Objects")
#@export var _texture: Sprite2D = null
@export var _animation: AnimationPlayer = null
@export var _attack_timer: Timer = null  # Timer para cooldown do ataque

func _ready() -> void:
	if _attack_timer:
		_attack_timer.timeout.connect(_on_attack_timer_timeout)  # Conecta o timer para resetar ataques

func _on_detection_area_body_entered(_body) -> void:
	if _body.is_in_group("charizard"):
		_player_ref = _body

func _on_detection_area_body_exited(_body) -> void:
	if _body.is_in_group("charizard"):
		_player_ref = null

func _physics_process(_delta: float) -> void:
	if _is_hurt:
		return
	_animate()
	if _player_ref != null:
		var _direction: Vector2 = global_position.direction_to(_player_ref.global_position)
		var _distance: float = global_position.distance_to(_player_ref.global_position)
		
		# Se o Charizard estiver muito perto e o ataque estiver disponível, ele recebe dano
		if _distance < 20 and _can_attack and not _player_ref._is_hurt:
			_player_ref.take_damage()  # Aplica dano no Charizard
			_can_attack = false  # Impede novos ataques até o cooldown acabar
			if _attack_timer:
				_attack_timer.start()  # Inicia o cooldown do ataque
		
		velocity = _direction * 40

		if velocity.length() > 0:
			_last_direction = velocity.normalized()  # Atualiza a última direção quando se move
			
		move_and_slide()
	else:
		velocity = Vector2.ZERO  # Para parar o inimigo caso o player saia do alcance

	_animate()

func _animate() -> void:
	if _is_hurt:
		return
	
	if velocity.length() > 0:
		_play_walk_animation()
	else:
		_play_idle_animation()

func _play_walk_animation() -> void:
	var direction = velocity.normalized()
	
	if direction.x > 0.5 and abs(direction.y) < 0.5:
		_animation.play("walk_right")
	elif direction.x < -0.5 and abs(direction.y) < 0.5:
		_animation.play("walk_left")
	elif direction.y > 0.5 and abs(direction.x) < 0.5:
		_animation.play("walk_down")
	elif direction.y < -0.5 and abs(direction.x) < 0.5:
		_animation.play("walk_up")
	elif direction.x > 0.5 and direction.y > 0.5:
		_animation.play("walk_down_right")
	elif direction.x < -0.5 and direction.y > 0.5:
		_animation.play("walk_down_left")
	elif direction.x > 0.5 and direction.y < -0.5:
		_animation.play("walk_up_right")
	elif direction.x < -0.5 and direction.y < -0.5:
		_animation.play("walk_up_left")

func _play_idle_animation() -> void:
	var idle_animation = ""

	if abs(_last_direction.x) > abs(_last_direction.y):
		if _last_direction.x > 0:
			idle_animation = "idle_right"
		else:
			idle_animation = "idle_left"
	else:
		if _last_direction.y > 0:
			idle_animation = "idle_down"
		else:
			idle_animation = "idle_up"

	_animation.play(idle_animation)

# Reseta o ataque após o cooldown
func _on_attack_timer_timeout() -> void:
	_can_attack = true

func update_health() -> void:
	_is_hurt = true
	
	var direction =  _last_direction.normalized()
	
	
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

func _on_animation_finished(_anim_name: String) -> void:
	queue_free()

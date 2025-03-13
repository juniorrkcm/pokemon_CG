extends CharacterBody2D
class_name Charizard

var _state_machine
var _is_hurt: bool = false
var _is_attacking: bool = false
var _last_direction := Vector2.DOWN  # Direção padrão inicial

@export_category("Variables")
@export var _move_speed: float = 64.0
@export var _friction: float = 0.2
@export var _acceleration: float = 0.2

@export_category("Objects")
@export var _attack_timer: Timer = null
@export var _hurt_timer: Timer = null  # Timer para recuperação do hurt
@export var _animation_tree : AnimationTree = null

func _ready() -> void:
	_animation_tree.active = true
	_state_machine = _animation_tree["parameters/playback"]

func _physics_process(_delta: float) -> void:
	_move()
	_attack()
	_animate()
	move_and_slide()

func _move() -> void:
	if _is_hurt:  # Se estiver machucado, não pode se mover
		return

	var _direction: Vector2 = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)

	if _direction != Vector2.ZERO:
		_direction = _direction.normalized()
		_last_direction = _direction.normalized()  # Atualiza sempre a última direção válida
		_animation_tree["parameters/idle/blend_position"] = _direction
		_animation_tree["parameters/walk/blend_position"] = _direction
		_animation_tree["parameters/attack/blend_position"] = _direction
		_animation_tree["parameters/hurt/blend_position"] = _direction

		velocity.x = lerp(velocity.x, _direction.x * _move_speed, _acceleration)
		velocity.y = lerp(velocity.y, _direction.y * _move_speed, _acceleration)
		return
	
	velocity.x = lerp(velocity.x, 0.0, _friction)
	velocity.y = lerp(velocity.y, 0.0, _friction)

func _attack() -> void:
	if Input.is_action_just_pressed("attack") and not _is_attacking:
		set_physics_process(false)
		_attack_timer.start()
		_is_attacking = true

func _animate() -> void:
	if _is_hurt:
		_state_machine.travel("hurt")  # Define a animação correta
		return
	
	if _is_attacking:
		_state_machine.travel("attack")
		return
	
	if velocity.length() > 1:
		_last_direction = velocity.normalized()  # Atualiza a última direção válida
		_state_machine.travel("walk")
		return

	_state_machine.travel("idle")

func take_damage():
	if _is_hurt:  # Se já está em hurt, não toma dano de novo
		return
	
	_is_hurt = true
	_state_machine.travel("hurt")  # Garante que a animação certa seja tocada

	if _hurt_timer:
		_hurt_timer.start()

func _on_attack_timer_timeout() -> void:
	set_physics_process(true)
	_is_attacking = false

func _on_attack_area_body_entered(_body) -> void:
	if _body.is_in_group("enemy"):
		_body.update_health()

func _on_hurt_timer_timeout() -> void:
	_is_hurt = false  # Após o tempo de hurt, volta ao normal

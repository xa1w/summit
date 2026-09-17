extends CharacterBody2D

signal died

const SPEED = 400.0
const RUN_SPEED = 800.0
const JUMP_VELOCITY = -1000.0
const STEP_INTERVAL = 0.34

const SFX_JUMP = preload("res://sfx/jump.wav")
const SFX_LAND = preload("res://sfx/land.wav")
const SFX_STEP = preload("res://sfx/step.ogg")
const SFX_HURT = preload("res://sfx/hurt.wav")

@onready var animated_sprite = $AnimatedSprite2D
@onready var camera = $Camera2D
@onready var sfx = $Sfx
@onready var step_sfx = $StepSfx

var start_position: Vector2
var dead = false
var was_on_floor = true
var step_timer = 0.0


func _ready():
	start_position = global_position


func _physics_process(delta: float) -> void:
	if dead:
		return

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Fell into a pit
	if global_position.y > 1400:
		die()
		return

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		play(SFX_JUMP)

	# Movement
	var direction := Input.get_axis("left", "right")
	var running := Input.is_action_pressed("run")

	if direction:
		velocity.x = direction * (RUN_SPEED if running else SPEED)
		animated_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Animations
	if not is_on_floor():
		animated_sprite.play("jump" if velocity.y < 0 else "fall")
	elif direction:
		animated_sprite.play("run" if running else "walk")
	else:
		animated_sprite.play("Idle")

	# Footsteps
	if is_on_floor() and direction:
		step_timer -= delta
		if step_timer <= 0.0:
			step_sfx.stream = SFX_STEP
			step_sfx.play()
			step_timer = STEP_INTERVAL * (0.55 if running else 1.0)
	else:
		step_timer = 0.0

	# MOVE THE PLAYER
	move_and_slide()

	# Landing
	if is_on_floor() and not was_on_floor:
		play(SFX_LAND)
	was_on_floor = is_on_floor()


func play(stream):
	sfx.stream = stream
	sfx.play()


func die():
	if dead:
		return

	dead = true
	velocity = Vector2.ZERO
	play(SFX_HURT)
	died.emit()


func respawn():
	global_position = start_position
	velocity = Vector2.ZERO
	dead = false
	was_on_floor = true
	camera.reset_smoothing()

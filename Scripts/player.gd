extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
var bullet = preload("res://Scenes/bullet.tscn")
@onready var muzzle: Marker2D = $Marker2D


const GRAVITY = 1000
const SPEED = 600
const MAX_HORIZONTAL_SPEED = 200

const JUMP = -400
const JUMP_HORIZONTAL_SPEED = 1000
const MAX_JUMP_HORIZONTAL_SPEED = 200


enum State {Idle,Run,Jump,Shoot,Shoot_Idle}

var current_state
var muzzle_position
var projectile_cd = true


func _ready():
	var current_state = State.Idle
	muzzle_position = muzzle.position

func _process(delta):
	player_falling(delta)
	player_idle(delta)
	player_run(delta)
	player_jump(delta)
	
	player_shooting(delta)
	player_muzzle_position()
		
	move_and_slide()
	player_animations()

	
func player_falling(delta):
	if !is_on_floor():
		velocity.y += GRAVITY * delta
		
func player_idle(delta):
	if is_on_floor():
		current_state = State.Idle
	
func player_run(delta):
	var direction = Input.get_axis("move_left","move_right")
	
	if direction:
		velocity.x += direction * SPEED
		velocity.x = clamp(velocity.x, -MAX_HORIZONTAL_SPEED,MAX_HORIZONTAL_SPEED)
	else:
		velocity.x = move_toward(velocity.x,0,SPEED)
	if direction != 0 and is_on_floor():
		current_state = State.Run
		animated_sprite_2d.flip_h = false if direction > 0 else true
		

func player_jump(delta : float):	
	if is_on_floor() and Input.is_action_just_pressed("move_up"):
		$SoundJump.play()
		velocity.y = JUMP
		current_state = State.Jump
		

	if !is_on_floor() and current_state == State.Jump:
		var direction = Input.get_axis("move_left","move_right")
		velocity.x += direction * JUMP_HORIZONTAL_SPEED * delta
		velocity.x = clamp(velocity.x, -MAX_JUMP_HORIZONTAL_SPEED,MAX_JUMP_HORIZONTAL_SPEED)
		
		
func player_shooting(delta):
	var direction = Input.get_axis("move_left","move_right")
	if direction != 0 and Input.is_action_pressed("shoot") and projectile_cd:
		$SoundShoot.play()
		projectile_cd = false
		var bullet_instance = bullet.instantiate() as Node2D
		bullet_instance.direction = direction
		bullet_instance.global_position = muzzle.global_position
		get_parent().add_child(bullet_instance)
		current_state = State.Shoot
		
		await get_tree().create_timer(0.2).timeout
		projectile_cd = true
		
	elif direction == 0 and Input.is_action_pressed("shoot") and projectile_cd:
		$SoundShoot.play()
		projectile_cd = false
		var bullet_instance = bullet.instantiate() as Node2D
		if animated_sprite_2d.flip_h == true:
			bullet_instance.direction = -1
		else:
			bullet_instance.direction = 1
		bullet_instance.global_position = muzzle.global_position
		get_parent().add_child(bullet_instance)
		current_state = State.Shoot_Idle
		
		await get_tree().create_timer(0.2).timeout
		projectile_cd = true
		

func player_muzzle_position():
	var direction = Input.get_axis("move_left","move_right")
	if direction > 0:
		muzzle.position.x = muzzle_position.x
	elif direction < 0:
		muzzle.position.x = -muzzle_position.x
	
func player_animations():
	if current_state == State.Idle and !Input.is_action_pressed("shoot"):
		animated_sprite_2d.play("Idle")
	elif current_state == State.Run and animated_sprite_2d.animation != "Shot":
		animated_sprite_2d.play("Run")
	elif current_state == State.Jump:
		animated_sprite_2d.play("Jump")
	elif current_state == State.Shoot:
		animated_sprite_2d.play("Shot")
	elif current_state == State.Shoot_Idle and Input.is_action_pressed("shoot"):
		animated_sprite_2d.play("Shot_Idle")
	
func _on_final_body_entered(body):
	if body.get_name() == "Player":
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")


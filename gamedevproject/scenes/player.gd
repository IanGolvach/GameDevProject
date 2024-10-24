extends CharacterBody3D

var current_state=player_states.MOVE
enum player_states {MOVE, JUMP, SWORD, FALLING}

@export var speed:= 200
@export var gravity:= 9.8
@export var jump_force := 8.0

@onready var player_body = $"."
@onready var anim = $AnimationPlayer
@onready var camera = $"../cam_gimbal"
@onready var anim_tree = $AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback")
var angular_speed = 10


var movement
var direction
var sprint_speed = 10.0

func _physics_process(delta):
	match current_state:
		player_states.MOVE:
			move(delta)
		#player_states.SWORD:
			#sword(delta)
		player_states.JUMP:
			jump()
		player_states.FALLING:
			falling(delta)

func _input(event):
	#if Input.is_action_just_pressed("ui_sword"):
		#current_state=player_states.SWORD
	if Input.is_action_just_pressed("ui_accept"):
		#current_state = player_states.JUMP
		jump()

func anim_set():
	anim_tree.set("parameters/air_state/start_jump/blend_position", movement)
	anim_tree.set("parameters/attack_state/sword/blend_position", movement)
	anim_tree.set("parameters/ground_state/idle_passive/blend_position", movement)
	anim_tree.set("parameters/ground_state/walk_passive/blend_position", movement)
	anim_tree.set("parameters/ground_state/running/blend_position", movement)
	anim_tree.set("parameters/damage_state/hurt/blend_position", movement)

func move(delta):
	movement = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	#direction = (transform.basis * Vector3(movement.x, 0, movement.y)).normalized()
	direction = Vector3(movement.x, 0, movement.y).rotated(Vector3.UP, camera.rotation.y).normalized()
	var sprint = false
	
	if Input.is_action_pressed("ui_sprint"):
		sprint = true
	if Input.is_action_just_released("ui_sprint"):
		sprint = false
	
	if direction && sprint == false:
		anim_set()
		#anim.play("Walk")
		#anim_tree["parameters/ground_state/conditions/moving"] = true
		anim_state.travel("ground_state/walk_passive")
		velocity.x = direction.x * speed * delta
		velocity.z = direction.z * speed * delta
		player_body.rotation.y = lerp_angle(player_body.rotation.y, atan2(velocity.x, velocity.z), delta * angular_speed)
	elif direction && sprint == true:
		#anim.play("Run")
		anim_tree["parameters/ground_state/conditions/running"] = true
		anim_state.travel("ground_state/running")
		velocity.x = direction.x * sprint_speed
		velocity.z = direction.z * sprint_speed
		player_body.rotation.y = lerp_angle(player_body.rotation.y, atan2(velocity.x, velocity.z), delta * angular_speed)
	else:
		#anim.play("Idle")
		#anim_tree["parameters/ground_state/conditions/standing"] = true
		anim_state.travel("ground_state/idle_passive")
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	velocity.y -= gravity * delta
	move_and_slide()
		
func jump():
	velocity.y = jump_force
	#anim_tree["parameters/conditions/jumping"] = true
	anim_state.travel("jumping_state/jump")
	
	if velocity.y > 5.0:
		current_state = player_states.FALLING
		
	move_and_slide()
	
func falling(delta):
	var new_gravity = gravity * 2
	velocity.y -= new_gravity * delta
	#input_movement(delta)
	if is_on_floor():
		#anim_tree["parameters/conditions/on_ground"] = true
		anim_state.travel("ground_state/idle_passive")
		current_state=player_states.MOVE
		
	move_and_slide()
		
	
	

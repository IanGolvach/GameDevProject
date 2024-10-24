extends Node3D

@onready var player = $"../player"
@export var mouse_sensitivity = 100
var base_position = Vector3()
var base_rotation = Vector3()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_position = position
	base_rotation = rotation
	# taken from https://kidscancode.org/godot_recipes/4.x/input/mouse_capture/index.html
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = player.position
		
func _input(event):
	# taken from https://kidscancode.org/godot_recipes/4.x/input/mouse_capture/index.html
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x / mouse_sensitivity
		
		rotation.x -= event.relative.y / mouse_sensitivity
		position.y -= (event.relative.y * 0.3)/mouse_sensitivity
		rotation.x = clamp(rotation.x, deg_to_rad(-45), deg_to_rad(45))
		position.y = clamp(position.y, base_position.y-(deg_to_rad(-45)*0.3),base_position.y+(deg_to_rad(45)*0.3))
		

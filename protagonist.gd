extends CharacterBody2D


@export var SPEED = 75.0
const JUMP_VELOCITY = -175.0

var falling = true;
var floating = false;

var hasTorch = true;

func _physics_process(delta: float) -> void:
	
	handle_gravity(delta);

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func handle_gravity(delta: float): 
	if !is_on_floor():
		if velocity.y <= 0:
			velocity += get_gravity() * delta;
		if !floating:
			floating = true;
			$CoyoteTimer.start();
			velocity += get_gravity() * delta * 0.01;
	else:
		falling = false;
		floating = false;
	if falling:
		velocity += get_gravity() * delta;


func _on_coyote_timer_timeout() -> void:
	falling = true;

func gainTorch(energy: float):
	$Torch/PointLight2D.energy = energy
	$"Torch/Burning Out".start()

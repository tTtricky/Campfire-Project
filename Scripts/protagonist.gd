class_name Protagonist extends CharacterBody2D


@export var SPEED = 75.0
const JUMP_VELOCITY = -175.0

var falling = true;
var floating = false;

var hasTorch = true;

var inRope = false;

var ropeEntered : Callable = enterRope
var ropeExited : Callable = exitRope

var onFloor : bool

func _physics_process(delta: float) -> void:
	onFloor = is_on_floor()
	if (inRope):
		onFloor = true
		falling = false;
		print("should be on rope")
		if (Input.is_action_pressed("Use Rope")):
			velocity.y = 10
	
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
	if !onFloor:
		if velocity.y <= 0:
			velocity += get_gravity() * delta;
		if !floating:
			floating = true;
			$CoyoteTimer.start();
			if !inRope:
				velocity += get_gravity() * delta * 0.01;
				print("Slowly going down")
	else:
		falling = false;
		floating = false;
	if falling:
		if (!inRope):
			print("Falling")
			velocity += get_gravity() * delta;


func _on_coyote_timer_timeout() -> void:
	falling = true;

func gainTorch(energy: float):
	$Torch/PointLight2D.energy = energy
	$"Torch/Burning Out".start()
	
func enterRope():
	inRope = true;
func exitRope():
	inRope = false;

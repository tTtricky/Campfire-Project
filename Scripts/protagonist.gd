class_name Protagonist extends CharacterBody2D


@export var SPEED = 75.0
const JUMP_VELOCITY = -175.0


var floating = false;
var floated = false
var jumped = 0 ## -1 means just jumped off left wall, 1 means right

var presentAnimation : String

var inRope = false;
var holdingRope = false;

var onFloor : bool

@export var ropeFriction = 500

func _physics_process(delta: float) -> void:
	onFloor = is_on_floor()
	
	
	handle_gravity(delta);

	if (inRope):
		##print("should be on rope")
		if (Input.is_action_pressed("Use Rope")):
			if !(Input.is_action_pressed("Climb Down") || Input.is_action_pressed("Climb Up")):
				velocity.y = move_toward(velocity.y,0,500*delta)
			else:
				if (Input.is_action_pressed("Climb Up")):
					velocity.y = SPEED/-2 ##move_toward(velocity.y,SPEED/2,100*delta);
				if (Input.is_action_pressed("Climb Down")):
					velocity.y = SPEED/2 ##move_toward(velocity.y,SPEED/-2,100*delta);
			holdingRope = true;
		else:
			holdingRope = false;
			
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and (onFloor or floating or is_on_wall_only()):
		if (is_on_wall_only()):
			if (transform.x.x != jumped):
				velocity.y = JUMP_VELOCITY
				velocity.x += JUMP_VELOCITY/2 * transform.x.x
				jumped = transform.x.x
				print(jumped)
		else:
			velocity.y = JUMP_VELOCITY
			floated = true

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		if (onFloor || holdingRope):
			velocity.x = move_toward(velocity.x, 0, SPEED)
			jumped = 0

	move_and_slide()

func handle_gravity(delta: float): 
	if !onFloor && !holdingRope:
		velocity += get_gravity() * delta;
		if !floating and !floated:
			floating = true
			$CoyoteTimer.start();
	else:
		floating = false;
		floated = false


func _on_coyote_timer_timeout() -> void:
	floating = false;
	floated = true

func gainTorch(energy: float):
	$Torch/PointLight2D.energy = energy
	$"Torch/Burning Out".start()



func _on_rope_detector_area_entered(area: Area2D) -> void:
	print("Entered")
	if area in get_tree().get_nodes_in_group("Rope"):
		print(" and recieved")
		inRope = true;


func _on_rope_detector_area_exited(area: Area2D) -> void:
	print("Exited")
	if area in get_tree().get_nodes_in_group("Rope"):
		print(" and left")
		inRope = false;
		floated = !is_on_floor()
		holdingRope = false
		
func checkDirection():
	if velocity.x > 0:
		transform.x = Vector2(1,0)
	if (velocity.x < 0):
		transform.x = Vector2(-1,0);

func checkWhichAnimation():
	if (!is_on_floor()):
		if (holdingRope):
			pass #But the answer is climbSet
		else:
			pass #But the answer is jumpSet
	else:
		if velocity.x != 0:
			if ($Torch/PointLight2D.energy > 0):
				pass #But the answer is YesTorchRun
			else:
				pass #But the answer is noTorchRun
		else:
			if ($Torch/PointLight2D.energy > 0):
				pass #But the answer is YesTorch
			else:
				pass #But the answer is noTorch

func _process(delta: float): ## This is mostly for the animation so far
	if (!is_on_floor()):
		if (holdingRope):
			if (presentAnimation != "PlayerClimb"):
				$Sprite2D.play("PlayerClimb")
				presentAnimation = "PlayerClimb"
		else: 
			if (presentAnimation != "PlayerJump"):
				$Sprite2D.play("PlayerJump")
				presentAnimation = "PlayerJump"
	else: 
		if velocity.x != 0:
			if ($Torch/PointLight2D.energy > 0):
				if (presentAnimation != "PlayerYesTorchRun"):
					$Sprite2D.play("PlayerYesTorchRun")
					presentAnimation = "PlayerYesTorchRun"
			else:
				if (presentAnimation != "PlayerNoTorchRun"):
					$Sprite2D.play("PlayerNoTorchRun")
					presentAnimation = "PlayerNoTorchRun"
		else:
			if ($Torch/PointLight2D.energy > 0):
				if (presentAnimation != "PlayerYesTorch"):
					$Sprite2D.play("PlayerYesTorch")
					presentAnimation = "PlayerYesTorch"
			else:
				if (presentAnimation != "PlayerNoTorch"):
					$Sprite2D.play("PlayerNoTorch")
					presentAnimation = "PlayerNoTorch"
	checkDirection()

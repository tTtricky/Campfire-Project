class_name Protagonist extends CharacterBody2D


@export var SPEED = 75.0
const JUMP_VELOCITY = -175.0


var floating = false;
var floated = false
var jumped = 0 ## -1 means just jumped off left wall, 1 means right
var hitGround = true

var ropeLength = 0
var maxRopeLength = 0;
var ropeIndex : int

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
				velocity.y = move_toward(velocity.y,0,750*delta)
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
			
	## Handles losing your torch if you fall too far
	var cords = $"../TileMap".local_to_map(position + Vector2(0 ,velocity.y * delta * 3))
	#print(delta)
	var usingCord = Vector2(cords.x,cords.y)
	if($"../TileMap".get_cell_tile_data(0,usingCord) != null) and !hitGround:
		print(velocity.y)
		hitGround = true
		if (velocity.y > 300):
			$Torch/PointLight2D.energy -= (velocity.y - 300) / 300
			if $Torch/PointLight2D.energy < 0:
				$Torch/PointLight2D.energy = 0

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("Left", "Right")
	if direction:
		velocity.x = direction * SPEED
	else:
		if (onFloor || holdingRope):
			velocity.x = move_toward(velocity.x, 0, SPEED)
			if (!holdingRope):
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
		hitGround = false


func _on_coyote_timer_timeout() -> void:
	floating = false;
	floated = true

func gainTorch(energy: float):
	$Torch/PointLight2D.energy = energy
	$"Torch/Burning Out".start()



func _on_rope_detector_area_entered(area: Area2D) -> void:
	if area in get_tree().get_nodes_in_group("Rope"):
		print(" and recieved")
		inRope = true;
	if area in get_tree().get_nodes_in_group("EditArea"):
		ropeIndex = area.get_parent().instanceOfRope


func _on_rope_detector_area_exited(area: Area2D) -> void:
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
	if (Input.is_action_just_released("Use Rope") && !inRope):
		var cords = $"../TileMap".local_to_map(position)
		var usingCord = Vector2(cords.x,cords.y+1)
		if($"../TileMap".get_cell_tile_data(0,usingCord) != null):
			print("Debug 1")
			usingCord = Vector2(cords.x+transform.x.x,cords.y+1)
			if ($"../TileMap".get_cell_tile_data(0,usingCord) == null):
				print("Debug 2")
				var whichRope
				if (transform.x.x == 1):
					whichRope = 1
				if (transform.x.x == -1):
					whichRope = 1
				$"../TileMap".set_cell(0,usingCord,1,Vector2(0,0),whichRope)
				await get_tree().process_frame
				print("Debug 3")
				## Find how maxRopeLength
				var foundBottom = false
				var movingDown = 1
				while (!foundBottom):
					if ($"../TileMap".get_cell_tile_data(0,Vector2(usingCord.x,usingCord.y+movingDown))== null && movingDown < 100):
						print("Debug 3.5." + str(movingDown))
						movingDown += 1
					else:
						print("Debug 4" + str(movingDown))
						foundBottom = true
						maxRopeLength = movingDown/8.0
						print("Debug 4.5" + str(maxRopeLength))
						if ropeLength > maxRopeLength:
							ropeLength = maxRopeLength
							print("Maximum " + str(ropeLength))
						else:
							print(ropeLength)
				
				var children := $"../TileMap".get_children()
				for child in children:
					print("We got this far")
					if (child in get_tree().get_nodes_in_group("Rope")):
						print("this one's a rope")
						if child.instanceOfRope == ropeIndex:
							child.setLength(ropeLength)
							print("Rope Length:" + str(ropeLength))
	if (Input.is_action_pressed("Use Rope") && !inRope):
		ropeLength += delta/2
	else:
		await get_tree().process_frame
		ropeLength = 0
	checkDirection()

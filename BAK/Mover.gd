extends Spatial

onready var test_body = $test_body

func _ready():
	pass

func _physics_process(delta):
	if Input.is_action_just_pressed("debug_button"):
		# var move_result = move_right(test_body, 5)
		var move_result = move_west(test_body, 5)
		print(move_result)

################################
func move_forwards(move_client, move_speed):
	if move_client is RigidBody:
		move_client.add_central_force(-move_client.global_transform.basis.z * move_speed)
		return move_client.global_transform.origin

	var move_vec = Vector3()
	move_vec.z -= 1
	move_vec = move_vec.normalized()
	move_vec.rotated(Vector3(0, 1, 0), move_client.rotation.y)
	move_vec *= move_speed
	move_client.move_and_slide(move_vec, Vector3.UP)
	return move_client.global_transform.origin

func move_backwards(move_client, move_speed):
	if move_client is RigidBody:
		move_client.add_central_force(move_client.global_transform.basis.z * move_speed)
		return move_client.global_transform.origin

	var move_vec = Vector3()
	move_vec.z += 1
	move_vec = move_vec.normalized()
	move_vec.rotated(Vector3(0, 1, 0), move_client.rotation.y)
	move_vec *= move_speed
	move_client.move_and_slide(move_vec, Vector3.UP)
	return move_client.global_transform.origin

func move_right(move_client, move_speed):
	if move_client is RigidBody:
		move_client.add_central_force(move_client.global_transform.basis.x * move_speed)
		return move_client.global_transform.origin

	var move_vec = Vector3()
	move_vec.y += 1
	move_vec = move_vec.normalized()
	move_vec.rotated(Vector3(0, 1, 0), move_client.rotation.y)
	move_vec *= move_speed
	move_client.move_and_slide(move_vec, Vector3.UP)
	return move_client.global_transform.origin

func move_left(move_client, move_speed):
	if move_client is RigidBody:
		move_client.add_central_force(-move_client.global_transform.basis.x * move_speed)
		return move_client.global_transform.origin

	var move_vec = Vector3()
	move_vec.y -= 1
	move_vec = move_vec.normalized()
	move_vec.rotated(Vector3(0, 1, 0), move_client.rotation.y)
	move_vec *= move_speed
	move_client.move_and_slide(move_vec, Vector3.UP)
	return move_client.global_transform.origin


################################
func move_north(move_client, move_speed):
	if move_client is RigidBody:
		move_client.add_central_force(Vector3(0,0,-1) * move_speed)
		return move_client.global_transform.origin

	var move_vec = Vector3()
	move_vec.z -= 1
	move_vec = move_vec.normalized()
	# move_vec.rotated(Vector3(0, 1, 0), move_client.rotation.y)
	move_vec *= move_speed
	move_client.move_and_slide(move_vec, Vector3.UP)
	return move_client.global_transform.origin


func move_south(move_client, move_speed):
	if move_client is RigidBody:
		move_client.add_central_force(Vector3(0,0,1) * move_speed)
		return move_client.global_transform.origin

	var move_vec = Vector3()
	move_vec.z += 1
	move_vec = move_vec.normalized()
	# move_vec.rotated(Vector3(0, 1, 0), move_client.rotation.y)
	move_vec *= move_speed
	move_client.move_and_slide(move_vec, Vector3.UP)
	return move_client.global_transform.origin

func move_east(move_client, move_speed):
	if move_client is RigidBody:
		move_client.add_central_force(Vector3(1,0,0) * move_speed)
		return move_client.global_transform.origin

	var move_vec = Vector3()
	move_vec.x += 1
	move_vec = move_vec.normalized()
	# move_vec.rotated(Vector3(0, 1, 0), move_client.rotation.y)
	move_vec *= move_speed
	move_client.move_and_slide(move_vec, Vector3.UP)
	return move_client.global_transform.origin

func move_west(move_client, move_speed):
	if move_client is RigidBody:
		move_client.add_central_force(Vector3(-1,0,0) * move_speed)
		return move_client.global_transform.origin

	var move_vec = Vector3()
	move_vec.x -= 1
	move_vec = move_vec.normalized()
	# move_vec.rotated(Vector3(0, 1, 0), move_client.rotation.y)
	move_vec *= move_speed
	move_client.move_and_slide(move_vec, Vector3.UP)
	return move_client.global_transform.origin

extends Spatial

#onready var test_body = $test_body

func _ready():
	pass

func _physics_process(delta):
	pass

################################
func move_forwards(move_client, move_speed):
	if move_client is RigidBody:
		move_client.add_central_force(-move_client.global_transform.basis.z * move_speed)
		return move_client.global_transform.origin
	
	elif move_client is KinematicBody:
		var move_vec = Vector3()
		move_vec.z -= 1
		move_vec = move_vec.normalized()
		move_vec = move_vec.rotated(Vector3(0, 1, 0), move_client.rotation.y)
		move_vec *= move_speed
		move_client.move_and_slide(move_vec, Vector3.UP)
		return move_client.global_transform.origin

	else:
		print('Choose a KinematicBody or RigidBody. move_client is ', move_client)

func move_backwards(move_client, move_speed):
	if move_client is RigidBody:
		move_client.add_central_force(move_client.global_transform.basis.z * move_speed)
		return move_client.global_transform.origin

	elif move_client is KinematicBody:
		var move_vec = Vector3()
		move_vec.z += 1
		move_vec = move_vec.normalized()
		move_vec = move_vec.rotated(Vector3(0, 1, 0), move_client.rotation.y)
		move_vec *= move_speed
		move_client.move_and_slide(move_vec, Vector3.UP)
		return move_client.global_transform.origin

	else:
		print('Choose a KinematicBody or RigidBody. move_client is ', move_client)

func move_right(move_client, move_speed):
	if move_client is RigidBody:
		move_client.add_central_force(move_client.global_transform.basis.x * move_speed)
		return move_client.global_transform.origin

	elif move_client is KinematicBody:
		var move_vec = Vector3()
		move_vec.x += 1
		move_vec = move_vec.normalized()
		move_vec = move_vec.rotated(Vector3(0, 1, 0), move_client.rotation.y)
		move_vec *= move_speed
		move_client.move_and_slide(move_vec, Vector3.UP)
		return move_client.global_transform.origin

	else:
		print('Choose a KinematicBody or RigidBody. move_client is ', move_client)

func move_left(move_client, move_speed):
	if move_client is RigidBody:
		move_client.add_central_force(-move_client.global_transform.basis.x * move_speed)
		return move_client.global_transform.origin

	elif move_client is KinematicBody:
		var move_vec = Vector3()
		move_vec.x -= 1
		move_vec = move_vec.normalized()
		move_vec = move_vec.rotated(Vector3(0, 1, 0), move_client.rotation.y)
		move_vec *= move_speed
		move_client.move_and_slide(move_vec, Vector3.UP)
		return move_client.global_transform.origin

	else:
		print('Choose a KinematicBody or RigidBody. move_client is ', move_client)


################################
func move_north(move_client, move_speed):
	if move_client is RigidBody:
		move_client.add_central_force(Vector3(0,0,-1) * move_speed)
		return move_client.global_transform.origin

	elif move_client is KinematicBody:
		var move_vec = Vector3()
		move_vec.z -= 1
		move_vec = move_vec.normalized()
		# move_vec.rotated(Vector3(0, 1, 0), move_client.rotation.y)
		move_vec *= move_speed
		move_client.move_and_slide(move_vec, Vector3.UP)
		return move_client.global_transform.origin

	else:
		print('Choose a KinematicBody or RigidBody. move_client is ', move_client)


func move_south(move_client, move_speed):
	if move_client is RigidBody:
		move_client.add_central_force(Vector3(0,0,1) * move_speed)
		return move_client.global_transform.origin

	elif move_client is KinematicBody:
		var move_vec = Vector3()
		move_vec.z += 1
		move_vec = move_vec.normalized()
		# move_vec.rotated(Vector3(0, 1, 0), move_client.rotation.y)
		move_vec *= move_speed
		move_client.move_and_slide(move_vec, Vector3.UP)
		return move_client.global_transform.origin

	else:
		print('Choose a KinematicBody or RigidBody. move_client is ', move_client)

func move_east(move_client, move_speed):
	if move_client is RigidBody:
		move_client.add_central_force(Vector3(1,0,0) * move_speed)
		return move_client.global_transform.origin

	elif move_client is KinematicBody:
		var move_vec = Vector3()
		move_vec.x += 1
		move_vec = move_vec.normalized()
		# move_vec.rotated(Vector3(0, 1, 0), move_client.rotation.y)
		move_vec *= move_speed
		move_client.move_and_slide(move_vec, Vector3.UP)
		return move_client.global_transform.origin

	else:
		print('Choose a KinematicBody or RigidBody. move_client is ', move_client)

func move_west(move_client, move_speed):
	if move_client is RigidBody:
		move_client.add_central_force(Vector3(-1,0,0) * move_speed)
		return move_client.global_transform.origin

	elif move_client is KinematicBody:
		var move_vec = Vector3()
		move_vec.x -= 1
		move_vec = move_vec.normalized()
		# move_vec.rotated(Vector3(0, 1, 0), move_client.rotation.y)
		move_vec *= move_speed
		move_client.move_and_slide(move_vec, Vector3.UP)
		return move_client.global_transform.origin

	else:
		print('Choose a KinematicBody or RigidBody. move_client is ', move_client)

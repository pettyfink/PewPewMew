extends KinematicBody

onready var anim = $AnimationPlayer

onready var raycast = $Area/RayCast
onready var hand = $Body/Hand
onready var catbot_collision = $CatbotCollision

onready var res_pistol_p = preload("res://pistol_p.tscn")
onready var res_pistol_w = preload("res://pistol_w.tscn")
onready var res_shotgun_p = preload("res://shotgun_p.tscn")
onready var res_shotgun_w = preload("res://shotgun_w.tscn")


onready var attack_timer = $AttackTimer
onready var delay_timer = $DelayTimer
onready var patrol_timer = $PatrolTimer

const GRAVITY = 0.98
const MAX_FALL_SPEED = 30
# const MOVE_SPEED = 6

var y_velo = 0
var move_speed = 200
var health = 35
var last_health
var dead = false

var target
var last_target_origin
var active_attack_tool
var delay_timeout = false
export var weapon_choice: String
export var has_hardhat: bool
export var patrol: bool
onready var hardhat = $Body/Head/metro_hardhat

# Patrol vars
var is_patrolling
var patrol_original_pos
var patrol_negative_x_paces_made
var patrol_positive_x_paces_made
var patrol_negative_x_paces = 5
var patrol_positive_x_paces = 5
var patrol_west_pos
var patrol_east_pos
var patrol_routine = ['face_west','move_to_west_pos','face_east','move_to_east_pos','face_west','move_to_original_pos']
var patrol_routine_index = 0

func _ready():
	if !weapon_choice:
		weapon_choice = 'pistol'
	# equip_weapon(weapon_choice)
	last_health = health
	
	if has_hardhat:
		hardhat.visible = true

	if patrol:
		patrol_original_pos = global_transform.origin
		patrol_east_pos = patrol_original_pos
		patrol_east_pos.x -= patrol_negative_x_paces
		patrol_west_pos = patrol_original_pos
		patrol_west_pos.x += patrol_negative_x_paces
		is_patrolling = true

func _process(delta):
	if dead:
		return
		
	var move_vec = Vector3()
	move_vec.y = y_velo
	move_and_slide(move_vec, Vector3.UP)

	if is_on_floor() and y_velo <= 0:
		y_velo = -0.1
		
	if y_velo < -MAX_FALL_SPEED:
		y_velo = -MAX_FALL_SPEED
		
	y_velo -= GRAVITY
	
	if health <= 0:
		anim.stop()
		anim.play("die")
		anim.queue("die_idle")
		if active_attack_tool:
			if active_attack_tool.editor_description == 'pistol':
				spawn_weapon(res_pistol_w)
				# spawn_pistol()
			if active_attack_tool.editor_description == 'shotgun':
				spawn_weapon(res_shotgun_w)
				# spawn_pistol()
		for item in hand.get_children():
			item.queue_free()
		dead = true
	
	if !dead and health < last_health:
		anim.play("pain")
		anim.queue("Idle")
	last_health = health
	
	if active_attack_tool:
		if active_attack_tool.magazine_ammo < 1:
			active_attack_tool.reload()
	if target:
		is_patrolling = false
		raycast.look_at(target.global_transform.origin, Vector3.UP)
		var ray_collider = raycast.get_collider()
		if ray_collider:
			if ray_collider.is_in_group("Player"):
				last_target_origin = target.global_transform.origin
				look_at(target.global_transform.origin, Vector3.UP)
				if delay_timer.is_stopped():
					delay_timer.start()
				if delay_timeout:
					attack(raycast)
					delay_timeout = false
	else:
		if !is_patrolling and patrol_timer.is_stopped():
			patrol_timer.start()
					
				
	if last_target_origin:
		var ray_collider = raycast.get_collider()
		if ray_collider:
			if !ray_collider.is_in_group("Player"):
				var direction = (last_target_origin - global_transform.origin).normalized()
				move_and_slide(direction * move_speed * delta, Vector3.UP)
				
				var last_self_origin = global_transform.origin
				var move_difference = (global_transform.origin - last_self_origin)[0]
				if move_difference < (move_speed*0.0001) and patrol_timer.is_stopped():
					rotation_degrees.y += rand_range(-15,15)
		if !target:
			var direction = (last_target_origin - global_transform.origin).normalized()
			move_and_slide(direction * move_speed * delta, Vector3.UP)				

	if patrol and is_patrolling:

		basic_patrol("walk", delta)

func equip_weapon(weapon):
	for held in hand.get_children():
		held.queue_free()

	var weapon_p
	if weapon == 'pistol':
		weapon_p = res_pistol_p.instance()
	if weapon == 'shotgun':
		weapon_p = res_shotgun_p.instance()
	hand.add_child(weapon_p)
	active_attack_tool = weapon_p

func attack(raycast):
	if active_attack_tool:
		active_attack_tool.attack(raycast)
		
func spawn_weapon(weapon_resource):
	var weapon_w = weapon_resource.instance()
	get_parent().add_child(weapon_w)
	weapon_w.global_transform = global_transform
	weapon_w.global_transform.origin.y += 1
	weapon_w.apply_impulse(transform.basis.y, -transform.basis.y)
	weapon_w.apply_impulse(-transform.basis.z, -transform.basis.z * 5)
	weapon_w.apply_impulse(transform.basis.y, transform.basis.y * rand_range(.1,-.1))
	weapon_w.apply_impulse(transform.basis.x, transform.basis.y * rand_range(.1,-.1))


func spawn_pistol():
	# if !active_attack_tool:
	# 	return
	# if active_attack_tool.editor_description != "pistol":
	# 	return
	var pistol_w = res_pistol_w.instance()
	get_parent().add_child(pistol_w)
	pistol_w.global_transform = global_transform
	pistol_w.global_transform.origin.y += 1
#	pistol_w.global_transform.origin.z -= 1
	pistol_w.apply_impulse(transform.basis.y, -transform.basis.y)
	pistol_w.apply_impulse(-transform.basis.z, -transform.basis.z * 5)
	pistol_w.apply_impulse(transform.basis.y, transform.basis.y * rand_range(.1,-.1))
	pistol_w.apply_impulse(transform.basis.x, transform.basis.y * rand_range(.1,-.1))

func basic_patrol(patrol_type, delta):
	pass
	# Patrol types = ['walk', 'look']
	# Walk = Take x paces -= x, then x paces += x, then return to spot
	#			Remember where left off
	# Look = look 90 degrees left and 90 degrees right at interval
	#if patrol_type == "walk":
	#	# Turn left
	#	# patrol_routine = ['face_west','move_to_west_pos','face_east','move_to_east_pos','face_west','move_to_original_pos']
	#	if patrol_routine[patrol_routine_index] == 'face_west':
	#		if rotation_degrees.y > 92 or rotation_degrees.y < 88:
	#			rotation_degrees.y += 1
	#		else:
	#			rotation_degrees.y = 90
	#			patrol_routine_index = 1

	#	elif patrol_routine[patrol_routine_index] == 'move_to_west_pos':
	#		var patrol_direction = (patrol_east_pos - global_transform.origin).normalized()
	#		var pos_difference = patrol_east_pos.distance_to(global_transform.origin)
	#		move_and_slide(patrol_direction * move_speed * delta, Vector3.UP)
	#		patrol_east_pos.distance_to(global_transform.origin)
	#		if pos_difference < .09:
	#		# if patrol_direction.x > -0.05 or patrol_direction.x < 0.05:
	#			patrol_routine_index = 2

	#	elif patrol_routine[patrol_routine_index] == 'face_east':
	#		if rotation_degrees.y < -92 or rotation_degrees.y > -88:
	#			rotation_degrees.y -= 1
	#		else:
	#			rotation_degrees.y = -90
	#			patrol_routine_index = 3

	#	elif patrol_routine[patrol_routine_index] == 'move_to_east_pos':
	#		var patrol_direction = (patrol_west_pos - global_transform.origin).normalized()
	#		var pos_difference = patrol_east_pos.distance_to(global_transform.origin)
	#		move_and_slide(patrol_direction * move_speed * delta, Vector3.UP)
	#		if pos_difference < .09:
	#			patrol_routine_index = 4

	#	elif patrol_routine[patrol_routine_index] == 'face_west':
	#		if rotation_degrees.y > 92 or rotation_degrees.y < 88:
	#			rotation_degrees.y += 1
	#		else:
	#			rotation_degrees.y = 90
	#			patrol_routine_index = 5

	#	elif patrol_routine[patrol_routine_index] == 'move_to_original_pos':
	#		var patrol_direction = (patrol_original_pos - global_transform.origin).normalized()
	#		var pos_difference = patrol_east_pos.distance_to(global_transform.origin)
	#		move_and_slide(patrol_direction * (move_speed * 2) * delta, Vector3.UP)
	#		if pos_difference < .09:
	#			patrol_routine_index = 0


func _on_Area_body_entered(body):
	if body.is_in_group("Player") and !dead:
		target = body
		equip_weapon(weapon_choice)


func _on_Area_body_exited(body):
	if body.is_in_group("Player"):
		target = null


func _on_DelayTimer_timeout():
	delay_timeout = true


func _on_PatrolTimer_timeout():
	is_patrolling = true
	last_target_origin = null
	patrol_routine_index = 5

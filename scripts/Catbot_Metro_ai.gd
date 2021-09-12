extends KinematicBody

onready var anim = $AnimationPlayer
onready var head = $Body/Head
onready var sight_area = $Body/Head/sight_area
onready var raycast = $Body/Head/goggle_raycast
onready var sensor_raycast = $sensor_raycast
onready var eyes = $eyes
onready var player = $"../../../Player"
var target
var last_target_origin
var original_origin

export var has_hardhat: bool
onready var hardhat = $Body/Head/metro_hardhat

export var weapon_choice: String
onready var res_pistol_p = preload("res://scenes/pistol_p.tscn")
onready var res_pistol_w = preload("res://scenes/pistol_w.tscn")
onready var res_shotgun_p = preload("res://scenes/shotgun_p.tscn")
onready var res_shotgun_w = preload("res://scenes/shotgun_w.tscn")
onready var hand = $Body/Hand
var active_attack_tool

var health = 35
var last_health
var dead = false

const MAX_FALL_SPEED = 30
const MOVE_SPEED = 2.5
const TURN_SPEED = 2
const GRAVITY = .98
var y_velo = 0

var preset_look_around_degrees = 90
var look_around_degrees
var last_static_rotation
var is_look_direction_left = true

onready var init_timer = $init_timer
onready var turn_timer = $turn_timer
onready var state_flip_timer = $state_flip_timer
onready var forget_timer = $forget_timer

enum {
	IDLE,
	ALERT,
	CHASE,
	STATIC_ATTACK,
	LOOK_AROUND,
	FLEE,
	DEAD_IDLE
}

var state = IDLE

func _ready():
	init_timer.start()
	if !weapon_choice:
		weapon_choice = 'pistol'
	equip_weapon(weapon_choice)
	last_health = health
	
	if has_hardhat:
		hardhat.visible = true

	# original_origin = global_transform.origin

func _process(delta):
	gravity_force()

	if dead:
		return

	death_manager()
	pain_reaction()
	reload_manager()


####
# Player in area:
#     If player viewable, alert
#     attack player
# 
# Player left area:
#     Start forget_timer
#     Until forget_timer stops:
#         If sensor_raycast can see player:
#                 Change state to CHASE
#                 (Turn to face player with sensor_raycast)
#         Else:
#                 Walk to last_target.origin
#                 If colliding with StaticBody:
#                     Move away by relative X
# 
# Forget_timer stops:
#     Look around
#     Change state to IDLE
# 
####
	if Input.is_action_just_pressed("debug_button"): # O
		print(state)
	match state:
		IDLE:
			# anim.stop()
			# anim.play("Idle")
			var is_target_viewable = check_target_viewable()
			if is_target_viewable:
				state = ALERT
			else:
				var distance_to_original_origin
				if !original_origin:
					distance_to_original_origin = 0
				else:
					distance_to_original_origin = global_transform.origin.distance_to(original_origin)
				if distance_to_original_origin > 1:
					var direction = (original_origin - global_transform.origin)
					anim.play("walk")
					move_and_slide(direction.normalized(), Vector3.UP)
				else:
					anim.stop()
					anim.play("Idle")
			# If !is_busy:
				# If is_energy_low and known_recharge_node:
				#	(maybe switch to a charging state, set is_busy = true)
				#	go to the closest recharge node
				#	recharge
				#	return to original spot (add random chance, low possibility of staying)
				# If is_energy_lwo and !known_recharge_node:
				#	(maybe switch to a charging state, set is_busy = true)
				#   spin sensor_raycast around and look for one
				#	if sensor_collider.is_in_group("recharge_station"):
				#		recharge
				#		return to original spot (add random chance, low possibility of staying)
				# If is_ammo_low
				#	(maybe switch to an ammo_hunt state, set is_busy = true)
				#	look for ammo until has 2 reloads worth

		ALERT:
			if target:
				var is_target_viewable = check_target_viewable()
				if is_target_viewable:
					set_last_target_origin()
					face_target()
				if last_target_origin and !is_target_viewable:
					state = CHASE

				var distance = global_transform.origin.distance_to(target.global_transform.origin)
				if distance > 10:
					state = CHASE
			elif !target and last_target_origin:
				state = CHASE
			else:
				print("No target and no last target origin.")

		CHASE:
			# anim.stop()
			anim.play("walk")
			print()
			if target:
				var is_target_viewable = check_target_viewable()
				if is_target_viewable:
					set_last_target_origin()
					face_target()
					var direction = (target.global_transform.origin - global_transform.origin)
					move_and_slide(direction.normalized() * MOVE_SPEED, Vector3.UP)
					var distance = global_transform.origin.distance_to(target.global_transform.origin)
					if distance <= 5:
						state = ALERT
				elif !is_target_viewable and last_target_origin:
					var direction = (last_target_origin - global_transform.origin)
					var distance = global_transform.origin.distance_to(last_target_origin)
					if distance < 1:
						state = LOOK_AROUND
					move_and_slide(direction.normalized(), Vector3.UP)
					if forget_timer.is_stopped():
						forget_timer.start()
				else:
					print("I guess target can't be seen and no last target was found")

			else:
				var is_target_viewable = check_target_viewable()
				if !is_target_viewable and last_target_origin:
					var direction = (last_target_origin - global_transform.origin)
					var distance = global_transform.origin.distance_to(last_target_origin)
					if distance < 1:
						state = LOOK_AROUND
					move_and_slide(direction.normalized(), Vector3.UP)
					if forget_timer.is_stopped():
						forget_timer.start()
					# state = LOOK_AROUND

		STATIC_ATTACK:
			anim.stop()
			anim.play("Idle")

		LOOK_AROUND:
			if turn_timer.is_stopped():
				turn_timer.start()
			if state_flip_timer.is_stopped():
				state_flip_timer.start()
			
			if !look_around_degrees:
				last_static_rotation = rotation_degrees.y
				look_around_degrees = last_static_rotation + preset_look_around_degrees
			match is_look_direction_left:
				true:
					rotate_y(deg2rad(TURN_SPEED))
				false:
					rotate_y(deg2rad(-TURN_SPEED))
			var is_target_viewable = check_target_viewable()
			if is_target_viewable:
				state = ALERT

		FLEE:
			anim.stop()
			anim.play("walk")

		DEAD_IDLE:
			anim.stop()
			anim.play("die")
			anim.queue("die_idle")

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
	var pistol_w = res_pistol_w.instance()
	get_parent().add_child(pistol_w)
	pistol_w.global_transform = global_transform
	pistol_w.global_transform.origin.y += 1
	pistol_w.apply_impulse(transform.basis.y, -transform.basis.y)
	pistol_w.apply_impulse(-transform.basis.z, -transform.basis.z * 5)
	pistol_w.apply_impulse(transform.basis.y, transform.basis.y * rand_range(.1,-.1))
	pistol_w.apply_impulse(transform.basis.x, transform.basis.y * rand_range(.1,-.1))

func pain_reaction():
	if !dead and health < last_health:
		anim.play("pain")
		anim.queue("Idle")
	last_health = health

func death_manager():
	if health <= 0:
		state = DEAD_IDLE
		# anim.stop()
		# anim.play("die")
		# anim.queue("die_idle")
		if active_attack_tool:
			if active_attack_tool.editor_description == 'pistol':
				spawn_weapon(res_pistol_w)
				# spawn_pistol()
			if active_attack_tool.editor_description == 'shotgun':
				spawn_weapon(res_shotgun_w)
				# spawn_pistol()
		for item in hand.get_children():
			item.queue_free()
		raycast.queue_free()
		sensor_raycast.queue_free()
		sight_area.queue_free()
		dead = true

func reload_manager():
	if active_attack_tool:
		if active_attack_tool.magazine_ammo < 1:
			active_attack_tool.reload()

func gravity_force():
	var move_vec = Vector3()
	move_vec.y = y_velo
	move_and_slide(move_vec, Vector3.UP)

	if is_on_floor() and y_velo <= 0:
		y_velo = -0.1
		
	if y_velo < -MAX_FALL_SPEED:
		y_velo = -MAX_FALL_SPEED
		
	y_velo -= GRAVITY


func _on_sight_area_body_entered(body):
	if body.is_in_group("Player"):
		target = body
		var is_target_viewable = check_target_viewable()
		if is_target_viewable:
			state = ALERT


func _on_sight_area_body_exited(body):
	if body.is_in_group("Player"):
		target = null

func face_target():
	eyes.look_at(target.global_transform.origin, Vector3(0, 1, 0))
	rotate_y(deg2rad(eyes.rotation.y * TURN_SPEED))

func check_target_viewable():
	if !target:
		return false
	var target_mid_vec = target.global_transform.origin
	target_mid_vec.y += .25
	sensor_raycast.look_at(target_mid_vec, Vector3.UP)
	var sensor_collider = sensor_raycast.get_collider()
	if sensor_collider:
		var target_in_view = sensor_collider.name == target.name
		return target_in_view

func set_last_target_origin():
	print('Func setting last_target_origin')
	if !target:
		return
	last_target_origin = target.global_transform.origin

func _on_turn_timer_timeout():
	is_look_direction_left = !is_look_direction_left

func _on_state_flip_timer_timeout():
	state = IDLE

func _on_forget_timer_timeout():
	state = LOOK_AROUND

func _on_init_timer_timeout():
	print('Setting original origin.')
	original_origin = global_transform.origin
	print(original_origin)
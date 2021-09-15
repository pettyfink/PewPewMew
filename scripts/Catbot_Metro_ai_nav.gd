extends KinematicBody

onready var anim = $AnimationPlayer
onready var anim_raycast = $RaycastAnimationPlayer
onready var head = $Body/Head
onready var sight_area = $Body/Head/sight_area
onready var raycast = $Body/Head/raycast
onready var sensor_raycast = $sensor_raycast
onready var eyes = $eyes
# onready var player = $"../../../Player"

### NAV
export (NodePath) var nav_path
export (NodePath) var player_path
onready var nav = get_node(nav_path)
onready var player = get_node(player_path)
var nav_live_tracking = true
var destination_origin
var path = []
var path_node = 0
var moving_to_path
###

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
var is_attacking = false
var attack_heard = false

var health = 35
var last_health
var dead = false

const MAX_FALL_SPEED = 30
const MOVE_SPEED = 5
const TURN_SPEED = 4
const GRAVITY = .98
var y_velo = 0

var preset_look_around_degrees = 90
var look_around_degrees
var last_static_rotation
var is_look_direction_left = true

onready var init_timer = $init_timer
onready var attack_timer = $attack_timer
onready var turn_timer = $turn_timer
onready var state_flip_timer = $state_flip_timer
onready var forget_timer = $forget_timer
onready var nav_timer = $nav_timer

enum {
	IDLE,
	ALERT,
	CHASE,
	MOVING,
	LOOK_AROUND,
	FLEE,
	DEAD_IDLE,
	NO_STATE
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

	death_manager()
	if dead:
		return

	pain_reaction()
	reload_manager()

	if attack_heard:
		state = MOVING
	match state:
		IDLE:
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
					anim.play("walk")
					destination_origin = original_origin
					nav_manager()
				else:
					anim.stop()
					anim.play("Idle")

		ALERT:
			if target:
				var distance = global_transform.origin.distance_to(target.global_transform.origin)
				if distance > 10:
					state = CHASE
				
				var is_target_viewable = check_target_viewable()
				if is_target_viewable:
					set_last_target_origin()
					face_target()
					if distance < 2:
						attack_manager(sensor_raycast)
					else:
						attack_manager(raycast)

				if last_target_origin and !is_target_viewable:
					state = CHASE


			elif !target and last_target_origin:
				state = CHASE

			else:
				# print("No target and no last target origin.")
				pass

		CHASE:
			anim.play("walk")
			if target:
				var is_target_viewable = check_target_viewable()
				if is_target_viewable:
					set_last_target_origin()
					face_target()

					# Navigate to target
					destination_origin = target.global_transform.origin
					nav_live_tracking = true
					nav_manager()

					var distance = global_transform.origin.distance_to(target.global_transform.origin)
					if distance <= 5:
						state = ALERT

				elif !is_target_viewable and last_target_origin:
					var direction = (last_target_origin - global_transform.origin)
					var distance = global_transform.origin.distance_to(last_target_origin)
					if distance < 1:
						state = LOOK_AROUND

					# Navigate to last_target_origin
					destination_origin = last_target_origin
					nav_live_tracking = false
					nav_manager()

					if forget_timer.is_stopped():
						forget_timer.start()

				else:
					# print("I guess target can't be seen and no last target was found")
					pass


			else:
				var is_target_viewable = check_target_viewable()
				if !is_target_viewable and last_target_origin:
					var direction = (last_target_origin - global_transform.origin)
					var distance = global_transform.origin.distance_to(last_target_origin)
					if distance < 1:
						state = LOOK_AROUND

					# Navigate to last target origin
					destination_origin = last_target_origin
					nav_live_tracking = false
					nav_manager()

					if forget_timer.is_stopped():
						forget_timer.start()

		MOVING:
			if attack_heard:
				face_origin(last_target_origin)
				update_nav_path(last_target_origin)
				attack_heard = false

			var is_target_viewable = check_target_viewable()

			if last_target_origin:
				var direction = (last_target_origin - global_transform.origin)
				var distance = global_transform.origin.distance_to(last_target_origin)
				if distance < 1:
					state = LOOK_AROUND

				# Navigate to last_target_origin
				destination_origin = last_target_origin
				nav_live_tracking = false
				nav_manager()

				if forget_timer.is_stopped():
					forget_timer.start()
				# state = LOOK_AROUND
				anim.play("walk")

			if target or is_target_viewable:
				state = CHASE
			
			if !target or !is_target_viewable or attack_heard:
				face_origin(last_target_origin)

			if !target and !last_target_origin:
				state = IDLE

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
			pass
			# anim.stop()
			# anim.play("die")
			# anim.queue("die_idle")
			# dead = true

		NO_STATE:
			pass

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

func nav_manager():
	# path = nav.get_simple_path(global_transform.origin, player.global_transform.origin)
	if !path:
		# update_nav_path(player.global_transform.origin) # Working
		update_nav_path(destination_origin)
	elif path and nav_timer.is_stopped() and nav_live_tracking:
		nav_timer.start()

	# print('Moving to node ', path_node, ' of ', path.size())
	if path_node < path.size():
		var direction = (path[path_node] - global_transform.origin)
		if direction.length() < 1:
			path_node += 1
		else:
			move_and_slide(direction.normalized(), Vector3.UP)
		return false
	else:
		return true

func update_nav_path(goal_pos):
	path = nav.get_simple_path(global_transform.origin, player.global_transform.origin)
	path = nav.get_simple_path(global_transform.origin, goal_pos)
	path_node = 0

func death_manager():
	if dead:
		return

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
		raycast.queue_free()
		sensor_raycast.queue_free()
		sight_area.queue_free()
		state = DEAD_IDLE
		dead = true

func attack_manager(chosen_raycast):
	if is_attacking:
		anim_raycast.play("bounce")
		anim_raycast.queue("bounce")
		active_attack_tool.attack(chosen_raycast)
		is_attacking = false
		return
	else:
		# anim_raycast.stop()
		# anim_raycast.play("Idle")
		if attack_timer.is_stopped():
			attack_timer.start()



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

func face_origin(vec_origin):
	eyes.look_at(vec_origin, Vector3(0, 1, 0))
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
	# print('Setting original origin.')
	original_origin = global_transform.origin
	if nav_path == "":
		nav = false

func _on_attack_timer_timeout():
	is_attacking = true

func _on_nav_timer_timeout():
	update_nav_path(player.global_transform.origin)

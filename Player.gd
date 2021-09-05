extends KinematicBody

var MOVE_SPEED = 0
const WALK_SPEED = 6
const RUN_SPEED = WALK_SPEED*2
const AIR_MOVE_SPEED = 6
const JUMP_FORCE = 18
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30

const H_LOOK_SENS = .16
const V_LOOK_SENS = .16

var block_player_controls = false

onready var anim = $CamBase/GraphicsBase/Graphics/AnimationPlayer

onready var colshape = $CollisionShape
onready var area = $Area
onready var raycast = $CamBase/ClippedCamera/RayCast

onready var mesh = $CamBase/GraphicsBase/Graphics
onready var hand = $CamBase/GraphicsBase/Hand

onready var cam = $CamBase
onready var viewport = $CamBase/ClippedCamera

onready var crosshair = $CamBase/ClippedCamera/Crosshair
onready var ammo_display = $CamBase/ClippedCamera/Ammo_display
onready var health_display = $CamBase/ClippedCamera/Health_display
onready var color_overlay = $CamBase/ClippedCamera/ColorOverlay
onready var timer_overlay = $CamBase/ClippedCamera/TimerOverlay
onready var console = $CamBase/ClippedCamera/LineEdit
onready var console_timer = $CamBase/ClippedCamera/ConsoleTimer
onready var console_print = $CamBase/ClippedCamera/ConsolePrint

onready var res_unarmed_p = preload("res://unarmed_p.tscn")
onready var res_knife_p = preload("res://knife_p.tscn")

onready var res_pistol_p = preload("res://pistol_p.tscn")
onready var res_pistol_w = preload("res://pistol_w.tscn") # Just testing
onready var res_akimbo_pistol_p = preload("res://akimbo_pistol_p.tscn")

onready var res_shotgun_p = preload("res://shotgun_p.tscn")
onready var active_attack_tool = null
var selected_pistol = 'single' # This is bad code, you should replace it

var y_velo = 0
var x_velo = 0
var z_velo = 0
var rot_velo = 0

var health = 100

# Weap
var pistol_ammo
var pistol_magazine
var akimbo_magazine
var shotgun_magazine
var pistol_count
var pistol_slot = [1,2]
var last_health
var dead = false
var finished = false

var shotgun_ammo

var inventory = []

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	anim.get_animation("walk").set_loop(true)

	active_attack_tool = equip_attack_tool(res_unarmed_p, hand)
	inventory.append('knife')
	inventory.append('freekey')

	color_overlay.color = Color(0,0,0,0)

	last_health = health
	pistol_ammo = 36
	shotgun_ammo = 12
	pistol_count = 0
	pistol_magazine = 0
	akimbo_magazine = 0
	shotgun_magazine = 0





	
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
func _input(event):
	if Input.is_action_just_pressed('ui_accept'):
		if console.has_focus():
			console_interpret(console.text)
			console.release_focus()
			console.visible = false


	if dead:
		return
		
	if event is InputEventMouseMotion:
		cam.rotation_degrees.x -= event.relative.y * V_LOOK_SENS
		cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -90, 90)
		rotation_degrees.y -= event.relative.x * H_LOOK_SENS
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

######################################
## C U S T O M    F U N C T I O N S ##
######################################

func reset_raycast(raycast):
	raycast.cast_to.x = 0
	raycast.cast_to.y = 0

func slot2_key_action(act_atk_tool, sel_pistol, pist_count):
	var attack_tool_resource
	if pist_count < 1 or !inventory.has("pistol"):
		attack_tool_resource = res_unarmed_p
		return equip_attack_tool(attack_tool_resource, hand)

	if act_atk_tool and pist_count == 1:
		if act_atk_tool.editor_description == "pistol":
			return act_atk_tool
		sel_pistol = 'single'
	elif act_atk_tool and pist_count > 1:
		if act_atk_tool.editor_description == "akimbo":
			sel_pistol = 'single'
		elif act_atk_tool.editor_description == "pistol":
			sel_pistol = 'akimbo'
		elif act_atk_tool.editor_description == "unarmed":
			sel_pistol = 'single'

	attack_tool_resource = get_resource_slot2(sel_pistol)
	return equip_attack_tool(attack_tool_resource, hand)

func slot3_key_action(act_atk_tool):
	var attack_tool_resource
	if !inventory.has("shotgun"):
		print('No shotgun in inventory')
		attack_tool_resource = res_unarmed_p
	else:
		if act_atk_tool.editor_description == "shotgun":
			return act_atk_tool
		else:
			attack_tool_resource = get_resource_slot3()
	return equip_attack_tool(attack_tool_resource, hand)

func equip_attack_tool(resource, attach_point, drop_current=true):
	reset_raycast(raycast)
	if drop_current and attach_point.get_child_count() > 0:
		for held in attach_point.get_children():
			held.queue_free()

	var attack_tool_p = resource.instance()
	attach_point.add_child(attack_tool_p)
	attack_tool_p.rotation = attach_point.rotation

	if attack_tool_p.use_raycast:
		crosshair.visible = true
	else:
		crosshair.visible = false

	attack_tool_p.draw_tool()
	return attack_tool_p

func console_interpret(command_string):
	var console_output
	console_timer.stop()
	console_timer.start()

	match command_string:
		'space':
			print()
			console_output = ''
		'reset.raycast':
			reset_raycast(raycast)
			console_output = str(raycast.cast_to)
		'inventory':
			console_output = str(inventory)
		'print.weaptext':
			console_output = active_attack_tool.editor_description
		'fov+':
			viewport.fov += 5
			console_output = str(viewport.fov)
		'fov-':
			viewport.fov -= 5
			console_output = str(viewport.fov)
	console_print.text = str(console_output)

	return console_output

func attack2(camera, lift_item=null, default_fov=70, zoom_fov=25):
	# For now this is just zooming
	var zoom_speed = 5
	var lift_amount = 1
	if Input.is_action_pressed("attack2") and camera.fov > zoom_fov:
		camera.fov -= zoom_speed
		if lift_item:
			lift_item.translation.y += .03
	if Input.is_action_just_released("attack2") and camera.fov < 70:
		# camera.fov = default_fov
		while camera.fov < 70:
			camera.fov += zoom_speed
			if lift_item:
				lift_item.translation.y -= .03


func play_anim(name):
	if anim.current_animation == name:
		return
	anim.play(name)

func update_text():
	if active_attack_tool:
		if active_attack_tool.has_ammo:
			ammo_display.text = str(active_attack_tool.magazine_ammo) + ' / ' + str(active_attack_tool.carry_ammo)
	health_display.text = str(health)

func pain_overlay():
	color_overlay.color = Color(255, 0, 0, .1)
	color_overlay.visible = true
	timer_overlay.start()
	if timer_overlay.is_stopped():
		color_overlay.visible = false
		
func finished_overlay():
	color_overlay.color = Color(255, 255, 255, .1)
	color_overlay.visible = true

func next_in_array(array):
	var first_item = array[0]
	var array_last_index = len(array)-1
	var new_array = array.slice(1, array_last_index, 1)
	new_array.append(first_item)
	return new_array

func get_resource_slot2(select_pistol):
	# This function should return which resource in slot2
	# to give to equip_attack_tool
	if select_pistol == 'single':
		return res_pistol_p
	if select_pistol == 'akimbo':
		return res_akimbo_pistol_p

func get_resource_slot3():
	# This function should return which resource in slot3
	# to give to equip_attack_tool
	return res_shotgun_p

func _on_TimerOverlay_timeout():
	color_overlay.visible = false


func _on_Area_area_entered(entered_area):
	if entered_area.is_in_group("ammo"):
		pass
	if entered_area.is_in_group("pickups"):
		inventory.append(entered_area.name)
		entered_area.get_parent().queue_free()

########################################
## P H Y S I C S    P R O C E S S ######
########### L O O P    +    D E L T A ##
########################################

func _physics_process(delta):
	var move_vec = Vector3()
	var grounded = is_on_floor()
	
	if finished:
		finished_overlay()
		return

	if dead:
		mesh.translation.y = -0.55599
		mesh.translation.z = -0.51
		if mesh.rotation.x > -1.35:
			mesh.rotation.x -= .135
		if colshape.rotation.x < 3.040795:
			colshape.rotation.x += .304
		cam.rotation_degrees.x += .1
		return
		
	if !dead and health < last_health:
		pain_overlay()
		update_text()
	last_health = health
		
	if health < 1:
		dead = true
		return

	if grounded:
		z_velo = 0
		x_velo = 0
		rot_velo = rotation.y

	if grounded and !block_player_controls:
		if Input.is_action_pressed("run"):
			MOVE_SPEED = RUN_SPEED
		else:
			MOVE_SPEED = WALK_SPEED
		if Input.is_action_pressed("move_forwards"):
			z_velo -= 1
			move_vec.z = z_velo
		if Input.is_action_pressed("move_backwards"):
			z_velo += 1
			move_vec.z = z_velo
		if Input.is_action_pressed("move_left"):
			x_velo -= 1
			move_vec.x = x_velo
		if Input.is_action_pressed("move_right"):
			x_velo += 1
			move_vec.x = x_velo

		attack2(viewport, hand)

	if !grounded and !block_player_controls:
		move_vec.z = z_velo
		move_vec.x = x_velo
		if !block_player_controls:
			if Input.is_action_pressed("move_forwards"):
				move_vec.z -= AIR_MOVE_SPEED
			if Input.is_action_pressed("move_backwards"):
				move_vec.z += AIR_MOVE_SPEED
			if Input.is_action_pressed("move_left"):
				move_vec.x -= AIR_MOVE_SPEED
			if Input.is_action_pressed("move_right"):
				move_vec.x += AIR_MOVE_SPEED
	
	move_vec = move_vec.normalized()
	move_vec = move_vec.rotated(Vector3(0, 1, 0), rot_velo)
	move_vec *= MOVE_SPEED
	move_vec.y = y_velo
	move_and_slide(move_vec, Vector3(0, 1, 0))

	y_velo -= GRAVITY
	if !block_player_controls:
		if grounded and Input.is_action_just_pressed("jump"):
			y_velo = JUMP_FORCE

	if grounded and y_velo <= 0:
		y_velo = -0.1
	if y_velo < -MAX_FALL_SPEED:
		y_velo = -MAX_FALL_SPEED

	if !block_player_controls:
		if Input.is_action_just_pressed("crouch"):
			if grounded:
				y_velo += 5
		if Input.is_action_pressed("crouch"):

			mesh.translation.y = -0.55599
			mesh.translation.z = -0.51
			if mesh.rotation.x > -1.35:
				mesh.rotation.x -= .135
			if colshape.rotation.x < 3.040795:
				colshape.rotation.x += .304
			if viewport.translation.y > -0.19:
				viewport.translation.y -= 0.0475

		if Input.is_action_just_released("crouch"):
			mesh.translation.y = -1.06599
			mesh.translation.z = 0
			if mesh.rotation.x != 0:
				mesh.rotation.x = 0
			colshape.rotation.x = 1.570796
			viewport.translation.y = 0.409213

	if !grounded:
		play_anim("jump")
	elif grounded:
		if move_vec.x == 0 and move_vec.z == 0:
			play_anim("idle")
		else:
			play_anim("walk")

	if !block_player_controls:
		if Input.is_action_just_pressed("use"):
			var collider = raycast.get_collider()
			if collider:
				if collider.is_in_group("door"):
					var access_granted = collider.key in inventory
					if access_granted:
						collider.open()
				if collider.is_in_group("interactable"):
					collider.interact()
					if "exit_button_body" == collider.name:
						finished = collider.player_in_range

		if Input.is_action_just_pressed("attack"):
			if active_attack_tool:
				if active_attack_tool.use_raycast:
					active_attack_tool.attack(raycast)
					cam.rotation_degrees.x += active_attack_tool.recoil
					# 	reset_raycast(raycast)
				else:
					active_attack_tool.attack()
				update_text()

				match active_attack_tool.editor_description:
					"pistol":
						pistol_magazine = active_attack_tool.magazine_ammo
					"akimbo":
						akimbo_magazine = active_attack_tool.magazine_ammo
					"shotgun":
						shotgun_magazine = active_attack_tool.magazine_ammo
				

		if Input.is_action_just_pressed("reload"):
			if active_attack_tool:
				active_attack_tool.reload()
			update_text()


		#######################
		## I N V E N T O R Y ##
		#######################

		if Input.is_action_just_pressed("inv_slot_1"):
			var is_knife = 'knife' in active_attack_tool.editor_description
			if !is_knife:
				active_attack_tool = equip_attack_tool(res_knife_p, hand)

		if Input.is_action_just_pressed("inv_slot_2"):
			active_attack_tool = slot2_key_action(active_attack_tool, selected_pistol, pistol_count)
			if active_attack_tool:
				if active_attack_tool.editor_description == "akimbo":
					active_attack_tool.magazine_ammo = akimbo_magazine
				if active_attack_tool.editor_description == "pistol":
					active_attack_tool.magazine_ammo = pistol_magazine
		
		if Input.is_action_just_pressed("inv_slot_3"):
			active_attack_tool = slot3_key_action(active_attack_tool)
			if active_attack_tool.editor_description == "shotgun":
				active_attack_tool.magazine_ammo = shotgun_magazine

		##################################
		## D E B U G    C O N T R O L S ##
		##################################

		if Input.is_action_just_pressed("console"):
			console.visible = true
			console.grab_focus()
			# vim://" console_interpret "

		if Input.is_action_just_pressed("debug_button"): # O
			raycast.cast_to.x += 1

		if Input.is_action_just_pressed("debug_button2"): # P
			get_tree().change_scene("res://World.tscn")

########################################
## S I G N A L S #######################
############### A N D ##################
##################### C O N N E C T S ##
########################################

func _on_Area_body_entered(body):
	# if 'pistol_w' in body.name:
	if body.editor_description == "pistol_w":
		# If not in inventory, add
		# Add body.ammo to carry ammo
		pistol_ammo += body.ammo
		if "pistol" in active_attack_tool.editor_description:
			active_attack_tool.carry_ammo = pistol_ammo
		if "akimbo" in active_attack_tool.editor_description:
			active_attack_tool.carry_ammo = pistol_ammo
		update_text()
		body.queue_free()

		if pistol_count < 2:
			pistol_count += 1
		if "pistol" in inventory:
			pass
		else:
			inventory.append("pistol")

	if body.editor_description == "shotgun_w":
		shotgun_ammo += body.ammo
		if active_attack_tool.editor_description == "shotgun":
			active_attack_tool.carry_ammo = shotgun_ammo
		update_text()
		body.queue_free()

		if "shotgun" in inventory:
			pass
		else:
			inventory.append("shotgun")

func _on_LineEdit_focus_entered():
	block_player_controls = true # Replace with function body.

func _on_LineEdit_focus_exited():
	block_player_controls = false # Replace with function body.

func _on_ConsoleTimer_timeout():
	console_print.text = ''

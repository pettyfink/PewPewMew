extends Spatial

onready var anim = $AnimationPlayer
onready var anim_effects = $EffectsPlayer
var damage = 8*5
var recoil = 1.8
var use_raycast = true
var has_ammo = true
const MAX_MAGAZINE_AMMO = 8
const MAX_CARRY_AMMO = 120
var magazine_ammo = 0
var carry_ammo = 12
var weap_name = 'shotgun'
var pump_needed
var spread = 5

# onready var res_csg_subtraction_box = preload("res://scenes/csg_subtraction_box.tscn")

func _ready():
	pump_needed = false
	if magazine_ammo < 1:
		recoil = 0
		

# #### Original Attack (one raycast)
func attack(raycast):
	if magazine_ammo < 1:
		# Play click sound?
		return

	if pump_needed:
		anim.play("pump")
		anim.queue("Idle")
		pump_needed = false
		recoil = 0
		return

	pump_needed = true

	magazine_ammo -= 1
	if magazine_ammo < 1:
		recoil = 0
	elif magazine_ammo > 0:
		recoil = 1.8

	if anim.is_playing():
		anim.stop()
	if anim_effects.is_playing():
		anim_effects.stop()

	anim.play("shoot1")
	anim_effects.play("flash")
	anim_effects.queue("hide")
	anim.queue("Idle")
	var collider = raycast.get_collider()
	if collider == null:
		return

	if collider is RigidBody:
		var impulse_direction = raycast.global_transform.origin - collider.global_transform.origin
		var impulse_force = impulse_direction * .6
		var up_force = Vector3.UP * .1
		# collider.apply_impulse(impulse_force, Vector3.UP)
		collider.apply_impulse(impulse_force, (-impulse_force * 9) + up_force)

#	if !collider.is_in_group("damage_taker") and collider is CSGCombiner:
#		var collider_children = collider.get_children()
#		var collider_holes = 0
#		for child in collider_children:
#			if child is CSGSphere:
#				collider_holes += 1
#		# if len(collider_children) > 5:
#		if collider_holes > 5:
#			for child in collider_children:
#				if child is CSGSphere:
#					child.queue_free()
#					break
#		var csg_subtraction_box = res_csg_subtraction_box.instance()
#		collider.add_child(csg_subtraction_box)
#		csg_subtraction_box.scale = csg_subtraction_box.scale * 4
#		var collision_point = raycast.get_collision_point()
#		csg_subtraction_box.global_transform.origin = collision_point
#		# csg_subtraction_box.look_at(collision_point + raycast.get_collision_normal(), Vector3.UP)

	if collider.is_in_group("damage_taker"):
		collider.health -= damage

func reload():
	if magazine_ammo >= MAX_MAGAZINE_AMMO:
		return
	if carry_ammo < 1:
		return
	
	anim.play("reload")
	anim.queue("Idle")
	
	var ammo_needed = 1 # MAX_MAGAZINE_AMMO - magazine_ammo
	if carry_ammo >= ammo_needed:
		magazine_ammo += 1
		carry_ammo -= 1
		recoil = 1.8
	else:
		pass # ?
	
#		magazine_ammo += carry_ammo
#		carry_ammo = 0

func draw_tool():
#	anim.play("no_animation")
	anim.play("Draw")
	anim.queue("Idle")

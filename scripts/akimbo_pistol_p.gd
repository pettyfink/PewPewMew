extends Spatial

#onready var anim = $AnimationPlayer
#onready var anim_effects = $Effects/EffectsPlayer

onready var hacky_anim_fix = $hacky_anim_player
onready var pistol1_anim = $pistol_p/AnimationPlayer
onready var pistol1_anim_effects = $pistol_p/Effects/EffectsPlayer

onready var pistol2_anim = $extra_hand/pistol_p2/AnimationPlayer
onready var pistol2_anim_effects = $extra_hand/pistol_p2/Effects/EffectsPlayer

# onready var res_bullet_mark = preload("res://bullet_mark.tscn")
# onready var res_csg_subtraction_box = preload("res://csg_subtraction_box.tscn")

var damage = 15
var recoil = .8
var use_raycast = true
var has_ammo = true
const MAX_MAGAZINE_AMMO = 18*2
const MAX_CARRY_AMMO = 120*2
var magazine_ammo
var carry_ammo = 36*2
var weap_name = 'akimbo_pistol'
var shoot_toggle

func _ready():
	hacky_anim_fix.play("Idle")
	shoot_toggle = 'pistol1'

func attack(raycast):
	if magazine_ammo < 1:
		# Play click sound?
		return

	if pistol1_anim.is_playing():
		pistol1_anim.stop()
	if pistol2_anim.is_playing():
		pistol2_anim.stop()

	if pistol1_anim_effects.is_playing():
		pistol1_anim_effects.stop()
	if pistol2_anim_effects.is_playing():
		pistol2_anim_effects.stop()

	magazine_ammo -= 1

	if shoot_toggle == 'pistol1':
		pistol1_anim.play("shoot1")
		pistol1_anim_effects.play("flash")
		pistol1_anim_effects.queue("hide")
		pistol1_anim.queue("Idle")
		shoot_toggle = 'pistol2'

	elif shoot_toggle == 'pistol2':
		pistol2_anim.play("shoot1")
		pistol2_anim_effects.play("flash")
		pistol2_anim_effects.queue("hide")
		pistol2_anim.queue("Idle")
		shoot_toggle = 'pistol1'

	var collider = raycast.get_collider()
	if collider == null:
		return
		
	if collider is RigidBody:
		var impulse_direction = raycast.global_transform.origin - collider.global_transform.origin
		var impulse_force = impulse_direction * .25
		collider.apply_impulse(impulse_force, Vector3.UP)
		# collider.apply_impulse(impulse_force, -impulse_force * 5)

#	if !collider.is_in_group("damage_taker") and collider is CSGCombiner:
#		var collider_children = collider.get_children()
#
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
#		var collision_point = raycast.get_collision_point()
#		csg_subtraction_box.global_transform.origin = collision_point
	
	if collider.is_in_group("damage_taker"):
		collider.health -= damage


func reload():
	if magazine_ammo >= MAX_MAGAZINE_AMMO:
		return
	if carry_ammo < 1:
		return
	
	pistol1_anim.play("reload")
	pistol1_anim.queue("Idle")
	pistol2_anim.play("reload")
	pistol2_anim.queue("Idle")
	
	var ammo_needed = MAX_MAGAZINE_AMMO - magazine_ammo
	if carry_ammo >= ammo_needed:
		magazine_ammo += ammo_needed
		carry_ammo -= ammo_needed
	else:
		magazine_ammo += carry_ammo
		carry_ammo = 0

func draw_tool():
#	anim.play("no_animation")
	pistol1_anim.play("Draw")
	pistol1_anim.queue("Idle")
	pistol2_anim.play("Draw")
	pistol2_anim.queue("Idle")

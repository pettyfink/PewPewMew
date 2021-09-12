extends Spatial

onready var anim = $AnimationPlayer
onready var anim_effects = $Effects/EffectsPlayer

onready var sound_area = $sound_area
var damage = 15
var recoil = .8
var use_raycast = true
var has_ammo = true
const MAX_MAGAZINE_AMMO = 18
const MAX_CARRY_AMMO = 120
var magazine_ammo = 0
var carry_ammo = 36
var weap_name = 'pistol'

# onready var res_bullet_mark = preload("res://bullet_mark.tscn")
# onready var res_csg_subtraction_box = preload("res://csg_subtraction_box.tscn")

func _ready():
	pass

func attack(raycast):
	if magazine_ammo < 1:
		# Play click sound?
		return

	if anim.is_playing():
		anim.stop()
	if anim_effects.is_playing():
		anim_effects.stop()
	magazine_ammo -= 1
	anim.play("shoot1")
	anim_effects.play("flash")
	anim_effects.queue("hide")
	anim.queue("Idle")

	for body in sound_area.get_overlapping_bodies():
		if body.is_in_group("sound_listener"):
			body.attack_heard = true
			body.last_target_origin = global_transform.origin

	var collider = raycast.get_collider()
	if collider == null:
		return
		
	if collider is RigidBody:
		var impulse_direction = raycast.global_transform.origin - collider.global_transform.origin
		var impulse_force = impulse_direction * .25
		collider.apply_impulse(impulse_force, Vector3.UP)
	
	if collider.is_in_group("damage_taker"):
		collider.health -= damage

func reload():
	if magazine_ammo >= MAX_MAGAZINE_AMMO:
		return
	if carry_ammo < 1:
		return
	
	anim.play("reload")
	anim.queue("Idle")
	
	var ammo_needed = MAX_MAGAZINE_AMMO - magazine_ammo
	if carry_ammo >= ammo_needed:
		magazine_ammo += ammo_needed
		carry_ammo -= ammo_needed
	else:
		magazine_ammo += carry_ammo
		carry_ammo = 0

func draw_tool():
#	anim.play("no_animation")
	anim.play("Draw")
	anim.queue("Idle")

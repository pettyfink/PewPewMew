extends Spatial

onready var rigid_body = $RigidBody
var has_been_forced = false
var random_number

func _ready():
	pass

func _process(delta):
	if rigid_body.health <= 0:
		if !has_been_forced:
			random_number = rand_range(-50,50)
			rigid_body.apply_impulse(-transform.basis.y, transform.basis.y * 100)
			rigid_body.apply_impulse(-transform.basis.z, transform.basis.z * 10)
			rigid_body.apply_impulse(-transform.basis.x, transform.basis.x * random_number)
			has_been_forced = true


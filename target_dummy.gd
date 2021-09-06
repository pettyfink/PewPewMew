extends KinematicBody

var health = 100
onready var res_phys_ball = preload("res://phys_ball.tscn")

func _ready():
	pass

func _process(delta):
	if health <= 0:
		queue_free()

func interact():
	spawn_ball()

func spawn_ball():
	var phys_ball = res_phys_ball.instance()
	add_child(phys_ball)
	phys_ball.add_collision_exception_with(get_parent())
	phys_ball.global_transform = global_transform
	phys_ball.apply_impulse(transform.basis.z, -transform.basis.z * 5)
	# phys_ball.apply_impulse(player_pos.origin, -player_pos.origin)

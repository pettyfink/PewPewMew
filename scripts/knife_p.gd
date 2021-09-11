extends Spatial

onready var anim = $AnimationPlayer
onready var hitbox = $Hitbox
var damage = 15
var use_raycast = false
var has_ammo = false

func _ready():
	pass # Replace with function body.

func attack():
	if anim.is_playing():
		anim.stop()
	anim.play("swipe1")
	for body in hitbox.get_overlapping_bodies():
		if body.is_in_group("Player"):
			return
		if body.is_in_group("damage_taker"):
			body.health -= damage

func draw_tool():
	anim.play("Draw")
	anim.queue("Idle")

func reload():
	pass

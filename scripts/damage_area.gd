extends Spatial

onready var hitbox = $Area
onready var timer = $Timer
var damage = 20

func _ready():
	pass # Replace with function body.

func _process(delta):
	if timer.is_stopped():
		for body in hitbox.get_overlapping_bodies():
			if body.is_in_group("damage_taker"):
				body.health -= damage
				timer.start()

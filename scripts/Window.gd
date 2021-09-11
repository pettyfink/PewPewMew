extends Spatial

onready var glass_unbroken = $glass_unbroken
onready var glass_unbroken_staticbody = $glass_unbroken/StaticBody
onready var glass_broken = $glass_broken
var dead = false

func _ready():
	glass_broken.visible = false

func _process(delta):
	if dead:
		return
	if glass_unbroken_staticbody.health <= 0:
		dead = true
		glass_broken.visible = true
		glass_unbroken.queue_free()

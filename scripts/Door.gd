extends Spatial

onready var door_mesh = $door_mesh
var opened
var original_y
var open_speed = .5

func _ready():
	original_y = door_mesh.translation.y

func open_drop():
	if opened:
		return
	if door_mesh.translation.y >= (original_y + 1.5):
		opened = true
	door_mesh.translation.y += open_speed

func open_lift():
	pass

#func _process(delta):
#	pass


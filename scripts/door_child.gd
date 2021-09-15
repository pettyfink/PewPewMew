extends Spatial

var opened_vector
var closed_vector

func _ready():
	if editor_description == "self":
		var door_actor = get_parent()
		var script = load("res://door_child.gd")
		door_actor.add_to_group("interactable")
		door_actor.set_script(script)
	opened_vector = global_transform.origin
	var vector_shifted_by_x = global_transform.origin
	vector_shifted_by_x.x += 1
	closed_vector = vector_shifted_by_x

func interact():
	if editor_description == "self":
		print('Self interacted.')
		return
	var direction = (closed_vector - global_transform.origin)
	if direction.length() < 1:
		global_transform.origin = opened_vector
	else:
		global_transform.origin = closed_vector

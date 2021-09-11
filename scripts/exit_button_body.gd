extends StaticBody

onready var switch = $Graphics/switch_mesh
onready var anim = $Graphics/AnimationPlayer
onready var area = $Area
var is_on = false
var health = 1
var player_in_range = false

func _ready():
	pass # Replace with function body.

func interact():
	if !player_in_range:
		return
	if is_on:
		return
	else:
		anim.play("switch_on")
		anim.queue("on")
		is_on = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area_body_entered(body):
	if body.is_in_group("Player"):
		player_in_range = true


func _on_Area_body_exited(body):
	if body.is_in_group("Player"):
		player_in_range = false

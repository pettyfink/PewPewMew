extends Spatial

onready var mover_nodetest = $Mover
onready var res_metro = preload("res://scenes/Catbot_Metro.tscn")
var metro_mover

onready var player = $Player
onready var static_body = $StaticBody

func _ready():
#	pass
	metro_mover = res_metro.instance()
	mover_nodetest.add_child(metro_mover)
	metro_mover.global_transform = mover_nodetest.global_transform

func _physics_process(delta):
	if Input.is_action_just_pressed("debug_button"):
		print('doing nothing, please delete me. I\'m in World.gd')

	if Input.is_action_just_pressed('ui_up'):
		mover_nodetest.move_forwards(metro_mover, 3)
	if Input.is_action_just_pressed('ui_down'):
		mover_nodetest.move_backwards(metro_mover, 3)
	if Input.is_action_just_pressed('ui_right'):
		mover_nodetest.move_right(metro_mover, 3)
	if Input.is_action_just_pressed('ui_left'):
		mover_nodetest.move_left(metro_mover, 3)

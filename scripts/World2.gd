extends Spatial

onready var red_key = $RedKey
onready var red_door = $RedDoor/door_mesh/door_body
onready var catbot_shotgun = $Catbot_Metro
onready var catbot_shotgun2 = $Catbot_Metro2
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	red_door.key = 'key_pickup'
	catbot_shotgun.weapon_choice = 'shotgun'
	catbot_shotgun2.weapon_choice = 'shotgun'

#func _process(delta):
#	pass

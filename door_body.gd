extends StaticBody

onready var Door = get_parent().get_parent()
var key = 'freekey'

func _ready():
	pass # Replace with function body.

func open():
	Door.open_drop()

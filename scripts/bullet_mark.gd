extends Spatial

onready var timer = $cleanup_timer

func _ready():
	timer.start()
	



func _on_cleanup_timer_timeout():
	queue_free() # Replace with function body.

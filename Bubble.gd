extends "res://Shape.gd"

var timer = 0.0

func _process(delta):
	super._process(delta)
	if timer > 0.0:
		timer -= delta
	else:
		if visible:
			hide()

func display():
	if timer <= 0:
		timer = 0.2
		show()

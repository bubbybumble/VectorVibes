extends "res://Shape.gd"

var bpm = 120.0
var dance_timer = 1 * (60.0 / bpm)
var dancing = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
	if not dancing:
		return
	if dance_timer <= 0:
		dance_timer = 1 * (60.0 / bpm)
		if $body.visible:
			$body.hide()
			$body2.show()
		else:
			$body2.hide()
			$body.show()
	dance_timer -= delta
	

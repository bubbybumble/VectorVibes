extends CanvasItem

# for notes: 0, 1, 2, 3 = d, f, j, k respectively - second value is beats after current beat
var bpm = 120.0
var notes_to_display
var start_time
var iteration = 0
var score = 0
var started = false
var notes = PackedVector3Array()
var health = 3
var bubbles

var bubble


var state = "start"
var time_to_next_turn = 0.0

func start_game():
	start_time = Time.get_ticks_msec() * .001
	$AudioStreamPlayer.play()

func _ready():
	bubbles = [$D, $F, $J, $K]


func generate_note_set():
	
	var possible_patterns = [
		PackedVector3Array([
			Vector3(0, 0.0, 0),
			Vector3(0, 2.0, 0),
		]),
		PackedVector3Array([
			Vector3(0, 1.0, 0),
			Vector3(0, 3.0, 0),
		]),
#		PackedVector3Array([
#			Vector3(0, 1.0, 0),
#			Vector3(0, 3.0, 0),
#			Vector3(0, 3.5, 0),
#		]),
#		PackedVector3Array([
#			Vector3(0, 1.0, 0),
#			Vector3(0, 3.0, 0), 
#			Vector3(0, 3.0 + 1.0/3.0, 0),
#			Vector3(0, 3.0 + 2.0/3.0, 0),
#		]),
	]
	
	var new_notes = possible_patterns[randi_range(0, possible_patterns.size() - 1)]
	
	
	for i in range(new_notes.size()):
		new_notes[i].y = ( (60.0 / bpm) * new_notes[i].y ) + time_to_next_turn
		new_notes[i].x = randi_range(0, 3)
		
	for i in range(notes.size()):
		notes[i].z = 0
	
	time_to_next_turn += (60.0 / bpm) * 4.0
	notes.append_array(new_notes)

		

func apply_damage():
	for note in notes:
		if note.z == 0:
			health -= 1
			$health.text = "HEALTH: " + str(health)
	if health <= 0:
		Settings.score = score
		get_tree().change_scene_to_file("res://game_over.tscn")

func score_input(n, time):
	var dist = 234543456357 # loool
	var closest_note = 0
	for i in range(notes.size()):
		var note = notes[i]
		if note.z == 0 and note.x == n:
			if abs(time - note.y) < dist:
				dist = abs(time - note.y)
				closest_note = i
	
	if dist < .05:
		notes[closest_note].z = 1
		return 10
	if dist < .15:
		notes[closest_note].z = 1
		return 4
	if dist < .25:
		notes[closest_note].z = 1
		return 1
	return 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not start_time:
		return
	
	var time = (Time.get_ticks_msec() * .001) - start_time
	if time >= time_to_next_turn:
		$countdown.text = "GO!!! :D"
		start_time = Time.get_ticks_msec() * .001
		
		if state == "start":
			generate_note_set()
			notes_to_display = notes.duplicate()
			state = "saying"
			$countdown.text = ""
		elif state == "saying":
			state = "listening"
		else:
			apply_damage()
			generate_note_set()
			state = "saying"
			$countdown.text = ""
			notes_to_display = notes.duplicate()
		return
	
	if state == "saying":
		if time_to_next_turn - time <= 1 * (60.0 / bpm):
			$countdown.text = "1"
		elif time_to_next_turn - time <= 2 * (60.0 / bpm):
			$countdown.text = "2"
		elif time_to_next_turn - time <= 3 * (60.0 / bpm):
			$countdown.text = "3"
		
		
		
		var notes_to_remove = []
		
		for i in range(notes_to_display.size()):
			var note = notes_to_display[i]
			if note.y <= time:
				notes_to_remove.insert(0, i)
				if note.x == 0:
					$d.play()
				if note.x == 1:
					$f.play()
				if note.x == 2:
					$j.play()
				if note.x == 3:
					$k.play()
				bubble = bubbles[note.x]
				bubble.display()
		for i in notes_to_remove:
			notes_to_display.remove_at(i)
	
	if state == "listening":
		if Input.is_action_just_pressed("d"):
			$Stewart.wiggle_amt = 10
			$d.play()
			score += score_input(0, time)
			$score.text = "SCORE: " + str(score)
		if Input.is_action_just_pressed("f"):
			$Stewart.wiggle_amt = 10
			$f.play()
			score += score_input(1, time)
			$score.text = "SCORE: " + str(score)
		if Input.is_action_just_pressed("j"):
			$Stewart.wiggle_amt = 10
			$j.play()
			score += score_input(2, time)
			$score.text = "SCORE: " + str(score)
		if Input.is_action_just_pressed("k"):
			$Stewart.wiggle_amt = 10
			$k.play()
			score += score_input(3, time)
			$score.text = "SCORE: " + str(score)



func _input(event):
	if !start_time:
		if event.is_action("space"):
			$space.hide()
			start_game()

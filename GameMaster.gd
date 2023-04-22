extends CanvasItem

# for notes: 0, 1, 2, 3 = d, f, j, k respectively - second value is beats after current beat
var bpm = 120.0
var notes_to_display
var start_time
var iteration = 0
var score = 0
var started = false
var notes = PackedVector2Array()

var bubbles

var bubble

var input_scores = [0, 0, 0, 0]

var state = "start"
var time_to_next_turn = 0.0

func start_game():
	generate_note_set()
	start_time = Time.get_ticks_msec() * .001
	$AudioStreamPlayer.play()

func _ready():
	bubbles = [$D, $F, $J, $K]


func generate_note_set():
	
	var possible_patterns = [
		PackedVector2Array([
			Vector2(0, 0.0),
			Vector2(0, 2.0),
		]),
		PackedVector2Array([
			Vector2(0, 1.0),
			Vector2(0, 3.0),
		]),
		PackedVector2Array([
			Vector2(0, 1.0),
			Vector2(0, 3.0),
			Vector2(0, 3.5),
		]),
		PackedVector2Array([
			Vector2(0, 1.0),
			Vector2(0, 3.0),
			Vector2(0, 3.0 + 1.0/3.0),
			Vector2(0, 3.0 + 2.0/3.0),
		]),
	]
	
	var new_notes = possible_patterns[randi_range(0, possible_patterns.size() - 1)]
	
	
	for i in range(new_notes.size()):
		new_notes[i].y = ( (60.0 / bpm) * new_notes[i].y ) + time_to_next_turn
		new_notes[i].x = randi_range(0, 3)
		
	time_to_next_turn += (60.0 / bpm) * 4.0
	notes.append_array(new_notes)
	for i in range(4):
		input_scores[i] = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not start_time:
		return
	
	var time = (Time.get_ticks_msec() * .001) - start_time
	if time >= time_to_next_turn:
		start_time = Time.get_ticks_msec() * .001
		
		
		if state == "saying":
			state = "listening"
		else:
			generate_note_set()
			state = "saying"
			notes_to_display = notes.duplicate()
			print(score)
		return
	
	if state == "saying":
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
		for i in range(notes.size()):
			var note = notes[i]
			if input_scores[note.x] != -1:
				var diff = abs(note.y - time)
				if diff < .2:
					input_scores[note.x] = 1
				if diff < .15:
					input_scores[note.x] = 4
				if diff < .05:
					input_scores[note.x] = 10


func _input(event):
	if start_time:
		if event.is_action_pressed("d"):
			score += input_scores[0]
			input_scores[0] = -1
		if event.is_action_pressed("f"):
			score += input_scores[1]
			input_scores[1] = -1
		if event.is_action_pressed("j"):
			score += input_scores[2]
			input_scores[2] = -1
		if event.is_action_pressed("k"):
			score += input_scores[3]
			input_scores[3] = -1
	else:
		if event.is_action("space"):
			start_game()

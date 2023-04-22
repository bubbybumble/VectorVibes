extends CanvasItem

# for notes: 0, 1, 2, 3 = d, f, j, k respectively - second value is beats after current beat
var bpm = 120.0

var start_time

var score = 0

var notes

var bubbles

var input_scores = [0, 0, 0, 0]

var state = "start"
var time_to_next_turn = (60.0 / bpm) * 4.0

func _ready():
	generate_note_set()
	bubbles = [$D, $F, $J, $K]
	start_time = Time.get_ticks_msec() * .001

func generate_note_set():
	notes = PackedVector2Array([
		Vector2(0, 0.0),
		Vector2(1, 1.0),
		Vector2(2, 2.0),
		Vector2(3, 3.0)
	])
	
	for i in range(notes.size()):
		notes[i].y = (60.0 / bpm) * notes[i].y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var time = (Time.get_ticks_msec() * .001) - start_time
	if time >= time_to_next_turn:
		start_time = Time.get_ticks_msec() * .001
		print(score)
		$AudioStreamPlayer.play()
		
		if state == "saying":
			state = "listening"
		else:
			generate_note_set()
			state = "saying"
		return
	
	if state == "saying":
		for i in range(notes.size()):
			var note = notes[i]
			if note.y <= time:
				if note.y + .4 <= time:
					bubbles[note.x].hide()
				else:
					bubbles[note.x].show()
	
	if state == "listening":
		for i in range(notes.size()):
			var note = notes[i]
			if note.y - .25 <= time:
				if note.y + .25 <= time:
					input_scores[note.x] = 0
				else:
					input_scores[note.x] = 1

func _input(event):
	if event.is_action_pressed("d"):
		score += input_scores[0]
		input_scores[0] = 0
	if event.is_action_pressed("f"):
		score += input_scores[1]
		input_scores[1] = 0
	if event.is_action_pressed("j"):
		score += input_scores[2]
		input_scores[2] = 0
	if event.is_action_pressed("k"):
		score += input_scores[3]
		input_scores[3] = 0

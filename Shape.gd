extends Node2D

var wiggle_amt = 1.0

const line_thickness = 2

var num_lines 

func _ready():
	num_lines = get_child_count()
	for i in range(num_lines):
		var line = get_child(i)
		line.width = 0
	
	
func _draw():
	for i in range(num_lines):
		var line = get_child(i)
		if line.visible:
			var vertices = line.points.duplicate()
			
			for j in range(vertices.size()):
				vertices[j] += line.position
				
			if vertices[0] == vertices[vertices.size() - 1]:
				wiggle(vertices)
				vertices[0] = vertices[vertices.size() - 1]
			else:
				wiggle(vertices)
			
			draw_polyline(vertices, line.default_color, line_thickness)
	
func wiggle(v):
	for i in range(v.size()):
		v[i].x += randi_range(-wiggle_amt,wiggle_amt) # only a bit of wiggle is a sufficient jiggle!
		v[i].y += randi_range(-wiggle_amt,wiggle_amt)


	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()
	if wiggle_amt > 1:
		wiggle_amt -= delta * 5
	wiggle_amt = max(wiggle_amt, 1)
		

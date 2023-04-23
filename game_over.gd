extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Score.text = "SCORE: " + str(Settings.score)



func _input(event):
	if event.is_action("enter"):
		get_tree().change_scene_to_file("res://level.tscn")
	if event.is_action("escape"):
		get_tree().change_scene_to_file("res://title_screen.tscn")

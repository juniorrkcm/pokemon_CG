class_name MainMenu
extends Control

@onready var play = $MarginContainer/Play as Button
@onready var quit = $MarginContainer2/Quit as Button
@onready var start_level = preload("res://levels/scenes/test_level.tscn") as PackedScene

func _ready():
	play.button_down.connect(on_start_pressed)
	quit.button_down.connect(on_quit_pressed)
		
func on_start_pressed() -> void:
	get_tree().change_scene_to_packed(start_level)

func on_quit_pressed() -> void:
	get_tree().quit()
	
	

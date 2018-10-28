extends Node2D

onready var label = $PanelContainer/Panel/RichTextLabel

func _ready():
	var version = Engine.get_version_info()
	label.add_text("Made with Godot version " + version["string"])
	
func on_start_pressed():
	get_tree().change_scene("res://scenes/Main.tscn")

func on_credits_pressed():
	get_tree().change_scene("res://scenes/Credits.tscn")

func on_settings_pressed():
	get_tree().change_scene("res://scenes/Settings.tscn")

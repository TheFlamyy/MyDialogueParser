tool
extends EditorPlugin

const custom_type := "MyDialogueParser"
const script_path := "res://addons/my-dialogue-parser/MDP.gd"

func _enter_tree():
	add_custom_type(custom_type, "Node", preload(script_path), preload("res://addons/my-dialogue-parser/Icon.png"))


func _exit_tree():
	remove_custom_type(custom_type)
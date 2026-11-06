class_name TerminalSpawner extends Node3D


const TERMINAL_SCENE: PackedScene = preload("res://Scenes/Level Design/Stage Elements/terminal.tscn");


@export var angles: Vector3;


func _func_godot_apply_properties(props:Dictionary)->void:
	if props.is_empty():
		return;

	angles = Vector3.ZERO if !props.has('angles') else props['angles'];


func _ready()->void:
	GDPatch.get_mod("customspheres").compile_complete.connect(spawn, ConnectFlags.CONNECT_ONE_SHOT);
	LoadingScreen.scene_loaded.connect(spawn, ConnectFlags.CONNECT_ONE_SHOT);


func spawn()->void:
	print("TERMINAL SPAWN")
	var _s := TERMINAL_SCENE.instantiate();
	get_tree().current_scene.add_child(_s);
	_s.global_position = self.global_position;
	angles.x = deg_to_rad(angles.x);
	angles.y = deg_to_rad(angles.y);
	angles.z = deg_to_rad(angles.z);
	self.rotation = angles;

	_s.position = self.position;
	_s.rotation = self.rotation;

	self.queue_free();
@tool
class_name TerminalSpawner extends Node3D


const TERMINAL_SCENE: PackedScene = preload("res://Scenes/Level Design/Stage Elements/terminal.tscn");


@export var angles: Vector3;


func _func_godot_apply_properties(props:Dictionary)->void:
	if props.is_empty():
		return;

	angles = Vector3.ZERO if !props.has('angles') else props['angles'];


func _ready()->void:
	var _s := TERMINAL_SCENE.instantiate();

	get_tree().edited_scene_root.add_child(_s);
	_s.owner = get_tree().edited_scene_root;
	_s.global_position = self.global_position;

	angles.y = deg_to_rad(angles.y);
	self.global_rotation = angles;
	#_s.global_transform.basis = Basis.from_euler(angles, EULER_ORDER_YXZ);

	self.queue_free();
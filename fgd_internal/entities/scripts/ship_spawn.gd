class_name ShipSpawner extends Node3D


const SHIP_SCENE: PackedScene = preload("res://Scenes/Level Design/Level Setup/ship.tscn");


@export var angles: Vector3;


func _func_godot_apply_properties(props:Dictionary)->void:
	if props.is_empty():
		return;

	angles = Vector3.ZERO if !props.has('angles') else props['angles'];


func _ready()->void:
	LoadingScreen.scene_loaded.connect(spawn, ConnectFlags.CONNECT_ONE_SHOT);


func spawn()->void:
	print("SHIP SPAWN")
	var _s := SHIP_SCENE.instantiate();
	get_tree().current_scene.add_child(_s);
	angles.x = deg_to_rad(angles.x);
	angles.y = deg_to_rad(angles.y);
	angles.z = deg_to_rad(angles.z);
	self.rotation = angles;
	self.global_transform.basis = Basis.from_euler(angles, EULER_ORDER_YXZ);

	_s.position = self.position;
	_s.rotation = self.rotation;

	self.queue_free();
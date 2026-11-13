class_name FuncMovingPlatform extends AnimatableBody3D


const SCALE_FACTOR: int = 32;


var start_pos: Vector3;
var end_pos: Vector3;
@export var time: float = 2.0;
@export var pause: float = 0.7;
@export var start_delay: float = 0.0;
@export var distance: float = 0.0;
@export var direction: Vector3 = Vector3(0, 1, 0);
var reverse: bool = false;
var end_target_override: String;
var brush_mesh: MeshInstance3D;
var brush_collider: CollisionShape3D;


func get_mesh()->MeshInstance3D:
	for c in self.get_children():
		if c is MeshInstance3D:
			return c;
	return null;


func get_collider()->CollisionShape3D:
	for c in self.get_children():
		if c is CollisionShape3D:
			return c;
	return null;


func _func_godot_apply_properties(props:Dictionary)->void:
	if props.is_empty():
		return;

	if props.has('direction'): direction = props['direction'];
	if props.has('distance'): distance = props['distance'];
	if props.has('pause'): pause = props['pause'];
	if props.has('time'): time = props['time'];

	start_pos = self.global_position;
	end_pos = self.global_position + (distance / SCALE_FACTOR) * direction;


func _ready()->void:
	LoadingScreen.scene_loaded.connect(spawn, ConnectFlags.CONNECT_ONE_SHOT);


func spawn()->void:##wanna see what i can do without touching base game code... ill tell you...
	print('[MOVING PLATFORM] SPAWNED')
	add_to_group("movingplatform");
	start_pos = self.global_position;
	end_pos = self.global_position + (distance / SCALE_FACTOR) * direction;

	await get_tree().physics_frame

	if start_delay <= 0:
		start_move();
	else:
		await get_tree().create_timer(start_delay).timeout
		start_move();


func start_move()->void:
	var _move_tween: Tween = create_tween().set_loops();
	_move_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS);

	if pause > 0:
		_move_tween.tween_interval(pause);	
	_move_tween.tween_property(self, "global_position", end_pos, time);
	
	if pause > 0:
		_move_tween.tween_interval(pause);	
	_move_tween.tween_property(self, "global_position", start_pos, time);

	#sounds TBD
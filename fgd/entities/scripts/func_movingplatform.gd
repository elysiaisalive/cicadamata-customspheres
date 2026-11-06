class_name FuncMovingPlatform extends Node3D


const MOVING_PLATFORM: PackedScene = preload("res://Scenes/Level Design/Stage Elements/moving_platform.tscn");
const SCALE_FACTOR: int = 32;


@export var start_pos: Vector3;
@export var end_pos: Vector3;
@export var time: float = 2.0;
@export var pause: float = 0.7;
@export var start_delay: float = -1.0;
@export var distance: float = 0.0;
@export var direction: Vector3 = Vector3(0, 1, 0);
@export var end_target_override: String;


var brush_mesh: MeshInstance3D;
var brush_collider: CollisionShape3D;


# func get_mesh()->MeshInstance3D:
# 	for c in self.get_children():
# 		if c is MeshInstance3D:
# 			return c;
# 	return null;


# func get_collider()->CollisionShape3D:
# 	for c in self.get_children():
# 		if c is CollisionShape3D:
# 			return c;
# 	return null;


#THIS IS SO DISGUSTING


# func _func_godot_apply_properties(props:Dictionary)->void:
# 	if props.is_empty():
# 		return;

# 	if props.has('direction'): direction = props['direction'];
# 	if props.has('distance'): distance = props['distance'];

# 	var _end_target: Node = get_tree().get_first_node_in_group(end_target_override);

# 	start_pos = self.global_position;

# 	if _end_target == null:
# 		end_pos = self.global_position + (distance / SCALE_FACTOR) * direction;
# 	else:
# 		end_pos = start_pos;


func _ready()->void:
	return
	#GDPatch.get_mod("customspheres").compile_complete.connect(spawn, ConnectFlags.CONNECT_ONE_SHOT);
	#LoadingScreen.scene_loaded.connect(spawn, ConnectFlags.CONNECT_ONE_SHOT);


# func spawn()->void:##wanna see what i can do without touching base game code... ill tell you...
# 	var _mover: Node3D = MOVING_PLATFORM.instantiate().duplicate();
# 	_mover.name = 'MovingToJamaica';
# 	_mover.time = self.time;
# 	_mover.pause = self.pause;
# 	_mover.start_delay = self.start_delay;
# 	_mover.a = self.start_pos;
# 	_mover.b = self.end_pos;

# 	brush_mesh = self.get_mesh();
# 	brush_collider = self.get_collider();
	
# 	var _verts: PackedVector3Array = brush_collider.shape.get_points();
	
# 	if _verts.is_empty():
# 		return;
	
# 	var _aabb: AABB = AABB(_verts[0], Vector3.ZERO);
# 	_aabb.position = _aabb.position * _mover.global_basis;
	
# 	for v in _verts:
# 		_aabb = _aabb.expand(v);

# 	_mover.global_position = self.start_pos;

# 	var _mover_mesh: Mesh = BoxMesh.new();
# 	_mover_mesh.size = _aabb.size;

# 	var _mover_collider: CollisionShape3D = _mover.find_child('CollisionShape3D');
# 	_mover_collider.shape = brush_collider.shape.duplicate();

# 	var _mover_meshinstance: MeshInstance3D = _mover.find_child('MeshInstance3D');
# 	var _material: BaseMaterial3D = _mover_meshinstance.get_surface_override_material(0).duplicate();
# 	var _uv_scale: float = 1 / SCALE_FACTOR;
# 	_material.uv1_triplanar = true;
# 	_material.uv1_scale = Vector3(_uv_scale, 0.0, _uv_scale);
# 	_material.uv1_offset = Vector3(0.51, -0.23, 0.495);

# 	_mover_meshinstance.set_surface_override_material(0, _material);
# 	_mover_meshinstance.mesh = _mover_mesh.duplicate();
# 	_mover_meshinstance.scale = Vector3(1.0, 1.0, 1.0);

# 	get_tree().current_scene.add_child(_mover);##we will just always assume the func_godot_map exists

# 	_mover.owner = get_tree().current_scene;
# 	_mover_meshinstance.owner = get_tree().current_scene
# 	_mover_collider.owner = get_tree().current_scene;
# 	#extremely fucked code
# 	for c in _mover.get_children():
# 		c.owner = get_tree().current_scene;

# 		if c.get_child_count() > 0:
# 			for nested in c.get_children():
# 				nested.owner = get_tree().current_scene;

# 	_mover.scene_file_path = "";

# 	self.queue_free();
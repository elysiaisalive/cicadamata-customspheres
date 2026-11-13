class_name FuncSpike extends Area3D


const SPIKE_MATERIAL: ShaderMaterial = preload('res://Assets/Materials/enemy_material.tres');
const SPIKE_MESH: ArrayMesh = preload("res://Assets/Models/spikemesh.res");

var cooldown: float = 0;
var distort: float = 0.0;
var multimesh_inst: MultiMeshInstance3D;
var mesh: MeshInstance3D;
var collision_shape: CollisionShape3D;
var spike_separation: float = 0.5;


func get_collider()->CollisionShape3D:
	for c in self.get_children():
		if c is CollisionShape3D:
			return c;
	return null;


func get_mesh()->MeshInstance3D:
	for c in self.get_children():
		if c is MeshInstance3D:
			return c;
	return null;


func init_material()->void:
	multimesh_inst.material_override = SPIKE_MATERIAL.duplicate();
	multimesh_inst.material_override.render_priority = 0;
	multimesh_inst.set_instance_shader_parameter("dissolve_amount",distort)
	multimesh_inst.set_instance_shader_parameter("distortion_strength",0.2)
	multimesh_inst.set_instance_shader_parameter("grid_size",0.01)


func init_spike_mesh()->void:
	print('[SPIKE GENERATION] SPIKE MESH GENERATING')
	var _verts: PackedVector3Array = collision_shape.shape.get_points();

	if _verts.is_empty():
		print('[SPIKE GENERATION] SPIKE MESH FAILED, no mesh')
		return;

	var _aabb: AABB = AABB(_verts[0], Vector3.ZERO);

	for v in _verts:
		_aabb = _aabb.expand(v);

	var _cols: int = floori(_aabb.size.x / spike_separation);
	var _rows: int = floori(_aabb.size.z / spike_separation);
	var _count: int = _cols * _rows;
	
	if _count == 0:
		print('[SPIKE GENERATION] SPIKE MESH FAILED, mesh is too small')
		return;

	if SPIKE_MESH == null:
		print('[SPIKE GENERATION] SPIKE MESH FAILED, base mesh not found')
		return;		

	var _mesh_res: MultiMesh = MultiMesh.new();

	_mesh_res.transform_format = MultiMesh.TRANSFORM_3D;
	_mesh_res.mesh = SPIKE_MESH;
	_mesh_res.instance_count = _count;

	var _collider_transform: Transform3D = multimesh_inst.global_transform.inverse() * collision_shape.global_transform;
	var _x: float = _aabb.position.x + (spike_separation / 2.0) + ((_aabb.size.x - (_cols * spike_separation)) / 2.0);
	var _z: float = _aabb.position.z + (spike_separation / 2.0) + ((_aabb.size.z - (_rows * spike_separation)) / 2.0);
	var _idx: int = 0;

	for r in range(_rows):
		for c in range(_cols):
			var _pos: Vector3 = Vector3(
				_x + (c * spike_separation),
				_aabb.position.y,
				_z + (r * spike_separation)
			);
			var _spikepos: Vector3 = _collider_transform * _pos;
			var _t: Transform3D = Transform3D(Basis(), _spikepos);
			_mesh_res.set_instance_transform(_idx, _t);
			_idx += 1;
			
	multimesh_inst.multimesh = _mesh_res;
	print('[SPIKE GENERATION] SPIKE MESH GENERATED')


func spawn()->void:
	multimesh_inst = MultiMeshInstance3D.new();
	multimesh_inst.name = 'Fuck';
	get_tree().current_scene.add_child(multimesh_inst);

	mesh = self.get_mesh();
	collision_shape = self.get_collider();
	init_spike_mesh();
	init_material();
	print('[SPIKE GENERATION] SPIKE MESH SPAWNED')


func _ready()->void:
	#GDPatch.get_mod("customspheres").func_godot_map.build_complete.connect(spawn, ConnectFlags.CONNECT_ONE_SHOT);
	#GDPatch.get_mod("customspheres").compile_complete.connect(spawn, ConnectFlags.CONNECT_ONE_SHOT);
	LoadingScreen.scene_loaded.connect(spawn, ConnectFlags.CONNECT_ONE_SHOT);


func _physics_process(delta: float) -> void:
	if global._player == null:
		return;
	var predistort = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.15,0.1,0.3]
	distort = predistort[randi() % predistort.size()]
	
	var presize = [0.01,0.02,0.05,1.0]
	var size = presize[randi() % presize.size()]
	
	multimesh_inst.set_instance_shader_parameter("dissolve_amount",distort)
	multimesh_inst.set_instance_shader_parameter("grid_size",size)
	
	if cooldown > 0:
		cooldown -= 1
	
	var _overlap = get_overlapping_bodies()

	for i in _overlap:
		
		if i is Player and cooldown <= 0:
			if i.active:
				cooldown = 5
				Audio.sound_play_ui(Audio.sndSpikeStab)
				i._damage(global_transform.origin)
				i._bounce(false)
				i.velocity.y += 4.0
				i._knockback_test()
			
		if i is Enemy and cooldown <= 0:
			cooldown = 5
			i._damage(500,"IMPALED",5.0)
			if i.enemy_type == Enemy.Type.FLOWER:
				i._flowerexplode()
			Audio.sound_play_suit(Audio.sndEnemyStab)
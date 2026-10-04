class_name CustomSphereLoader extends Node


#load idea
#scan mod dir for sphere resource
#scan mod dir for level resources
#construct custom level dictionary
#patch _setlevel to use custom stuff if a level is defined as custom
#patch _leveldata to use custom stuff if a level is defined as custom

#var level_data: Dictionary[String, Variant];
#var level_resources: Array[CustomSphereData];
var custom_levels: Dictionary[String, Variant];
var func_godot_map: FuncGodotMap;
#	level_data["lvl_debug"] = {
#		"pretitle": "SPHERE DEBUG",
#		"title": "CUBES",
#		"world" : 1,
#		"levelmusic": Audio.mscWorld1_Main,
#		"red_score" : 15000,
#		"dmnd_score" : 12000,
#		"gold_score" : 8000,
#		"slvr_score" : 5000,
#	}

const DEFAULT_LVL_DATA: Dictionary = {
	"pretitle": "CUSTOM",
	"title": "Joy",
	"path": "PATHGOESHERE"
};


func _ready()->void:
	load_custom_levels();

	if is_building_from_editor():
		var _global: Node = get_autoload('global');

		func_godot_map = FuncGodotMap.new();
		func_godot_map.map_settings = load("res://FuncGodot/cicada_cfg.tres");
		func_godot_map.hyperplane_size = 2048.0;

		if _global:
			get_tree().root.add_child(func_godot_map);
			await get_tree().process_frame
			build_map();


func load_custom_levels()->void:##Loads custom levels from the mods 'custom' folder and caches them in a dictionary
	var _level_dir: String = GDPatch.get_mod_directory("customspheres").path_join("/levels/");
	var _dir: DirAccess = DirAccess.open(_level_dir);

	if _dir:
		_dir.list_dir_begin();

		var _fname: String = _dir.get_next();

		while _fname != "":
			if _fname.ends_with(".tscn") || _fname.ends_with(".scn"):
				var _trimmed_id: String = _fname.get_basename();
				var _try_load: PackedScene = ResourceLoader.load(_level_dir.path_join(_fname));

				if _try_load != null:
					var _global: Node = get_autoload('global');

					custom_levels[_trimmed_id] = self.DEFAULT_LVL_DATA.duplicate();
					custom_levels[_trimmed_id].path = _level_dir.path_join(_fname);

				_fname = _dir.get_next();


func get_autoload(autoload:String)->Node:
	return Engine.get_main_loop().root.get_node(autoload);


func is_building_from_editor()->bool:
	for cmdline_arg in OS.get_cmdline_args():
		if cmdline_arg.contains("run_map::"):
			print('EDITOR BUILD')
			return true;

	return false;


func compile_map()->void:
	pass
	#pack to packedscene
	#save to mod folder!!!


# https://func-godot.github.io/func_godot_docs/FuncGodot%20Manual/FuncGodot%20Manual.html
func build_map()->void:
	print("BUILDING MAP")

	func_godot_map.build_complete.connect(run_map);

	for cmdline_arg in OS.get_cmdline_args():
		if cmdline_arg.contains("run_map::"):
			var arg_arr := cmdline_arg.split("::");

			if arg_arr.size() != 2:
				return;

			func_godot_map.global_map_file = arg_arr[1];
			func_godot_map.build();


func run_map()->void:##hack hack hack
	print("RUNNING MAP")
	var _level_path: String = GDPatch.get_mod_directory("customspheres").path_join("/levels/custom_level.tscn");
	var _scene: PackedScene = PackedScene.new();
	var _packed = _scene.pack(func_godot_map);
	
	ResourceSaver.save(_scene, _level_path, ResourceSaver.SaverFlags.FLAG_CHANGE_PATH);

	if _packed == OK:
		get_tree().change_scene_to_packed(_scene);
		await get_tree().process_frame

		var _env = load("res://Scenes/Level Design/Level Setup/Environments/env_world_1.tscn")
		var _global: Node = get_autoload("global");

		get_tree().root.add_child(_env.instantiate());
		_global.scene_path = _level_path;
		_global.currentlevel = _level_path.get_file().get_basename();
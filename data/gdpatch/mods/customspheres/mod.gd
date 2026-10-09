class_name CustomSphereLoader extends Node


var level_directory: String;
var custom_levels: Dictionary[String, Variant];
var func_godot_map: FuncGodotMap;
var __compile_level_path: String;


const DEFAULT_LVL_CFG: Dictionary = {
	"author": "DEMETER",
	"pretitle": "CUSTOM",
	"title": "Custom Level",
	"transition": "whats mine is yours,\n\t\tand what's yours is mine",
	"location": "UNIDENTIFIED",
	"conditions": "NEUTRAL + TEMPERATURE: ???°",
	"warning": "UNIDENTIFIED SPHERE DETECTED",
	"red_score" : 9999,
	"dmnd_score" : 999,
	"gold_score" : 99,
	"slvr_score" : 9,
};


func _ready()->void:
	init_custom_levels();
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


func init_custom_levels()->void:
	level_directory = GDPatch.get_mod_directory("customspheres").path_join("levels");
	DirAccess.make_dir_absolute(level_directory);


func init_levelbutton(node, level:String)->void:
	node.get_node('TextureRect').texture = GDPatch.get_mod("customspheres").load_thumbnail(level);
	node.get_node('WorldIcon').texture = GDPatch.get_mod("customspheres").load_icon(level);
	node.get_node('LvlPreTitle').text = GDPatch.get_mod("customspheres").custom_levels[level].pretitle;
	node.get_node('LvlName').text = GDPatch.get_mod("customspheres").custom_levels[level].title;
	node.get_node('LvlScore').text = GDPatch.get_mod("customspheres").custom_levels[level].author;
	node.get_node('LevelButton').pressed.connect(node.get_node("../../..")._on_lvl_pressed.bind(level, false));
	node.get_node('LevelButton').focus_entered.connect(node.get_node("../../..")._on_lvl_focus.bind(level, false));


func get_levels()->Array[String]:
	return DirAccess.get_directories_at(level_directory);


func get_shipscreen(level:String)->String:
	var _shiptext: String = "+ LOCATION: {location}, CASCADE\n+ CONDITIONS: {conditions}\n+ WARNING: {warning}\n+ TEAR FLESH FROM BONE"
	return _shiptext.format({
		"location": GDPatch.get_mod("customspheres").custom_levels[level].get('location', DEFAULT_LVL_CFG.location),
		"conditions": GDPatch.get_mod("customspheres").custom_levels[level].get('conditions', DEFAULT_LVL_CFG.conditions),
		"warning": GDPatch.get_mod("customspheres").custom_levels[level].get('warning', DEFAULT_LVL_CFG.warning),
	});


func get_ambience(level:String)->AudioStream:
	return GDPatch.get_mod("customspheres").custom_levels[level].get('ambience', load("res://Assets/Sounds/Ambiance/amb_w1.wav"));


func get_intromusic(level:String)->AudioStream:
	return GDPatch.get_mod("customspheres").custom_levels[level].get('intromusic', Audio.mscWorld1_Intro);


func get_mainmusic(level:String)->AudioStream:
	return GDPatch.get_mod("customspheres").custom_levels[level].get('mainmusic', Audio.mscWorld1_Main);


func get_skybox(level:String)->ImageTexture:
	return GDPatch.get_mod("customspheres").custom_levels[level].get('skybox', null);


func load_skybox(level:String)->ImageTexture:
	var _path: String = level_directory.path_join(level);

	return load_texture(_path.path_join("skybox.png"));


func load_thumbnail(level:String)->ImageTexture:
	var _path: String = level_directory.path_join(level);

	return load_texture(_path.path_join(level + ".png"));


func load_icon(level:String)->ImageTexture:
	var _path: String = level_directory.path_join(level);

	return load_texture(_path.path_join("icon.png"));


func load_config(dir:String, fname:String)->Dictionary:
	var _path: String = dir.path_join(fname) + ".cfg";

	if !FileAccess.file_exists(_path): 
		return DEFAULT_LVL_CFG.duplicate();

	var _file: FileAccess = FileAccess.open(_path, FileAccess.READ);
	var _contents: String = FileAccess.get_file_as_string(_path);
	var _json_decoded: Dictionary = JSON.parse_string(_contents);

	if _json_decoded is Dictionary:
		return _json_decoded;

	return DEFAULT_LVL_CFG.duplicate();


func load_music(path:String)->AudioStreamOggVorbis:
	var _music: AudioStreamOggVorbis = AudioStreamOggVorbis.load_from_file(path);
	_music.loop = true;
	return _music;	


func load_ambience(path:String)->AudioStreamWAV:
	var _amb: AudioStreamWAV = AudioStreamWAV.load_from_file(path, {"edit/loop_mode": AudioStreamWAV.LOOP_FORWARD});
	return _amb;


func load_texture(path:String)->ImageTexture:
	if !FileAccess.file_exists(path): 
		return null;

	var _bytes: PackedByteArray = FileAccess.get_file_as_bytes(path);
	var _img: Image = Image.new();

	_img.load_png_from_buffer(_bytes);
	return ImageTexture.create_from_image(_img);


func load_custom_levels()->void:
	var _main_dir: DirAccess = DirAccess.open(level_directory);

	if _main_dir:
		_main_dir.list_dir_begin();

		var _sub_dir: String = _main_dir.get_next();

		while _sub_dir != "":
			if _main_dir.current_is_dir() && !_sub_dir.begins_with("."):
				
				var _folder_path: String = level_directory.path_join(_sub_dir);
				
				var _scene_file_name: String = _sub_dir + ".tscn";
				var _full_scene_path: String = _folder_path.path_join(_scene_file_name);

				if !ResourceLoader.exists(_full_scene_path):
					_scene_file_name = _sub_dir + ".scn";
					_full_scene_path = _folder_path.path_join(_scene_file_name);

				if ResourceLoader.exists(_full_scene_path):
					var _try_load: PackedScene = ResourceLoader.load(_full_scene_path);

					if _try_load != null:
						custom_levels[_sub_dir] = load_config(_folder_path, _sub_dir);
						custom_levels[_sub_dir]["intromusic"] = load_music(_folder_path.path_join(_sub_dir + "_intro.ogg"));##music 
						custom_levels[_sub_dir]["levelmusic"] = load_music(_folder_path.path_join(_sub_dir + "_main.ogg"));
						custom_levels[_sub_dir]["ambience"] = load_ambience(_folder_path.path_join("ambience.wav"));
						custom_levels[_sub_dir]["skybox"] = load_skybox(_sub_dir);
						custom_levels[_sub_dir]["path"] = _full_scene_path;

			_sub_dir = _main_dir.get_next();
			
		_main_dir.list_dir_end();
		print(custom_levels)


func get_autoload(autoload:String)->Node:
	return Engine.get_main_loop().root.get_node(autoload);


func is_building_from_editor()->bool:
	for cmdline_arg in OS.get_cmdline_args():
		if cmdline_arg.contains("run_map::"):
			print('EDITOR BUILD')
			return true;

	return false;


func compile_map(path:String)->void:##ITS ALL A MESS!!!!
	# im just like ericw tools omg!!!
	var _scene: PackedScene = PackedScene.new();
	var _packed = _scene.pack(func_godot_map);
	var _level_dir_path: String = level_directory.path_join(path);
	var _level_scene_path: String = _level_dir_path.path_join(path + ".scn");
	var _level_cfg_path: String = _level_dir_path.path_join(path + ".cfg");

	if !DirAccess.dir_exists_absolute(_level_dir_path):
		DirAccess.make_dir_absolute(_level_dir_path);

	ResourceSaver.save(_scene, _level_scene_path, ResourceSaver.SaverFlags.FLAG_CHANGE_PATH);

	if _packed == OK:
		get_tree().change_scene_to_packed(_scene);
		await get_tree().process_frame

		var _global: Node = get_autoload("global");

		_global.scene_path = _level_scene_path;
		_global.currentlevel = _level_scene_path.get_file().get_basename();
		custom_levels[path] = DEFAULT_LVL_CFG.duplicate();
	#Generate default cfg
	if !FileAccess.file_exists(_level_cfg_path):
		var _file: FileAccess = FileAccess.open(_level_cfg_path, FileAccess.WRITE);
		_file.store_string(JSON.stringify(DEFAULT_LVL_CFG.duplicate(), "\t"));


# https://func-godot.github.io/func_godot_docs/FuncGodot%20Manual/FuncGodot%20Manual.html
func build_map()->void:
	print("BUILDING MAP")

	func_godot_map.build_complete.connect(run_map);

	for cmdline_arg in OS.get_cmdline_args():
		if cmdline_arg.contains("run_map::"):
			var arg_arr := cmdline_arg.split("::");

			if arg_arr.size() != 3:
				return;
			__compile_level_path = arg_arr[2].get_basename();
			func_godot_map.global_map_file = arg_arr[1];
			func_godot_map.build();


func run_map()->void:##hack hack hack
	print("RUNNING MAP")
	compile_map(__compile_level_path);
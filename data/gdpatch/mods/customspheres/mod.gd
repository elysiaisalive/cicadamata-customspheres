class_name CustomSphereLoader extends Node


signal compile_complete();


var level_directory: String;
var custom_levels: Dictionary[String, Variant];
var func_godot_map: FuncGodotMap;
var map_settings: FuncGodotMapSettings;
var map_fgd: FuncGodotFGDFile;


var __launch_args: PackedStringArray;
var __compile_level_path: String;


const HYPERPLANE_SIZE: float = 2048.0;
const DEFAULT_FGD: FuncGodotFGDFile = preload("res://FuncGodot/CICADAMATA_fgd.tres");
const DEFAULT_MAP_SETTINGS: TrenchBroomGameConfig = preload("res://FuncGodot/cicadamata_gamecfg.tres");
const DEFAULT_LVL_CFG: Dictionary = {
	"author": "DEMETER",
	"world_title": "CUSTOM",
	"world_colour": "FFFFFF",
	"world_light_colour": "FFFFFF",
	"fog_enabled": true,
	"volumetric_fog_enabled": true,
	"fog_skyaffect": 0.2,
	"volumetric_fog_skyaffect": 0.2,
	"music_override": "",
	"fgd_override": "",
	"pretitle": "CUSTOM",
	"title": "Custom Level",
	"transition": "whats mine is yours,\n\t\tand what's yours is mine",
	"location": "UNIDENTIFIED",
	"conditions": "NEUTRAL + TEMPERATURE: ???°",
	"warning": "UNIDENTIFIED SPHERE DETECTED",
	"red_score": 9999,
	"dmnd_score": 999,
	"gold_score": 99,
	"slvr_score": 9,
	"next_level": "",
	"terminal_title": "+ CUSTOM.ONR",
	"terminal_date": "??_???_7AS",
	"terminal_text": "I met a traveller from an antique land",
};


func _ready()->void:
	__launch_args = OS.get_cmdline_args();

	init_custom_dir();
	init_fgd();
	load_custom_levels();

	if is_building_from_editor():
		var _global: Node = get_autoload('global');

		func_godot_map = FuncGodotMap.new();
		func_godot_map.map_settings = DEFAULT_MAP_SETTINGS.duplicate();
		func_godot_map.map_settings.entity_fgd = map_fgd;
		func_godot_map.hyperplane_size = self.HYPERPLANE_SIZE;

		if _global:
			get_tree().root.add_child(func_godot_map);
			await get_tree().process_frame
			build_map();


func init_fgd()->void:##we have to have an internal fgd because loading external resources is wack yo
	map_fgd = FuncGodotFGDFile.new();
	map_fgd.fgd_name = 'fgd_custom';

	var _fgd_path: String = GDPatch.get_mod_directory("customspheres").path_join("fgd/entities");
	var _fgd_dir: DirAccess = DirAccess.open(_fgd_path);

	if _fgd_dir:
		_fgd_dir.list_dir_begin();

		var _fgd_file: String = _fgd_dir.get_next();

		while _fgd_file != "":
			var _fgd_file_path: String = _fgd_path.path_join(_fgd_file);

			if ResourceLoader.exists(_fgd_file_path) && _fgd_file.ends_with('.tres'):
				var _try_load: Resource = load(_fgd_file_path);

				if _try_load != null && _try_load is FuncGodotFGDEntityClass:
					map_fgd.entity_definitions.append(_try_load);

			_fgd_file = _fgd_dir.get_next();
			
		_fgd_dir.list_dir_end();


func init_custom_dir()->void:
	level_directory = GDPatch.get_mod_directory("customspheres").path_join("levels");
	DirAccess.make_dir_absolute(level_directory);


func init_levelbutton(node, level:String)->void:
	node.get_node('TextureRect').texture = GDPatch.get_mod("customspheres").load_thumbnail(level);
	node.get_node('WorldIcon').texture = GDPatch.get_mod("customspheres").load_icon(level);
	node.get_node('LvlPreTitle').text = GDPatch.get_mod("customspheres").custom_levels[level].pretitle;
	node.get_node('LvlName').text = GDPatch.get_mod("customspheres").custom_levels[level].title;
	node.get_node('LvlScore').text = GDPatch.get_mod("customspheres").custom_levels[level].author;
	node.get_node('LvlScore').modulate = GDPatch.get_mod("customspheres").get_worldcolour(level);
	node.get_node('LevelButton').color = GDPatch.get_mod("customspheres").get_worldcolour(level);
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


func get_worldcolour(level:String)->Color:
	var _worldcol: String = GDPatch.get_mod("customspheres").custom_levels[level].get('world_colour', DEFAULT_LVL_CFG.world_colour);
	var _col: Color = Color.html(_worldcol) if Color.html_is_valid(_worldcol) else Color.WHITE;
	return _col;


func get_world_light_colour(level:String)->Color:
	var _worldcol: String = GDPatch.get_mod("customspheres").custom_levels[level].get('world_light_colour', DEFAULT_LVL_CFG.world_colour);
	var _col: Color = Color.html(_worldcol) if Color.html_is_valid(_worldcol) else Color.WHITE;
	return _col;


func get_terminal_data(level:String)->Dictionary[String, String]:
	return {
		"title": GDPatch.get_mod("customspheres").custom_levels[level].get('terminal_title', DEFAULT_LVL_CFG.terminal_title),
		"date": GDPatch.get_mod("customspheres").custom_levels[level].get('terminal_date', DEFAULT_LVL_CFG.terminal_date),
		"text": GDPatch.get_mod("customspheres").custom_levels[level].get('terminal_text', DEFAULT_LVL_CFG.terminal_text),
	};


func get_terminal_icon(level:String)->ImageTexture:
	return GDPatch.get_mod("customspheres").custom_levels[level].get('terminal', load("res://Assets/UI/Terminal/lvl_1_1.png"));


func get_worldtitle(level:String)->String:
	return GDPatch.get_mod("customspheres").custom_levels[level].get('world_title', DEFAULT_LVL_CFG.world_title);


func get_ambience(level:String)->AudioStream:
	return GDPatch.get_mod("customspheres").custom_levels[level].get('ambience', load("res://Assets/Sounds/Ambiance/amb_w1.wav"));


func get_intromusic(level:String)->AudioStream:
	return GDPatch.get_mod("customspheres").custom_levels[level].get('intromusic', Audio.mscWorld1_Intro);


func get_mainmusic(level:String)->AudioStream:
	return GDPatch.get_mod("customspheres").custom_levels[level].get('levelmusic', Audio.mscWorld1_Main);


func get_skybox(level:String)->ImageTexture:
	return GDPatch.get_mod("customspheres").custom_levels[level].get('skybox', null);


func get_nextlevel(level:String)->String:
	return GDPatch.get_mod("customspheres").custom_levels[level].get('next_level', DEFAULT_LVL_CFG.next_level);


func get_chapter_end(level:String)->String:
	return GDPatch.get_mod("customspheres").custom_levels[level].get('chapter_end', false);


func get_icon(level:String)->ImageTexture:
	return GDPatch.get_mod("customspheres").custom_levels[level].get('icon', load("res://Assets/UI/LevelIcons/bonus_icon.png"));


func get_fog_enabled(level:String)->bool:
	return GDPatch.get_mod("customspheres").custom_levels[level].get('fog_enabled', DEFAULT_LVL_CFG.fog_enabled);


func get_volumetric_fog_enabled(level:String)->bool:
	return GDPatch.get_mod("customspheres").custom_levels[level].get('volumetric_fog_enabled', DEFAULT_LVL_CFG.volumetric_fog_enabled);


func get_env_fog_skyaffect(level:String)->ImageTexture:
	return GDPatch.get_mod("customspheres").custom_levels[level].get('fog_skyaffect', DEFAULT_LVL_CFG.fog_skyaffect);


func get_env_volumetric_fog_skyaffect(level:String)->ImageTexture:
	return GDPatch.get_mod("customspheres").custom_levels[level].get('volumetric_fog_skyaffect', DEFAULT_LVL_CFG.volumetric_fog_skyaffect);


func load_terminal_icon(level:String)->ImageTexture:
	var _path: String = level_directory.path_join(level);

	return load_texture(_path.path_join("terminal.png"));


func load_skybox(level:String)->ImageTexture:
	var _path: String = level_directory.path_join(level);

	return load_texture(_path.path_join("skybox.png"));


func load_thumbnail(level:String)->ImageTexture:
	var _path: String = level_directory.path_join(level);

	return load_texture(_path.path_join("thumbnail.png"));


func load_icon(level:String)->ImageTexture:
	var _path: String = level_directory.path_join(level);

	return load_texture(_path.path_join("icon.png"));


func load_fgd(level:String)->FuncGodotFGDFile:
	return DEFAULT_FGD.duplicate();
	var _dir: String = level_directory.path_join(level);
	var _path: String = _dir.path_join("fgd.tres");

	if !custom_levels[level].get("fgd_override").is_empty():
		var _override_target: String = custom_levels[level].get("fgd_override");

		_dir = level_directory.path_join(_override_target);
		_path = _dir.path_join("fgd.tres");

		return ResourceLoader.load(_path);

	if !ResourceLoader.exists(_path):##fallback to mod fgd
		var _fdir: String = GDPatch.get_mod_directory("customspheres");
		var _fpath: String = _fdir.path_join("fgd/CICADAMATA_fgd.tres");

		if ResourceLoader.exists(_fpath):
			var _try_load: Resource = ResourceLoader.load(_fpath);

			if _try_load:
				return _try_load;
	print('[CUSTOM_SPHERES] Error loading level FGD, using default');
	return DEFAULT_FGD.duplicate();


func load_config(level:String)->Dictionary:
	var _dir: String = level_directory.path_join(level);
	var _path: String = _dir.path_join("config.cfg");

	if !FileAccess.file_exists(_path):
		print('[CUSTOM_SPHERES] Error loading level cfg, not found');
		return DEFAULT_LVL_CFG.duplicate();

	var _file: FileAccess = FileAccess.open(_path, FileAccess.READ);
	var _contents: String = FileAccess.get_file_as_string(_path);
	var _json_decoded: Dictionary = JSON.parse_string(_contents);

	if _json_decoded is Dictionary:
		return _json_decoded.merged(DEFAULT_LVL_CFG);

	return DEFAULT_LVL_CFG.duplicate();


func load_sound(path:String)->AudioStreamOggVorbis:
	var _music: AudioStreamOggVorbis = AudioStreamOggVorbis.load_from_file(path);
	_music.loop = true;
	return _music;


func load_texture(path:String)->ImageTexture:
	if !FileAccess.file_exists(path):
		print('[CUSTOM_SPHERES] Error loading texture, not found'); 
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

					if _try_load == null:
						print('[CUSTOM_SPHERES] Error loading level, scene invalid');
						return;

					custom_levels[_sub_dir] = load_config(_sub_dir);#always load the cfg first
					custom_levels[_sub_dir]["path"] = _full_scene_path;
					custom_levels[_sub_dir]["fgd"] = load_fgd(_sub_dir);
					if custom_levels[_sub_dir].get("music_override").is_empty():
						custom_levels[_sub_dir]["intromusic"] = load_sound(_folder_path.path_join("intro.ogg"));
						custom_levels[_sub_dir]["levelmusic"] = load_sound(_folder_path.path_join("main.ogg"));
					else:
						var _override_path: String = level_directory.path_join(custom_levels[_sub_dir].get("music_override"));
						custom_levels[_sub_dir]["intromusic"] = load_sound(_override_path.path_join("intro.ogg"));
						custom_levels[_sub_dir]["levelmusic"] = load_sound(_override_path.path_join("main.ogg"));

					custom_levels[_sub_dir]["icon"] = load_icon(_sub_dir);
					custom_levels[_sub_dir]["skybox"] = load_skybox(_sub_dir);
					custom_levels[_sub_dir]["ambience"] = load_sound(_folder_path.path_join("ambience.ogg"));
					custom_levels[_sub_dir]["terminal"] = load_terminal_icon(_sub_dir);

			_sub_dir = _main_dir.get_next();
			
		_main_dir.list_dir_end();
		print('[CUSTOM_SPHERES] Loaded: %s' % custom_levels);


func get_autoload(autoload:String)->Node:
	return Engine.get_main_loop().root.get_node(autoload);


func is_building_from_editor()->bool:
	for cmdline_arg in __launch_args:
		if cmdline_arg.contains("run_map::"):
			return true;

	return false;


func compile_map(path:String)->void:##ITS ALL A MESS!!!!
	print("[CUSTOM_SPHERES] COMPILING MAP");

	var _global: Node = get_autoload("global");
	#get_tree().change_scene_to_node(func_godot_map);

	if path.is_empty():
		print('[CUSTOM_SPHERES] COMPILE ERROR, path invalid');
		return;

	# im just like ericw tools omg!!!
	if !func_godot_map:
		print('[CUSTOM_SPHERES] COMPILE ERROR, failed to copy FuncGodotMap');
		return;

	var _scene: PackedScene = PackedScene.new();
	var _packed = _scene.pack(func_godot_map);

	func_godot_map.queue_free();

	if _packed != OK:
		print('[CUSTOM_SPHERES] COMPILE ERROR, failed to pack FuncGodotMap');
		_global._goto_menu();
		return;

	var _level_dir_path: String = level_directory.path_join(path);
	var _level_scene_path: String = _level_dir_path.path_join(path + ".scn");
	var _level_cfg_path: String = _level_dir_path.path_join("config.cfg");

	if !DirAccess.dir_exists_absolute(_level_dir_path):
		DirAccess.make_dir_absolute(_level_dir_path);

	ResourceSaver.save(_scene, _level_scene_path, ResourceSaver.SaverFlags.FLAG_CHANGE_PATH);

	#Generate default cfg
	if !FileAccess.file_exists(_level_cfg_path):
		var _file: FileAccess = FileAccess.open(_level_cfg_path, FileAccess.WRITE);
		_file.store_string(JSON.stringify(DEFAULT_LVL_CFG.duplicate(), "\t"));

	custom_levels[path] = load_config(path);
	custom_levels[path]['path'] = _level_scene_path;
	_global.scene_path = _level_scene_path;

	__launch_args = PackedStringArray();
	compile_complete.emit();

	get_tree().change_scene_to_packed(_scene);
	_global._goto_menu();

	print('[CUSTOM_SPHERES] COMPILED MAP');

# https://func-godot.github.io/func_godot_docs/FuncGodot%20Manual/FuncGodot%20Manual.html
func build_map()->void:
	print("[CUSTOM_SPHERES] BUILDING MAP");

	func_godot_map.build_complete.connect(run_and_compile, ConnectFlags.CONNECT_ONE_SHOT);

	for cmdline_arg in __launch_args:
		if cmdline_arg.contains("run_map::"):
			var arg_arr := cmdline_arg.split("::");

			if arg_arr.size() != 3:
				return;
			__compile_level_path = arg_arr[2].get_basename();
			func_godot_map.global_map_file = arg_arr[1];

			if !__compile_level_path.is_empty():
				func_godot_map.build();


func run_and_compile()->void:
	compile_map(__compile_level_path);


func set_owner_recursive(node:Node, root:Node)->void:
	for child in node.get_children():
		child.owner = root;
		set_owner_recursive(child, root);
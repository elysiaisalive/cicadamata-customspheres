class_name CustomSphereLoader extends Node


var custom_levels: Dictionary[String, Variant];
var map_settings: FuncGodotMapSettings;
var map_fgd: FuncGodotFGDFile;


var __temp_directory: String;
var __level_directory: String;
var __level_temp_path: String;
var __build_path: String;
var __map_builder: FuncGodotMap;
var __launch_args: PackedStringArray;


const MAP_EXTENSION: String = '.map';
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
	"skybox_brightness": 1.0,
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
	init_map_builder();
	load_custom_levels();

	if is_exporting_map():
		export_map();



func init_map_builder()->void:
	print('[CUSTOM_SPHERES] INIT MAP BUILDER');
	__map_builder = FuncGodotMap.new();
	__map_builder.build_complete.connect(_on_build_ok);
	__map_builder.build_failed.connect(_on_build_fail);
	__map_builder.map_settings = DEFAULT_MAP_SETTINGS.duplicate();
	__map_builder.map_settings.entity_fgd = map_fgd;
	__map_builder.hyperplane_size = self.HYPERPLANE_SIZE;
	get_tree().root.add_child.call_deferred(__map_builder);


func init_fgd()->void:##we have to have an internal fgd because loading external resources is wack yo
	print('[CUSTOM_SPHERES] INIT MAP FGD');
	map_fgd = FuncGodotFGDFile.new();
	map_fgd.fgd_name = 'fgd_custom';

	var _fgd_path: String = GDPatch.get_mod_directory("customspheres").path_join("fgd_internal/entities");
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
	print('[CUSTOM_SPHERES] INIT CUSTOM DIRECTORIES');
	__temp_directory = GDPatch.get_mod_directory("customspheres").path_join("temp");
	__level_directory = GDPatch.get_mod_directory("customspheres").path_join("levels");

	var _dir: DirAccess = DirAccess.open(__level_directory);
	_dir.make_dir(__level_directory);
	_dir.make_dir(__temp_directory);


func init_custom_button(node, level:String)->void:
	node.level = level;
	node.custom = true;
	node.forceunlock = true;
	node.hiderank = false;
	node.get_node('TextureRect').texture = GDPatch.get_mod("customspheres").load_thumbnail(level);
	node.get_node('WorldIcon').texture = GDPatch.get_mod("customspheres").load_icon(level);
	node.get_node('LvlPreTitle').text = GDPatch.get_mod("customspheres").custom_levels[level].pretitle;
	node.get_node('LvlName').text = GDPatch.get_mod("customspheres").custom_levels[level].title;
	node.get_node('LvlScore').text = GDPatch.get_mod("customspheres").custom_levels[level].author;
	node.get_node('LvlScore').modulate = GDPatch.get_mod("customspheres").get_world_colour(level);
	node.get_node('LevelButton').color = GDPatch.get_mod("customspheres").get_world_colour(level);
	node.get_node('LevelButton').pressed.connect(node.get_node("../../..")._on_lvl_pressed.bind(level, false));
	node.get_node('LevelButton').focus_entered.connect(node.get_node("../../..")._on_lvl_focus.bind(level, false));


func init_custom_menu(ui_parent:Node)->void:
	if !GDPatch.get_mod("customspheres").custom_levels.is_empty():
		for level in GDPatch.get_mod("customspheres").custom_levels:
			var _new_custom_button: ColorRect = load("res://Scenes/UI/level_button.tscn").instantiate();

			init_custom_button(_new_custom_button, level);
			ui_parent.add_child(_new_custom_button);


func get_autoload(autoload:String)->Node:
	return Engine.get_main_loop().root.get_node(autoload);


func get_levels()->Array[String]:
	return DirAccess.get_directories_at(__level_directory);


func get_shipscreen(level:String)->String:
	var _shiptext: String = "+ LOCATION: {location}, CASCADE\n+ CONDITIONS: {conditions}\n+ WARNING: {warning}\n+ TEAR FLESH FROM BONE"
	return _shiptext.format({
		"location": GDPatch.get_mod("customspheres").custom_levels[level].get('location', DEFAULT_LVL_CFG.location),
		"conditions": GDPatch.get_mod("customspheres").custom_levels[level].get('conditions', DEFAULT_LVL_CFG.conditions),
		"warning": GDPatch.get_mod("customspheres").custom_levels[level].get('warning', DEFAULT_LVL_CFG.warning),
	});


func get_world_colour(level:String)->Color:
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


func get_next_level(level:String)->String:
	return GDPatch.get_mod("customspheres").custom_levels[level].get('next_level', '');


func get_chapter_end(level:String)->String:
	return GDPatch.get_mod("customspheres").custom_levels[level].get('chapter_end', false);


func get_icon(level:String)->ImageTexture:
	return GDPatch.get_mod("customspheres").custom_levels[level].get('icon', load("res://Assets/UI/LevelIcons/bonus_icon.png"));


func get_fog_enabled(level:String)->bool:
	return GDPatch.get_mod("customspheres").custom_levels[level].get('fog_enabled', DEFAULT_LVL_CFG.fog_enabled);


func get_volumetric_fog_enabled(level:String)->bool:
	return GDPatch.get_mod("customspheres").custom_levels[level].get('volumetric_fog_enabled', DEFAULT_LVL_CFG.volumetric_fog_enabled);


func get_env_fog_skyaffect(level:String)->float:
	return GDPatch.get_mod("customspheres").custom_levels[level].get('fog_skyaffect', DEFAULT_LVL_CFG.fog_skyaffect);


func get_env_volumetric_fog_skyaffect(level:String)->float:
	return GDPatch.get_mod("customspheres").custom_levels[level].get('volumetric_fog_skyaffect', DEFAULT_LVL_CFG.volumetric_fog_skyaffect);


func get_env_skybox_brightness(level:String)->float:
	return GDPatch.get_mod("customspheres").custom_levels[level].get('skybox_brightness', DEFAULT_LVL_CFG.skybox_brightness);


func get_map_path(level:String)->String:
	var _path: String = GDPatch.get_mod("customspheres").custom_levels[level].get('path');

	if _path.is_empty():
		return String();

	return _path;


func get_wad(level:String)->QuakeWadFile:
	var _wad_path: QuakeWadFile = GDPatch.get_mod("customspheres").custom_levels[level].get("wad");

	if _wad_path == null:
		return null;

	return _wad_path;


func load_terminal_icon(level:String)->ImageTexture:
	var _path: String = __level_directory.path_join(level);

	return load_texture(_path.path_join("terminal.png"));


func load_skybox(level:String)->ImageTexture:
	var _path: String = __level_directory.path_join(level);

	return load_texture(_path.path_join("skybox.png"));


func load_thumbnail(level:String)->ImageTexture:
	var _path: String = __level_directory.path_join(level);

	return load_texture(_path.path_join("thumbnail.png"));


func load_icon(level:String)->ImageTexture:
	var _path: String = __level_directory.path_join(level);

	return load_texture(_path.path_join("icon.png"));


func load_fgd(level:String)->FuncGodotFGDFile:
	return DEFAULT_FGD.duplicate();
	var _dir: String = __level_directory.path_join(level);
	var _path: String = _dir.path_join("fgd.tres");

	if !custom_levels[level].get("fgd_override").is_empty():
		var _override_target: String = custom_levels[level].get("fgd_override");

		_dir = __level_directory.path_join(_override_target);
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
	var _dir: String = __level_directory.path_join(level);
	var _path: String = _dir.path_join("config.cfg");

	if !FileAccess.file_exists(_path):
		print('[CUSTOM_SPHERES] Error loading level cfg, not found');
		return DEFAULT_LVL_CFG.duplicate();

	var _file: FileAccess = FileAccess.open(_path, FileAccess.READ);
	var _contents: String = FileAccess.get_file_as_string(_path);
	var _json_decoded: Dictionary = JSON.parse_string(_contents);

	if _json_decoded is Dictionary:
		return _json_decoded.merged(DEFAULT_LVL_CFG.duplicate());

	return DEFAULT_LVL_CFG.duplicate();


func load_sound(path:String)->AudioStreamOggVorbis:
	if !FileAccess.file_exists(path):
		print('[CUSTOM_SPHERES] Error loading audio, not found'); 
		return null;

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


func load_texture_wad(path:String)->QuakeWadFile:
	var _path: String = __level_directory.path_join(path);
	var _wadpath: String = _path.path_join("textures.wad");

	if !FileAccess.file_exists(_wadpath):
		print('[CUSTOM_SPHERES] Error loading WAD, not found'); 
		return;

	var _try_load: Dictionary[String, ImageTexture] = WADLoader.load_wad(_wadpath);

	if _try_load.is_empty():
		print('[CUSTOM_SPHERES] Error loading WAD, no textures'); 
		return;

	return QuakeWadFile.new(_try_load);



func load_custom_levels()->void:
	print('[CUSTOM_SPHERES] LOADING LEVELS');
	var _main_dir: DirAccess = DirAccess.open(__level_directory);

	if _main_dir:
		_main_dir.list_dir_begin();

		var _sub_dir: String = _main_dir.get_next();

		while _sub_dir != "":
			if _main_dir.current_is_dir() && !_sub_dir.begins_with('.'):
				var _folder_path: String = __level_directory.path_join(_sub_dir);				
				var _full_map_path: String;

				for file in DirAccess.get_files_at(_folder_path):
					if file.ends_with(MAP_EXTENSION):
						_full_map_path = _folder_path.path_join(file);
						break;

				if _full_map_path.is_empty() || !FileAccess.file_exists(_full_map_path):
					print('[CUSTOM_SPHERES] ERROR LOADING MAP, MAP NOT FOUND');
					_sub_dir = _main_dir.get_next();
					continue;

				load_level(_full_map_path, _sub_dir);

			_sub_dir = _main_dir.get_next();

		_main_dir.list_dir_end();

		if custom_levels.is_empty():
			print('[CUSTOM_SPHERES] NO LEVELS FOUND');
			return;

		print('[CUSTOM_SPHERES] LOADED LEVELS');
		print(custom_levels.keys());


func load_level(fullpath:String, level:String)->void:
	custom_levels[level] = load_config(level);#always load the cfg first
	custom_levels[level]["path"] = fullpath;
	custom_levels[level]["fgd"] = load_fgd(level);
	custom_levels[level]["wad"] = load_texture_wad(level);

	if custom_levels[level].get("music_override").is_empty():
		custom_levels[level]["intromusic"] = load_sound(level.path_join("intro.ogg"));
		custom_levels[level]["levelmusic"] = load_sound(level.path_join("main.ogg"));
	else:
		var _override_path: String = __level_directory.path_join(custom_levels[level].get("music_override"));
		custom_levels[level]["intromusic"] = load_sound(_override_path.path_join("intro.ogg"));
		custom_levels[level]["levelmusic"] = load_sound(_override_path.path_join("main.ogg"));

	custom_levels[level]["icon"] = load_icon(level);
	custom_levels[level]["skybox"] = load_skybox(level);
	custom_levels[level]["ambience"] = load_sound(level.path_join("ambience.ogg"));
	custom_levels[level]["terminal"] = load_terminal_icon(level);


func get_temp_path()->String:
	return __level_temp_path;


func export_map()->void:
	for cmdline_arg in __launch_args:
		if cmdline_arg.contains("export_map::"):
			var arg_arr := cmdline_arg.split("::");

			if arg_arr.size() != 3:
				return;

			var _level_dir_path: String = __level_directory.path_join(arg_arr[2]);
			var _level_cfg_path: String = _level_dir_path.path_join("config.cfg");
			## Generate default lvl cfg
			if !FileAccess.file_exists(_level_cfg_path):
				var _file: FileAccess = FileAccess.open(_level_cfg_path, FileAccess.WRITE);
				_file.store_string(JSON.stringify(DEFAULT_LVL_CFG.duplicate(), "\t"));
				print('[CUSTOM_SPHERES] GENERATED DEFAULT LEVEL CFG');

			fallback_to_menu();


func is_exporting_map()->bool:
	for cmdline_arg in __launch_args:
		if cmdline_arg.contains("export_map::"):
			print('[CUSTOM_SPHERES] EXPORTING MAP');
			return true;

	return false;


func create_temp(path:String)->void:
	print("[CUSTOM_SPHERES] CREATING TEMP SCENE");

	if path.is_empty():
		print('[CUSTOM_SPHERES] RUN MAP ERROR, INVALID PATH');
		return;

	var _temp_scene_path: String = __temp_directory.path_join("temp.scn");
	var _temp_dir: DirAccess = DirAccess.open(__temp_directory);

	if !_temp_dir.dir_exists(__temp_directory):
		_temp_dir.make_dir(__temp_directory);

	if FileAccess.file_exists(_temp_scene_path):
		print('[CUSTOM_SPHERES] CLEARING TEMP CACHE');
		LoadingScreen.loaded_scene = null;
		LoadingScreen.cached_scene = null;

	set_owner_recursive(__map_builder, __map_builder);

	var _scene: PackedScene = PackedScene.new();
	var _packed = _scene.pack(__map_builder);

	if _packed != OK:
		print('[CUSTOM_SPHERES] RUN MAP ERROR, FAILED TO PACK TEMP SCENE');
		fallback_to_menu();
		return;

	ResourceSaver.save(_scene, _temp_scene_path, ResourceSaver.SaverFlags.FLAG_CHANGE_PATH);
	__level_temp_path = _temp_scene_path;
	__map_builder.clear_children();

	print('[CUSTOM_SPHERES] TEMP SCENE CREATED');


func build_map(path:String)->void:
	print("[CUSTOM_SPHERES] BUILDING MAP");

	var _map_fpath: String = get_map_path(path);

	if !FileAccess.file_exists(_map_fpath):
		print("[CUSTOM_SPHERES] ERROR BUILDING MAP, NO MAP FILE FOUND");
		fallback_to_menu();
		return;
	print(custom_levels[path])
	if get_wad(path):
		print('WADDING IT UP')
		__map_builder.map_settings.texture_wads.append(get_wad(path));

	__build_path = _map_fpath;
	__map_builder.global_map_file = __build_path;
	__map_builder.build();


func _on_build_ok()->void:
	print("[CUSTOM_SPHERES] MAP BUILD OK");
	create_temp(__build_path);


func _on_build_fail()->void:
	print("[CUSTOM_SPHERES] ERROR BUILDING MAP");
	fallback_to_menu();


func fallback_to_menu()->void:
	var _global: Node = get_autoload("global");
	_global._goto_menu();


func set_owner_recursive(node:Node, root:Node)->void:
	for child in node.get_children():
		child.owner = root;
		if child.scene_file_path.is_empty() || !child.is_queued_for_deletion():
			set_owner_recursive(child, root);

## Heavy, HEAVY homework borrowing from;
## https://github.com/func-godot/func_godot_plugin/blob/main/addons/func_godot/src/import/quake_wad_import_plugin.gd
## https://yuraj11.github.io/old-files/half-life-formats.pdf
## https://quakewiki.org/wiki/Texture_Wad
## https://quakewiki.org/wiki/Quake_palette#colormap.lmp
class WADLoader extends RefCounted:
	class WADEntry extends RefCounted:
		var offset: int;
		var length: int;
		var full_length: int;
		var type: int;
		var compression: int;
		var pad: int;
		var texture_name: String;

	class WADTextureData extends RefCounted:
		var name: String;
		var width: int;
		var height: int;
		var buffer: PackedByteArray;
		var palette: PackedColorArray;

	enum WAD_FORMAT {
		WAD2,##quake
		WAD3##hl
	};

	const WAD3_MIPS_TEXTURE_TYPE: int = 0x43;
	const WAD2_MIPS_TEXTURE_TYPE: int = 0x44;
	const TEX_NAME_BYTES_LENGTH: int = 16;
	const QUAKE_PALETTE_BYTES: int = 768;
	const MAX_MIPS: int = 4;

	static func load_palette_lmp()->PackedColorArray:
		var _path: String = GDPatch.get_mod_directory("customspheres/fgd_internal").path_join("palette.lmp");
		var _palette: PackedColorArray = PackedColorArray();
		var _file: FileAccess = FileAccess.open(_path, FileAccess.READ);

		if _file == null:
			print("[CUSTOM_SPHERES][WADLoader] Error, could not find palette.lmp");
			return _palette;

		if _file.get_length() < QUAKE_PALETTE_BYTES:
			print("[CUSTOM_SPHERES][WADLoader] Error, invalid palette.lmp");
			return _palette;

		for col in 256:
			var _r: int = _file.get_8();
			var _g: int = _file.get_8();
			var _b: int = _file.get_8();

			_palette.append(
				Color8(_r, _g, _b)
			);
		return _palette;


	static func load_wad(path: String) -> Dictionary[String, ImageTexture]:
		var _wad_textures: Dictionary[String, ImageTexture] = {};## String, ImageTexture is the typedict FuncGodot expects!!!
		var _wadfile: FileAccess = FileAccess.open(path, FileAccess.READ);

		if _wadfile == null:
			print("[CUSTOM_SPHERES][WADLoader] Error, file could not open");
			print("[CUSTOM_SPHERES][WADLoader] Trace: %s" % path);
			return _wad_textures;

		# Start reading the header
		var _header: PackedByteArray = _wadfile.get_buffer(4);#4 byte offset
		var _wad_type: String = _header.get_string_from_ascii();
		var _format: int = WAD_FORMAT.WAD3;

		if _wad_type != 'WAD3' && _wad_type != 'WAD2':
			print("[CUSTOM_SPHERES][WADLoader] Error, unrecognized WAD format. ensure that your WAD file is WAD3.");
			print("[CUSTOM_SPHERES][WADLoader] Trace: %s" % path);
			return _wad_textures;

		_format = WAD_FORMAT.WAD3 if _wad_type == 'WAD3' else WAD_FORMAT.WAD2;

		var _lump_count: int = _wadfile.get_32();
		var _dir_offset: int = _wadfile.get_32();

		_wadfile.seek(_dir_offset);

		var _wad_entries: Array[WADEntry] = [];

		for idx in range(_lump_count):
			var _offs: int = _wadfile.get_32();## 4 bites mmm
			var _tex_length: int = _wadfile.get_32();## Compressed tex length
			var _full_length: int = _wadfile.get_32();## Compressed tex length
			var _tex_type: int = _wadfile.get_8();# texture type, we are only looking for mipstextures
			var _compression_type: int = _wadfile.get_8();## useless
			var _pad: int = _wadfile.get_16();
			var _tex_name_bytes: PackedByteArray = _wadfile.get_buffer(TEX_NAME_BYTES_LENGTH);## length of the texture name
			var _tex_name_string: String = _tex_name_bytes.get_string_from_ascii();## woo hoo our texture name yeah@!!!!

			var _entry: WADEntry = WADEntry.new();
			_entry.offset = _offs;
			_entry.length = _tex_length;
			_entry.full_length = _full_length;
			_entry.type = _tex_type;
			_entry.compression = _compression_type;
			_entry.pad = _pad;
			_entry.texture_name = _tex_name_string;

			_wad_entries.append(_entry);

		var _tex_data: Array[WADTextureData] = [];
		var _entry_type: int = WAD3_MIPS_TEXTURE_TYPE if _format == WAD_FORMAT.WAD3 else WAD2_MIPS_TEXTURE_TYPE;

		# now that we have read the header and the wad entries, we can load the TEXTURES
		for entry in _wad_entries:
			if entry.type != _entry_type || entry.compression != 0:## we are only looking for mipstextures, none of that font (etc) bullshit
				continue;

			var _offset: int = entry.offset;

			_wadfile.seek(_offset);

			var _tex: PackedByteArray = _wadfile.get_buffer(TEX_NAME_BYTES_LENGTH);
			var _tex_name: String = _tex.get_string_from_ascii();
			var _tex_width: int = _wadfile.get_32();
			var _tex_height: int = _wadfile.get_32();
			var _mip_offs: Array[int] = [];

			for idx in range(0, MAX_MIPS):## Max MIPS level is 4.
				_mip_offs.append(_wadfile.get_32());

			var _tex_pixel_num: int = _tex_width * _tex_height;
			var _tex_pixel_buff: PackedByteArray = _wadfile.get_buffer(_tex_pixel_num);

			var _data: WADTextureData = WADTextureData.new();
			_data.name = _tex_name;
			_data.width = _tex_width;
			_data.height = _tex_height;
			_data.buffer = _tex_pixel_buff;

			if _format == WAD_FORMAT.WAD2:## thank you func godot quake wad importer plugin
				_data.palette = load_palette_lmp();
				_tex_data.append(_data);
				continue;
			elif _format == WAD_FORMAT.WAD3:
				_wadfile.seek(
					_offset + _mip_offs[-1] + (_tex_width / 8) * (_tex_height / 8)
				);
				_wadfile.get_16();

				var _palette: PackedColorArray = PackedColorArray();

				for idx in 256:## hl textures have a maximum of 256 colours, here we get 256 bytes for each 24bit rgb value
					var _r: int = _wadfile.get_8();## this feels like gamemaker shit lol
					var _g: int = _wadfile.get_8();## this feels like gamemaker shit lol
					var _b: int = _wadfile.get_8();## this feels like gamemaker shit lol
					var _col: Color = Color(
						_r / 255.0,## we divide by 255 coz we need a normalized range of 0-1 to represent RGB
						_g / 255.0, 
						_b / 255.0
					);
					_palette.append(_col);

				_data.palette = _palette;
				_tex_data.append(_data);

		## now that we have the texture data..... 
		for data in _tex_data:
			var _name: String = data.name;
			var _width: int = data.width;
			var _height: int = data.height;
			var _pixels: PackedByteArray = data.buffer;
			var _img: Image;
			var _pixels_rgb: PackedByteArray = PackedByteArray();

			if _format == WAD_FORMAT.WAD3:## HL Textures use 0,0,255 for transparency, quake just uses 255.
				var _cols: PackedColorArray = data.palette;

				for col in _pixels:
					var _rgb: Color = _cols[col];
					_pixels_rgb.append(_rgb.r8);
					_pixels_rgb.append(_rgb.g8);
					_pixels_rgb.append(_rgb.b8);

					if _name.begins_with('{') && _rgb.r8 == 0 && _rgb.g8 == 0 && _rgb.b8 == 255:## 0, 0, 255
						_pixels_rgb.append(0);
					else:
						_pixels_rgb.append(255);
			elif _format == WAD_FORMAT.WAD2:
				var _cols: PackedColorArray = data.palette;

				for col in _pixels:
					var _rgb: Color = _cols[col];
					_pixels_rgb.append(_rgb.r8);
					_pixels_rgb.append(_rgb.g8);
					_pixels_rgb.append(_rgb.b8);
					
					if col != 255:
						_pixels_rgb.append(255);
					else:
						_pixels_rgb.append(0);	


			_img = Image.create_from_data(_width, _height, false, Image.FORMAT_RGBA8, _pixels_rgb);
			_img.generate_mipmaps();##i dont care about making this optional

			var _texture: ImageTexture = ImageTexture.create_from_image(_img);
			_wad_textures[_name.to_lower()] = _texture;

		return _wad_textures;
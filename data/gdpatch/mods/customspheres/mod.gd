class_name CustomSphereLoader extends Node


#load idea
#scan mod dir for sphere resource
#scan mod dir for level resources
#construct custom level dictionary
#patch _setlevel to use custom stuff if a level is defined as custom
#patch _leveldata to use custom stuff if a level is defined as custom

var level_data: Dictionary[String, Variant];
var level_resources: Array[CustomSphereData];
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


func _ready()->void:
	if is_building_from_editor():
		func_godot_map = FuncGodotMap.new();
		self.add_child(func_godot_map);
		await get_tree().process_frame
		build_and_run_map();


func is_building_from_editor()->bool:
	OS.get_cmdline_user_args().contains("run_map::"):
		return true;

	return false;

# https://func-godot.github.io/func_godot_docs/FuncGodot%20Manual/FuncGodot%20Manual.html
func build_and_run_map()->void:
	for cmdline_arg in OS.get_cmdline_user_args():
		if cmdline_arg.contains("run_map::"):
			var arg_arr := cmdline_arg.split("::");

			if arg_arr.size() != 2:
				return;

			self.func_godot_map.local_map_file = arg_arr[1];
			self.func_godot_map.verify_and_build();


# https://gist.github.com/hiulit/772b8784436898fd7f942750ad99e33e
func get_all_files(path: String, file_ext := "", files := []):
	var dir = DirAccess.open(path)

	if DirAccess.get_open_error() == OK:
		dir.list_dir_begin()

		var file_name = dir.get_next()

		while file_name != "":
			if dir.current_is_dir():
				files = get_all_files(dir.get_current_dir() +"/"+ file_name, file_ext, files)
			else:
				if file_ext and file_name.get_extension() != file_ext:
					file_name = dir.get_next()
					continue

			files.append(dir.get_current_dir() +"/"+ file_name)

			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access %s." % path)

	return files
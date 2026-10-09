local utils = require("gdpatch.utils")

GDPatch.patch_script_as_text("Scripts/UI/play.gdc", function(ctx, src)
	src = src:gsub(
		utils.escape([[func _ready() -> void :]]),
		[[%0
	if GDPatch.get_mod("customspheres"): 
		$MainSelect/Custom.show()
	]]
	)
	return src
end)
-- Init custom buttons
-- this code is ugly
GDPatch.patch_script_as_text("Scripts/UI/custom.gdc", function(ctx, src)
	src = src:gsub(
		utils.escape([[func _ready() -> void :]]),
		[[%0
	if GDPatch.get_mod("customspheres"):
		global.level_data = global.level_data.merged(GDPatch.get_mod("customspheres").custom_levels)

		var _lvlbleh: GridContainer = $ScrollContainer/bleh;

		if _lvlbleh != null:
			for bleh in _lvlbleh.get_children():
				bleh.queue_free()

		if !GDPatch.get_mod("customspheres").custom_levels.is_empty():
			for lvl in GDPatch.get_mod("customspheres").custom_levels:
				var _new_lvlbutton: ColorRect = load("res://Scenes/UI/level_button.tscn").instantiate()
				_new_lvlbutton.level = lvl
				_new_lvlbutton.custom = true
				_new_lvlbutton.hiderank = true
				_new_lvlbutton.forceunlock = true
				_new_lvlbutton.get_node('TextureRect').texture = GDPatch.get_mod("customspheres").load_thumbnail(lvl);
				_new_lvlbutton.get_node('WorldIcon').texture = GDPatch.get_mod("customspheres").load_icon(lvl);
				_new_lvlbutton.get_node('LvlPreTitle').text = GDPatch.get_mod("customspheres").custom_levels[lvl].pretitle;
				_new_lvlbutton.get_node('LvlName').text = GDPatch.get_mod("customspheres").custom_levels[lvl].title;
				_new_lvlbutton.get_node('LvlScore').text = GDPatch.get_mod("customspheres").custom_levels[lvl].author;
				_new_lvlbutton.get_node('LevelButton').pressed.connect(_new_lvlbutton.get_node("../../..")._on_lvl_pressed.bind(lvl, false));
				_new_lvlbutton.get_node('LevelButton').focus_entered.connect(_new_lvlbutton.get_node("../../..")._on_lvl_focus.bind(lvl, false));
				_lvlbleh.add_child(_new_lvlbutton)
	]]
	)
	return src
end)

-- patch transition screen and inject modded data
GDPatch.patch_script_as_text("Scripts/UI/level_transition.gdc", function(ctx, src)
	src = src:gsub(
		utils.escape([[func _ready() -> void :]]),
		[[%0
	if GDPatch.get_mod("customspheres"):
		var _custom: Dictionary = GDPatch.get_mod("customspheres").custom_levels;

		if _custom.has(global.translevel):
			$spherenum.text = "CUSTOM"
			$sphname.text = "CUSTOM"
			$sphname2.text = "CUSTOM"
			$levelname.text = "\"" + _custom.get(global.translevel).title + "\""
			$worldicon.texture = GDPatch.get_mod("customspheres").load_icon(global.translevel)
			$worldicon2.texture = GDPatch.get_mod("customspheres").load_icon(global.translevel)
			$leveldesc.text = _custom.get(global.translevel).transition if _custom.get(global.translevel) else '<null>'
			global.showmouse = false
			get_viewport().gui_release_focus()
			Audio.music_stop()
			Audio.music_stop2()
			Audio.music_fadeout2()
			Audio.sound_play_ui(Audio.sndLevelTransition)
			$AnimationPlayer.play("start")
			return
	]]
	)
	return src
end)


-- patch get lvl icon
GDPatch.patch_script_as_text("Scripts/System/global.gdc", function(ctx, src)
	src = src:gsub(
		utils.escape([[func _get_level_icon(_nod, _lev):]]),
		[[%0
	if GDPatch.get_mod("customspheres").custom_levels.has(_lev):
		_nod.texture = GDPatch.get_mod("customspheres").load_icon(_lev);
		return;
	]]
	)
	return src
end)
-- fuck
-- patch _setlevel
GDPatch.patch_script_as_text("Scripts/System/global.gdc", function(ctx, src)
	src = src:gsub(
		utils.escape([[func _setlevel(_lvl, stop_music = false, simple = false) -> void :]]),
		[[%0
	if GDPatch.get_mod("customspheres").custom_levels.has(_lvl):
		currentlevel = _lvl;
		_leveldata(_lvl);
		if !simple: Audio.sound_play_ui(Audio.sndUIGameStart);
		LoadingScreen.start_loading(GDPatch.get_mod("customspheres").custom_levels.get(_lvl).path, stop_music, simple);
		return;
	]]
	)
	return src
end)

-- patch ship screen
GDPatch.patch_script_as_text("Scripts/UI/ship_screen.gdc", function(ctx, src)
	src = src:gsub(
		utils.escape([[func _ready() -> void :]]),
		[[%0
	if GDPatch.get_mod("customspheres").custom_levels.has(global.currentlevel):
		self.texture = GDPatch.get_mod("customspheres").load_icon(global.currentlevel)
		$Label9.text = GDPatch.get_mod("customspheres").get_shipscreen(global.currentlevel)
		$Label4.text = GDPatch.get_mod("customspheres").custom_levels.get(global.currentlevel).title
		$Label3.text = GDPatch.get_mod("customspheres").custom_levels.get(global.currentlevel).pretitle + " + " + "CUSTOM"
		$Label14.modulate = Color("ea531f")
		return
	]]
	)
	return src
end)

-- patch music
GDPatch.patch_script_as_text("Scripts/Player/Player2.gdc", function(ctx, src)
	src = src:gsub(
		utils.escape([[func _ready() -> void :]]),
		[[%0
	if GDPatch.get_mod("customspheres").custom_levels.has(global.currentlevel):
		if global.play_intro_music:
			Audio.music_play(GDPatch.get_mod("customspheres").get_intromusic(global.currentlevel));
	]]
	)
	return src
end)

-- patch env
GDPatch.patch_script_as_text("Scripts/FX/world_environment.gdc", function(ctx, src)
	src = src:gsub(
		utils.escape([[func _ready() -> void :]]),
		[[%0
	if GDPatch.get_mod("customspheres").custom_levels.has(global.currentlevel):
		var _skybox: ImageTexture = GDPatch.get_mod("customspheres").get_skybox(global.currentlevel);
		if _skybox != null: self.get_environment().sky.sky_material.panorama = _skybox;

		var _amb: AudioStreamPlayer = self.find_child("amb");
		var _amb_sfx: AudioStream = GDPatch.get_mod("customspheres").get_ambience(global.currentlevel);
		_amb.stream = _amb_sfx;
		_amb.play();
	]]
	)
	return src
end)
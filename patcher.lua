local utils = require("gdpatch.utils")

GDPatch.patch_script_as_text("Scripts/UI/play.gdc", function(ctx, src)
	src = src:gsub(
		utils.escape([[func _ready() -> void :]]),
		[[%0
	if GDPatch.get_mod("customspheres"): 
		$MainSelect/Custom.show()
]])
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
				_new_lvlbutton.hiderank = false
				_new_lvlbutton.forceunlock = true
				_new_lvlbutton.get_node('TextureRect').texture = GDPatch.get_mod("customspheres").load_thumbnail(lvl);
				_new_lvlbutton.get_node('WorldIcon').texture = GDPatch.get_mod("customspheres").load_icon(lvl);
				_new_lvlbutton.get_node('LvlPreTitle').text = GDPatch.get_mod("customspheres").custom_levels[lvl].pretitle;
				_new_lvlbutton.get_node('LvlName').text = GDPatch.get_mod("customspheres").custom_levels[lvl].title;
				_new_lvlbutton.get_node('LvlScore').text = GDPatch.get_mod("customspheres").custom_levels[lvl].author;
				_new_lvlbutton.get_node('LevelButton').pressed.connect(_new_lvlbutton.get_node("../../..")._on_lvl_pressed.bind(lvl, false));
				_new_lvlbutton.get_node('LevelButton').focus_entered.connect(_new_lvlbutton.get_node("../../..")._on_lvl_focus.bind(lvl, false));
				_lvlbleh.add_child(_new_lvlbutton)
]])
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
]])
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
]])
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
]])
	return src
end)

-- Patch nextlevel
GDPatch.patch_script_as_text("Scripts/System/global.gdc", function(ctx, src)
	src = src:gsub(
		utils.escape([[func _nextlevel():]]),
		[[%0
	if GDPatch.get_mod("customspheres").custom_levels.has(global.currentlevel):
		var _next_level: String = GDPatch.get_mod("customspheres").get_nextlevel(global.currentlevel)
		global.play_intro_music = false
		Audio.music_resume()
		Audio.music_resume2()

		Audio.reverb_trigger = 0
		Audio.music_mult = 0.0
		Audio._lowpass_slow()
		
		global.showdeploying = true
		global._setlevel(_next_level,false)
		return
]])
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
		$Label14.modulate = GDPatch.get_mod("customspheres").get_worldcolour(global.currentlevel)
		return
]])
	return src
end)

-- patch ship for editor compiling
GDPatch.patch_script_as_text("Scripts/Player/ship.gdc", function(ctx, src)
	src = src:gsub(
		utils.escape([[func _ready() -> void :]]),
		[[%0
	if GDPatch.get_mod("customspheres").is_building_from_editor():
		return
]])
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
]])
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

		var _col: Color = GDPatch.get_mod("customspheres").get_world_light_colour(global.currentlevel);
		var _sun: DirectionalLight3D = self.find_child("DirectionalLight3D");
		_sun.light_color = _col;

		var _fog_enabled: bool = GDPatch.get_mod("customspheres").get_fog_enabled(global.currentlevel);
		self.get_environment().set_fog_enabled(_fog_enabled);

		var _volumetric_fog_enabled: bool = GDPatch.get_mod("customspheres").get_volumetric_fog_enabled(global.currentlevel);
		self.get_environment().set_fog_enabled(_volumetric_fog_enabled);

		var _fog_affect: float = GDPatch.get_mod("customspheres").get_env_fog_affect(global.currentlevel);
		self.get_environment().set_fog_sky_affect(_fog_affect);		

		var _volumetric_fog_affect: float = GDPatch.get_mod("customspheres").get_env_volumetric_fog_skyaffect(global.currentlevel);
		self.get_environment().set_volumetric_fog_sky_affect(_volumetric_fog_affect);

		var _sky_brightness: float = GDPatch.get_mod("customspheres").get_env_skybox_brightness(global.currentlevel);
		self.get_environment().get_sky().get_material().energy_multiplier = _sky_brightness;

		var _amb: AudioStreamPlayer = self.find_child("amb");
		var _amb_sfx: AudioStream = GDPatch.get_mod("customspheres").get_ambience(global.currentlevel);
		_amb.stream = _amb_sfx;
		_amb.volume_linear = 1.0;
		_amb.play();
]])
	return src
end)

-- patch lvl complete screen
GDPatch.patch_script_as_text("Scripts/UI/level_complete.gdc", function(ctx, src)
	src = src:gsub(
		utils.escape([[pixelmat.set_shader_parameter("colorr", _blehcolor)]]),
		[[%0
	if GDPatch.get_mod("customspheres").custom_levels.has(global.currentlevel):
		var _col: Color = GDPatch.get_mod("customspheres").get_worldcolour(global.currentlevel)

		$LevelCompleteUI/bg.color = _col
		pixelmat.set_shader_parameter("colorr", _col)

		if !GDPatch.get_mod("customspheres").get_nextlevel(global.currentlevel).is_empty():
			$LevelCompleteUI/HBoxContainer/cont.show()
		else:
			$LevelCompleteUI/HBoxContainer/cont.hide()
]])
	return src
end)

-- patch deploy screen
GDPatch.patch_script_as_text("Scripts/UI/deploy_screen.gdc", function(ctx, src)
	src = src:gsub(
		utils.escape([[func _ready() -> void :]]),
		[[%0
	if GDPatch.get_mod("customspheres").custom_levels.has(global.currentlevel):
		if !GDPatch.get_mod("customspheres").get_nextlevel(global.currentlevel).is_empty():
			$TextureRect2/bar.color = GDPatch.get_mod("customspheres").get_worldcolour(global.currentlevel)
			Audio.sound_play_ui(Audio.sndDeployClick)
			if saves.skin_portrait == 0:
				$TextureRect2/port.texture = _fawn1	
			if saves.skin_portrait == 1:
				$TextureRect2/port.texture = _fawn2
			$ColorRect/Lvl.text = GDPatch.get_mod("customspheres").custom_levels.get(global.currentlevel).title
			$ColorRect/Lvl2.text = GDPatch.get_mod("customspheres").custom_levels.get(global.currentlevel).pretitle

			var _next: String = GDPatch.get_mod("customspheres").get_nextlevel(global.currentlevel)
			$ColorRect4/Lvl.text = GDPatch.get_mod("customspheres").custom_levels.get(_next).title
			$ColorRect4/Lvl2.text = GDPatch.get_mod("customspheres").custom_levels.get(_next).pretitle

			$bg2/LevelText.text = "CUSTOM"
			$bg2/worldtext.text = GDPatch.get_mod("customspheres").get_worldtitle(global.currentlevel)
			$firstsquare/TextureRect.texture = GDPatch.get_mod("customspheres").get_icon(global.currentlevel)
			$"2ndsquare/TextureRect3".texture = GDPatch.get_mod("customspheres").get_icon(_next)
			$AudioStreamPlayer2.stream = _deployingmus
			$AudioStreamPlayer2.play()
			$AnimationPlayer.play("Start")
			$AnimationPlayer2.play("loop")
			$DidYouKnowText.text = global._get_random_hint()
			return
]])
	return src
end)

-- patch pause screen Absolutely Awesome Patches
GDPatch.patch_script_as_text("Scripts/UI/pause.gdc", function(ctx, src)
	src = src:gsub(
		utils.escape([[var _currentlvlarray = saves._lvls.find(global.currentlevel)]]),
		[[%1
	if GDPatch.get_mod("customspheres").custom_levels.has(global.currentlevel):
		var _col: Color = GDPatch.get_mod("customspheres").get_worldcolour(global.currentlevel)
		_lolmat.set_shader_parameter("bg_color",_col)
	elif global.levelrush == 1:
		_lolmat.set_shader_parameter("bg_color",Color("C42B47"))
		_lolmat.set_shader_parameter("fg_color",Color("ffffff"))
	elif global.museum:
		_lolmat.set_shader_parameter("bg_color",Color("8700ff"))
		_lolmat.set_shader_parameter("fg_color",Color("ffffff"))
	elif global.bonus:
		_lolmat.set_shader_parameter("bg_color",Color("ea531f"))
		_lolmat.set_shader_parameter("fg_color",Color("ffffff"))
	else:
		_lolmat.set_shader_parameter("bg_color",Color("a0a0a0"))
		_lolmat.set_shader_parameter("fg_color",Color("ffffff"))

	if GDPatch.get_mod("customspheres").get_nextlevel(global.currentlevel).is_empty():
		$Panel/GridContainer/playnext.hide()
]])
	return src
end)

-- patch gameui
GDPatch.patch_script_as_text("Scripts/UI/gameui.gdc", function(ctx, src)
	src = src:gsub(
		utils.escape([[_adsvignette.material.set_shader_parameter("intensity", 0.0)]]),
		[[%1
	if GDPatch.get_mod("customspheres").custom_levels.has(global.currentlevel):
		var _col: Color = GDPatch.get_mod("customspheres").get_worldcolour(global.currentlevel)
		$UI/LevelDisplay.color = _col
	elif global.levelrush == 1:
		$UI/LevelDisplay.color = Color("C42B47")
	elif global.museum:
		$UI/LevelDisplay.color = Color("8700ff")
	elif global.bonus:
		$UI/LevelDisplay.color = Color("ea531f")
	else:
		$UI/LevelDisplay.color = Color("000000")
]])
	return src
end)

-- patch terminal
GDPatch.patch_script_as_text("Scripts/UI/terminal_screen.gdc", function(ctx, src)
	src = src:gsub(
		utils.escape([[$AnimationPlayer.play("start")]]),
		[[%0
	if GDPatch.get_mod("customspheres").custom_levels.has(global.currentlevel):
		var _terminal: Dictionary = GDPatch.get_mod("customspheres").get_terminal_data(global.currentlevel)
		title.text = _terminal.title;
		date.text = _terminal.date;
		term_text = _terminal.text;
		$CanvasLayer/ColorRect2/TextureRect2.texture = GDPatch.get_mod("customspheres").get_terminal_icon(global.currentlevel)	
]])
	return src
end)

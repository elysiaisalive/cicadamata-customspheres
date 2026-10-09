# + CUSTOM SPHERES"
PROVIDES ACCESS TO USER GENERATED SPHERES

## + INSTALLATION"
1. Install [GDPatch](https://gdpatch.dev/)
2. [Download this repo as a .zip](https://github.com/elysiaisalive/cicadamata-customspheres/archive/refs/heads/master.zip)
3. Unzip the mod into your mods folder located in (`GDPatch/mods/customspheres`)
4. You can now play custom levels!

## + BASIC USAGE"
The mod loads custom levels located in `GDPatch/mods/customspheres/levels`.
Levels must have a valid scene file created by the compiler tools.

## + QUICKSTART
To create a custom level, you will need the [CICADAMATA FGD](https://github.com/elysiaisalive/cicadamata-fgd), and [Trenchbroom 2025.4+](https://github.com/TrenchBroom/TrenchBroom/releases#release-v2025.4)

Once you have the FGD and Trenchbroom downloaded, extract the contents to `AppData/Roaming/TrenchBroom/games/Cicadamata`.
For more information on mapping for trenchbroom, refer to the [official documentation](https://trenchbroom.github.io/manual/latest/)
#### + Setting up Trenchbroom
1. Use [GDRE Tools](https://github.com/GDRETools/gdsdecomp) or [PCKExplorer](https://github.com/DmitriySalnikov/GodotPCKExplorer) to decompile and extract necessary resources from the game.
2. Extract the textures located under `FuncGodot/textures`
3. For optional editor display of mapping entities, extract the models located under `FuncGodot/models`
4. Create a folder i.e `CicadamataFGD` to hold your FGD assets, and place the textures and models folders inside
5. Set your game path to your FGD folder in Trenchbroom under `View > Preferences > Cicadamata > Game Path`

#### + Setting up compiler tools
1. Navigate to `Run > Compile Map`
2. Change the 'Run Tool' path to your game executable (`steam/steamapps/common/CICADAMATA/CICADAMATA.exe`)
3. Set parameters to `run_map::${MAP_DIR_PATH}/${MAP_FULL_NAME}::${MAP_BASE_NAME}`
4. You can now run the compile tools and start testing your new map!

Once you run the compile tools, the mod will autogenerate a scene file and a config file located under `CICADAMATA/GDPatch/mods/customspheres/levels/mycustomlevel`.

### + Customizing your level
#### Custom Images
You can provide custom icons and thumbnails for levels by adding an `icon.png` and a `thumbnail.png`.
It is recommended to keep icons at `9x9`, and thumbnails at `84x69` to keep consistency with the games style.
#### Custom Music
To add custom music to your level you must add an `intro.ogg` and `main.ogg`.
#### Custom Skybox and Ambience
Levels can also have a custom ambient track and skybox by adding respective `ambience.ogg` and `skybox.png`.
Skyboxes are recommended to be authored at `2048x1024` and then rescaled to `1024x1024` for the final texture.

### + Level Design Tips/Considerations
- Keep grid size at `32x` for most main level geometry.
- Keep func_spikes at a maximum of `16-32` units tall.
- Create all brushes with __tb_empty, apply textures to all visible brush faces, and then replace all instances of __tb_empty with the 'skip' texture. This workflow makes it much easier to optimize geometry and unseen faces.

#### + Caveats // TBD
- Player leaderboards are not available
- Custom map textures are currently not possible

### + ACCESS USER CONTENT AT YOUR OWN RISK +
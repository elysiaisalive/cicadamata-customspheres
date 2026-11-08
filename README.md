# + CUSTOM SPHERES"
PROVIDES ACCESS TO USER GENERATED SPHERES

## + INSTALLATION
1. Install [GDPatch](https://gdpatch.dev/)
2. [Download this repo as a .zip](https://github.com/elysiaisalive/cicadamata-customspheres/archive/refs/heads/master.zip)
3. Unzip the mod into your mods folder located in (`GDPatch/mods/customspheres`)
4. You can now play custom levels!

## + WARNING
This mod is work-in-progress and may be incompatible with other mods and may cause random crashes. It is recommended to back up your saves before using this mod.

## + BASIC USAGE
The mod loads custom levels located in `GDPatch/mods/customspheres/levels`.
Levels must have a valid scene file created by Godot or the mods compiler tools.
Levels can be standalone `.scn` or `.tscn` files, or named folders containing their respective scene file and configs.

## + QUICKSTART
To create a custom level, you will need [Trenchbroom 2025.4+](https://github.com/TrenchBroom/TrenchBroom/releases#release-v2025.4)

This mod ships with an FGD preconfigured for Trenchbroom under `CICADAMATA/GDPatch/mods/customspheres/trenchbroom` and an internal FGD resource for the map compiler located under `customspheres/fgd`
\
It is **Not Recommended** that you touch the FGD resources unless you know what you are doing.

For more information on mapping for Trenchbroom, refer to the [official documentation](https://trenchbroom.github.io/manual/latest/)

#### + Setting up Trenchbroom
1. Install Trenchbroom.
2. Copy the contents of `customspheres/trenchbroom` into a new folder into `AppData/Roaming/Trenchbroom/games`
3. Use [GDRE Tools](https://github.com/GDRETools/gdsdecomp) or [PCKExplorer](https://github.com/DmitriySalnikov/GodotPCKExplorer) to decompile and extract necessary resources from the game.
4. Extract the textures located under `FuncGodot/textures`
5. For optional editor display of mapping entities, extract the models located under `FuncGodot/models`, or optionally provide your own. Your models will have to be exported as `.glb` and named the same as their counterpart under `customspheres/fgd/entities`
6. Create a folder i.e `CicadamataFGD` to hold your FGD assets, and place the textures and models folders inside
7. Set your game path to your FGD folder in Trenchbroom under `View > Preferences > Cicadamata > Game Path`

#### + Setting up compiler tools
1. Navigate to `Run > Compile Map`
2. Change the 'Run Tool' path to your game executable (`steam/steamapps/common/CICADAMATA/CICADAMATA.exe`)
3. Set parameters to `run_map::${MAP_DIR_PATH}/${MAP_FULL_NAME}::${MAP_BASE_NAME}`
4. You can now run the compile tools and start testing your new map!

Once you run the compile tools, the mod will generate a scene file and a config file located under `CICADAMATA/GDPatch/mods/customspheres/levels/mycustomlevel`

## + Customizing your level
#### Config Properties
| key | value | description |
| :-: | :-: | :-- |
| author |string | It's you. |
| world_title | string | The name of the world as seen on the deploy screen and other UI elements
| world_colour | string | Must be a valid colour hexcode. Changes the color as seen on the pause menu, and other UI elements
| world_light_colour | string | Must be a valid colour hexcode. Changes the levels sun color
| skybox_brightness | number | A range of `0.0 - 1.0`. Changes how bright the skybox is.
| fog_enabled | boolean | Controls if fog is enabled.
| volumetric_fog_enabled | boolean | Controls if volumetric fog is enabled.
| fog_skyaffect | number | A range of `0.0 - 1.0`. Changes how much fog obscures the skybox
| volumetric_fog_skyaffect | number | A range of `0.0 - 1.0`. Changes how much volumetric fog obscures the skybox
| music_override | string | Useful for level packs. Points to another levels song to use instead of providing `intro.ogg` or `main.ogg` files
| pretitle | string | The name of the sphere
| title | string | The name of the level
| transition | string | Short blurb that appears during level transitions
| location | string | Location on the dropship screen |
| conditions | string | Conditions on the dropship screen |
| warning | string | Warning on the dropship screen |
| next_level | string | The name of the next level to deploy into. Must be a valid level inside `GDPatch/mods/customspheres/levels`
| terminal_title | string | The title of your terminal e.x "+ CUSTOM.ONR" |
| terminal_date | string | The date of your terminal e.x "DD_MMM_7AS" |
| terminal_text | string | The text of your terminal |
| red_score | number | CCDA Rank |
| dmnd_score | number | Diamond Rank |
| gold_score | number | Gold Rank |
| slvr_score | number | Silver Rank |

#### + Custom Images
You can provide custom icons and thumbnails for levels by adding an `icon.png` and a `thumbnail.png`.
It is recommended to keep icons at `9x9`, and thumbnails at `84x69` to keep consistency with the games style.
#### + Custom Music
To add custom music to your level you must add an `intro.ogg` and `main.ogg`.
#### + Custom Skybox and Ambience
Levels can also have a custom ambient track and skybox by adding respective `ambience.ogg` and `skybox.png`.
Skyboxes are recommended to be authored at `2048x1024` and then rescaled to `1024x1024` for the final texture.
#### + Custom Terminal
For custom terminal text, see the above config properties chart.

You can provide a `terminal.png` for the icon that appears your terminal screens. It is recommended to author your icons at `1024x1024`, and white monochromatic to keep consistency with the games style.

### + Level Design Tips // Considerations
- Keep grid size at `32x` for most main level geometry.
- Keep func_spikes at a maximum of `16-32` units tall.
- Group non-detail brush geometry together with `func_geo`. This creates an occluder roughly the size of the brush group. This is incredibly important for optimizing levels with interiors.
- Group detailed brushwork with `func_detail`.
- Create all brushes with the `__tb_empty` texture, apply textures to all visible brush faces, and then replace all instances of `__tb_empty` with the 'skip' texture. This workflow makes it much easier to optimize geometry and unseen faces.

### + Common Errors // Incompatibilities
#### !my level loads into a black screen!
Your level is most likely not set up correctly. Check the console output in Trenchbroom for more information, as well as make sure your level has a Ship.

#### !my level isn't showing up in the menu!
Ensure your level has a unique name that does not conflict with any other level, as the compiler will overwrite any scene with the same name.

#### !one of my mods is broken!
This mod uses heavy script patching and is quite WIP, so it may be incompatible with other mods that do lots of patching.

#### !my level is dark and has no lighting!
Ensure your level has an env.

Pull requests are always welcome.

#### + Caveats // TBD // Bugs
- Moving platforms do not have sound or particles
- Rings are  not resizeable yet
- Rotating certain entities does not work yet
- Scores do not save
- Player leaderboards are not available
- Custom map textures are currently not possible
- Music will restart upon deployment in a level after transitioning to `next_level`

### + ACCESS USER CONTENT AT YOUR OWN RISK +
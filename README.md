# + CUSTOM SPHERES"
PROVIDES ACCESS TO USER GENERATED SPHERES

## + INSTALLATION
1. Install [GDPatch](https://gdpatch.dev/)
2. [Download this repo as a .zip](https://github.com/elysiaisalive/cicadamata-customspheres/archive/refs/heads/master.zip)
3. Unzip the mod into your mods folder located in `GDPatch/mods/customspheres`
4. You can now play custom levels!

## + WARNING
This mod is work-in-progress. It may be incompatible with other mods or cause random crashes. It is recommended to back up your saves before using this mod.

## + BASIC USAGE
The mod loads custom levels located in `GDPatch/mods/customspheres/levels`. Levels must be a valid `.map` file created by Trenchbroom.

## + QUICKSTART
To create a custom level, you will need [Trenchbroom 2025.4](https://github.com/TrenchBroom/TrenchBroom/releases#release-v2025.4)

This mod ships with an FGD preconfigured for Trenchbroom under `CICADAMATA/GDPatch/mods/customspheres/trenchbroom`.

For more information on mapping for Trenchbroom, refer to the [official documentation](https://trenchbroom.github.io/manual/latest/)

[Here is a useful playlist of Trenchbroom tutorials from the wonderful dumptruck_ds](https://www.youtube.com/playlist?list=PLgDKRPte5Y0AZ_K_PZbWbgBAEt5xf74aE)

#### + Setting up Trenchbroom
1. Install Trenchbroom
2. Copy the contents of `customspheres/trenchbroom` into a new folder into `AppData/Roaming/Trenchbroom/games/cicadamata`
3. Use [GDRE Tools](https://github.com/GDRETools/gdsdecomp) or [PCKExplorer](https://github.com/DmitriySalnikov/GodotPCKExplorer) to decompile and extract necessary resources from the game. Make sure to open the project in 'full recovery' mode.
4. Extract the textures located under `FuncGodot/textures` into `AppData/Roaming/Trenchbroom/games/cicadamata/textures`
5. Navigate to `AppData/Roaming/Trenchbroom/games/cicadamata` and place the textures inside of the `textures` folder
6. Set your game path to `AppData/Roaming/Trenchbroom/games/cicadamata` in Trenchbroom under `View > Preferences > Cicadamata > Game Path`

By default, the mod ships with display models for Rings, Glass and the Dropship. For optional editor display of mapping entities like enemies, extract the models located under `Assets/models`, or optionally provide your own. Your models will have to be exported as `.glb` and named the same as their counterpart inside the `customspheres/trenchbroom/CICADAMATA.fgd` file

#### + Setting up Trenchbroom Compiler Tools
1. Navigate to `Run > Compile Map`, and select the profile 'Export Map'
2. Change the 'Working Directory' path to `SteamLibrary/steamapps/common/CICADAMATA/GDPatch/mods/customspheres/levels`
3. Set the 'Export Map' file path to `${WORK_DIR_PATH}/${MAP_BASE_NAME}/${MAP_FULL_NAME}`
4. Change the 'Run Tool' path to your game executable `SteamLibrary/steamapps/common/CICADAMATA/CICADAMATA.exe`
5. Set the 'Run Tool' parameters to `export_map::${MAP_DIR_PATH}/${MAP_FULL_NAME}::${MAP_BASE_NAME}`
6. You can now press the 'Compile' button and begin testing your map!

Once you run the compile tools, a `.map` file and a config file will be created inside of `CICADAMATA/GDPatch/mods/customspheres/levels/your-custom-level`

## + Your first level
For your level to be playable, you will need to add a Ship, 4 Cores, and an Exit.

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
Ensure your level has a unique name that does not conflict with any other level, as the compiler tools will overwrite any map with the same name.

#### !one of my mods is broken!
This mod uses heavy script patching and is quite WIP, so it may be incompatible with other mods that do lots of patching.

#### !my level is dark and has no lighting!
Ensure your level has an env entity.

#### + Caveats // TBD // Bugs
- Moving platforms do not have sound or particles
- Rings are  not resizeable yet
- Rotating certain entities does not work yet
- Scores do not save
- Player leaderboards are not available
- Custom map textures are currently not possible
- Music will restart upon deployment in a level after transitioning to `next_level`

### + ACCESS USER CONTENT AT YOUR OWN RISK +
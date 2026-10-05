# + CUSTOM SPHERES"
PROVIDES ACCESS TO USER GENERATED SPHERES

## + INSTALLATION"
1. Install [GDPatch](https://gdpatch.dev/)
2. [Download this repo as a .zip](https://github.com/elysiaisalive/cicadamata-customspheres/archive/refs/heads/master.zip)
3. Unzip the mod into your mods folder located in (`GDPatch/mods/customspheres`)
4. You may now view freely.

## + BASIC USAGE"
The mod loads custom levels located in `GDPatch/mods/customspheres/levels`.
Levels must have a valid '.scn' file, and config file created by the [compiler tools](https://thisisavalidlinkokyes)


## + CREATING CUSTOM LEVELS"
To create a custom level, you will need the [CICADAMATA FGD](https://github.com/elysiaisalive/cicadamata-fgd), and [Trenchbroom 2025.4+](https://github.com/TrenchBroom/TrenchBroom/releases#release-v2025.4)

Once you have the FGD and Trenchbroom downloaded, drop the Game Config in `AppData/Roaming/TrenchBroom/games/Cicadamata`
For more information on mapping for trenchbroom, refer to the [official documentation](https://trenchbroom.github.io/manual/latest/)

Once you run the compile tools, the mod will autogenerate a `.scn` and a config file located under `CICADAMATA/GDPatch/mods/customspheres/levels/mycustomlevel`.

You can provide custom icons and thumbnails for levels by adding an `icon.png` and a `level_name.png`.
It is recommended to keep icons at 9x9, and thumbnails at 84x69 to keep consistency with the games style.
All custom level assets besides `icon.png` must match the name of the level/containing folder, otherwise they will not load.

To add custom music to your level you must add a `levelname_intro.ogg` and `levelname_main.ogg`.


### ACCESS USER CONTENT AT YOUR OWN RISK.
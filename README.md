# + CUSTOM SPHERES"
PROVIDES ACCESS TO USER GENERATED SPHERES

## + INSTALLATION"
1. Install [GDPatch](https://gdpatch.dev/)
2. [Download this repo as a .zip](https://github.com/elysiaisalive/cicadamata-customspheres/archive/refs/heads/master.zip)
3. Unzip the mod into your mods folder located in (`GDPatch/mods/customspheres`)
4. You may now view freely.

## + BASIC USAGE"
The mod loads custom levels located in `GDPatch/mods/customspheres/levels`.
Levels must have a valid scene file and config file created by the [compiler tools](https://thisisavalidlinkokyes)


## + QUICKSTART
To create a custom level, you will need the [CICADAMATA FGD](https://github.com/elysiaisalive/cicadamata-fgd), and [Trenchbroom 2025.4+](https://github.com/TrenchBroom/TrenchBroom/releases#release-v2025.4)

For a guide to get started, read [here](https://github/ccdamappingtutorial).

Once you have the FGD and Trenchbroom downloaded, drop the Game Config in `AppData/Roaming/TrenchBroom/games/Cicadamata`.
For more information on mapping for trenchbroom, refer to the [official documentation](https://trenchbroom.github.io/manual/latest/)

- use [GDRE Tools](https://github.com/GDRETools/gdsdecomp) or [PCKExplorer](https://github.com/DmitriySalnikov/GodotPCKExplorer) to decompile and extract the textures from the game.
- Extract the textures located under `FuncGodot/textures`
- For optional editor display of mapping entities, extract the models located under `FuncGodot/models`
- it is highly suggested you create some sort of folder called `CicadamataFGD` and place the textures and models inside
- set your game path to your FGD folder in Trenchbroom under View > Preferences > Cicadamata > Game Path

Once you run the compile tools, the mod will autogenerate a scene file and a config file located under `CICADAMATA/GDPatch/mods/customspheres/levels/mycustomlevel`.

### + Customizing your level
#### Custom Images
You can provide custom icons and thumbnails for levels by adding an `icon.png` and a `thumbnail.png`.
It is recommended to keep icons at 9x9, and thumbnails at 84x69 to keep consistency with the games style.
#### Custom Music
To add custom music to your level you must add an `intro.ogg` and `main.ogg`.
#### Custom Skybox and Ambience
Levels can also have a custom ambient track and skybox by adding respective `ambience.ogg` and `skybox.png`.
Skyboxes are recommended to be authored at 2048x1024 and then rescaled to 1024x1024 for the final texture.

### + Level Design Tips/Considerations
- Keep grid size at 32x for most main level geometry.
- Keep func_spikes at maximum heights of 16-32 Units.
- Create all brushes with __tb_empty, apply textures to all visible brush faces, and then replace all instances of __tb_empty with the 'skip' texture. This workflow makes it much easier to optimize geometry and unseen faces.


### + ACCESS USER CONTENT AT YOUR OWN RISK +
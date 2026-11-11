# THE FIVE MISSING ORBS — development workspace

A Godot 4.6.3 Android-first project for Eldoria. **Work in progress, not the full game.** The current build is a small third-person movement prototype and village blockout using built-in primitives together with included CC0 textures and models. It needs no additional asset downloads or plugins at runtime. See `docs/ASSET_CREDITS.md` for sources and licensing. Canonical story remains as supplied by the project owner.

## Current state

- Phase 1: configured project, folder structure, small 3D test environment.
- Phase 2: prototype player controller, gravity, jump, third-person orbit camera, touchscreen joystick, camera drag, jump button, keyboard input and an animated CC0 placeholder knight. Idle and run clips are wired; classes, customisation and final character art are not implemented.
- Phase 3: village blockout started: timber house blockouts with textured roofs and chimneys, a textured road and ground, placeholder trees, distant hills and MultiMesh meadow decoration. One NPC, Mira the guild herald, patrols and has a short interactive introduction. Village gameplay and final art are not complete.
- Phase 4: one data-driven local introductory quest, dialogue, ordered objectives, tracker and 25 session-only XP. This is an early quest prototype, not the full quest system.
- Phases 5–10: not implemented. In particular there is **no multiplayer, authentication, enemies, combat, inventory, actual Orbs, persistence, Champion system, large open world or commercial release build**.
- An update-check prototype is configured for the public GitHub repository `RUTH-BOT-TECH/Neverland-game-`. The end-to-end update flow is not yet tested. It opens a release page; Android installation still requires user action. See `docs/GITHUB_SETUP.md`.
- The blue sphere in the test scene is a decorative test marker, not a collectible Orb.

## Android installation and run (for when a release ZIP is supplied)

1. Install **Godot 4.6.3 Standard for Android** from https://godotengine.org/download/archive/4.6.3-stable/ (Android → Standard). If installing the APK, only approve installation from a source you trust.
2. Extract the project ZIP with the Android Files app, for example to Downloads. Inside `The_Five_Missing_Orbs` you should see `project.godot`.
3. Open Godot and allow file access if prompted. If it cannot see the folder, enable All files access for Godot when available, or place the project in Documents/Downloads. Android Go can restrict this permission.
4. Choose Import in the project manager, select the extracted `project.godot` (or its parent folder, depending on the picker), confirm and open the project. Keep Compatibility renderer.
5. Tap Run Project in the editor toolbar. You should see the title, a basic character, a village street, houses, grass and trees. The ruins and blue test marker are off to the side. Use the Stop button or Android back/app switching to return to the editor.

Godot 4.6's documented minimum for a simple project with Compatibility is Android 6, OpenGL ES 3.0 and 3 GB RAM; this does not guarantee performance. Android editor is early access and is not optimised for phones. https://docs.godotengine.org/en/4.6/about/system_requirements.html and https://docs.godotengine.org/en/4.6/tutorials/editor/using_the_android_editor.html

## Controls and testing

- Touch: drag the bottom-left circular stick to move; drag elsewhere on the right half of the screen to orbit the camera; tap JUMP at bottom-right. Multiple fingers are supported. The character respawns if it falls below the ground.
- Follow the quest tracker. Approach Mira on the village street, tap TALK and use Next through her final line. Closing early does not advance the quest. Go to the ruins on the eastern side of the village (to the player’s right and further along the street) and tap EXAMINE when near the glowing blue survey marker. The marker is not an Orb. A completion message and +25 session XP appear on the tracker.
- Player movement and the NPC patrol pause during dialogue. Quest state and XP reset when the game is restarted; there is no persistence yet.
- Keyboard (optional): WASD moves relative to the camera, arrow keys orbit, Space jumps, and E starts/advances a nearby conversation.
- Walk on the ground and onto the low stone platform near the ruins; rotate the view; jump and land. Walk into a house wall to check its collision. Run on an Android device to evaluate controls, visibility, smoothness and overheating. The four ruin pillars, step, pedestal, trees, road tiles and grass are visual-only and currently have no collision. The ground, platform and house walls have collision.
- If the screen is black or an error occurs, check the editor Output/Debugger and record the exact message, phone model, Android version, and Godot version.

## Settings and input map

`project.godot` already specifies main scene `res://scenes/world/Foundation.tscn`, Compatibility rendering on desktop/mobile, 1280×720 base viewport, canvas-items stretch, expanded aspect and landscape. No autoload scripts are registered yet. The Input Map defines `move_left` A, `move_right` D, `move_forward` W, `move_back` S, `jump` Space, `interact` E and `look_left/right/up/down` arrow keys, using physical key codes. Touch uses custom signals rather than emulating keyboard actions.

## Scene hierarchy and script connections

`res://scenes/world/Foundation.tscn`:

```
Foundation (Node3D)
├── QuestManager (Node; res://scripts/quests/quest_manager.gd)
├── WorldEnvironment (WorldEnvironment)
├── Sun (DirectionalLight3D)
├── Ground (StaticBody3D)
│   ├── Mesh (MeshInstance3D)
│   └── Collision (CollisionShape3D)
├── Platform (StaticBody3D)
│   ├── Mesh (MeshInstance3D)
│   └── Collision (CollisionShape3D)
├── Ruins (Node3D)
│   ├── PillarNorthWest (MeshInstance3D)
│   ├── PillarNorthEast (MeshInstance3D)
│   ├── PillarSouthWest (MeshInstance3D)
│   ├── PillarSouthEast (MeshInstance3D)
│   ├── Pedestal (MeshInstance3D)
│   ├── TestMarker (MeshInstance3D)
│   └── Step (MeshInstance3D)
├── Village (instance of res://scenes/world/Village.tscn)
├── VillageHerald (instance of res://scenes/characters/VillageHerald.tscn)
├── Player (instance of res://scenes/characters/Player.tscn)
└── Overlay (CanvasLayer)
    ├── Margin (MarginContainer)
    │   └── Labels (VBoxContainer)
    │       ├── Title (Label)
    │       └── Subtitle (Label)
    ├── TouchControls (Control; res://scripts/player/touch_controls.gd)
    ├── DialogueUI (instance of res://scenes/ui/DialogueUI.tscn)
    ├── QuestUI (instance of res://scenes/ui/QuestUI.tscn)
    └── UpdateNotice (instance of res://scenes/ui/UpdateNotice.tscn)
```

`res://scenes/characters/Player.tscn`:

```
Player (CharacterBody3D; res://scripts/player/player_controller.gd)
├── Collision (CollisionShape3D)
├── Visual (Node3D)
│   ├── Body, Belt, Head, Hair (hidden primitive MeshInstance3D placeholders)
│   ├── LeftLeg, RightLeg (hidden Node3D; each contains Mesh)
│   ├── LeftArm, RightArm (hidden Node3D; each contains Mesh and Hand)
│   ├── Sword (hidden Node3D; contains Blade and Hilt)
│   └── KnightModel (instanced GLB; AnimationPlayer contains Idle and Run)
└── CameraPivot (Node3D)
    └── SpringArm3D (SpringArm3D)
        └── Camera3D (Camera3D)
```

`res://scenes/characters/VillageHerald.tscn`:

```
VillageHerald (Node3D; scripts/world/village_npc.gd)
├── Model (Node3D)
│   └── Peasant (instanced GLB; AnimationPlayer has Idle and Walk)
└── NameLabel (Label3D)
```

Its `dialogue` property points to `res://resources/dialogue/village_herald.tres`, whose content schema lives in `res://scripts/world/dialogue_data.gd`. The NPC patrol and conversation are local prototypes, not multiplayer-authoritative.

`res://scenes/ui/DialogueUI.tscn`:

```
DialogueUI (Control; scripts/ui/dialogue_ui.gd)
├── TalkButton (Button)
└── DialoguePanel (PanelContainer)
    └── Margin (MarginContainer)
        └── Contents (VBoxContainer)
            ├── Speaker (Label)
            ├── Line (Label)
            └── Buttons (HBoxContainer)
                ├── CloseButton (Button)
                └── NextButton (Button)
```

`Foundation.tscn` instances the dialogue UI under Overlay and assigns its `player_path` to `../../Player` and `npc_path` to `../../VillageHerald`. TalkButton, CloseButton and NextButton are connected to the UI's `open_dialogue`, `close_dialogue` and `advance_dialogue` methods respectively. The UI enables the Talk button in range and temporarily locks player input and NPC patrol while speaking.

`res://scenes/ui/QuestUI.tscn`:

```
QuestUI (Control; scripts/quests/quest_ui.gd)
├── Tracker (PanelContainer)
│   └── Margin (MarginContainer)
│       └── Content (VBoxContainer)
│           ├── Title (Label)
│           └── Objective (Label)
└── ExamineButton (Button)
```

`Foundation.tscn` assigns the QuestManager node `res://resources/quests/heralds_warning.tres`, whose schema is `res://scripts/quests/quest_definition.gd`. QuestUI is under Overlay and receives paths to Player, QuestManager, and Ruins/TestMarker. DialogueUI emits `dialogue_finished` only when the last line is advanced; Foundation connects that signal to `QuestManager.on_herald_dialogue_finished()`. QuestUI's ExamineButton connects to `examine_marker()`. The manager accepts the correct event only for the current objective and grants the local session reward once. This prototype is not server-authoritative, and local XP must not be trusted in multiplayer.

`res://scenes/ui/UpdateNotice.tscn`:

```
UpdateNotice (Control; scripts/networking/update_notice.gd)
├── Request (HTTPRequest)
└── Panel (PanelContainer)
    └── Margin (MarginContainer)
        └── Content (VBoxContainer)
            ├── Text (Label)
            └── Buttons (HBoxContainer)
                ├── Later (Button)
                └── Open (Button)
```

The `UpdateNotice` instance uses `resources/settings/update_config.tres` (schema: `scripts/networking/update_config.gd`). Open and Later buttons are connected to `open_release_page()` and `dismiss()`. It checks public GitHub Releases at startup when enabled; this project is configured for `RUTH-BOT-TECH/Neverland-game-`. Export version/code and config's current build number must match. No in-app silent installation is implemented.

`scenes/world/Village.tscn` has a Village (Node3D) root with `res://scripts/world/village_builder.gd` attached. At runtime the script generates its road, houses, trees, hills and three meadow MultiMesh nodes. These generated children do not appear in the editor scene tree until the scene runs.

In `Foundation.tscn`, TouchControls signals `move_changed`, `look_dragged` and `jump_pressed` connect to Player methods `set_touch_move`, `look_by` and `queue_jump`. The player script excludes its own collision RID from the spring arm.

## Folder map

```
The_Five_Missing_Orbs/
├── project.godot, README.md
├── scenes/   world/ characters/ enemies/ bosses/ orbs/ quests/ ui/ multiplayer/
├── scripts/  player/ world/ ui/ combat/ inventory/ quests/ networking/ ai/ progression/
├── assets/   models/ textures/ animations/ audio/ materials/
├── resources/ items/ characters/ quests/ enemies/ dialogue/ settings/
├── autoload/
├── docs/
├── tools/patch_godot_manifest.py
└── tests/phase2_smoke.gd, village_dialogue_smoke.gd, quest_smoke.gd, update_checker_smoke.gd
```

Empty folders contain `.gitkeep` placeholders; these are not scripts. Godot may hide them in its FileSystem dock.

## Test record

Godot 4.6.3 Linux: project imported and ran; automated headless smoke script checked scene loading, landing on the ground, movement, upward jump velocity, camera rotation, joystick touch and release, and that the Run animation is selected while moving. A second headless smoke test checked proximity, dialogue buttons, input lock, keyboard interaction, all lines and closing. A third headless smoke test checked ordered quest events, early dialogue close, tracker updates, proximity, keyboard interaction and single-award XP. The update-checker smoke test exercised disabled mode, version selection, unsafe URL and invalid JSON rejection, offline behavior, and notice display. A live request to an unrelated public GitHub Releases endpoint returned HTTP 200 on Linux; no actual Eldoria repository or Android update flow was tested. A desktop software-rendered screenshot was also captured. Neither test verifies physical touch devices, Android editor behavior or phone performance. Run the automated tests from a desktop command line with `godot --headless --path . --script res://tests/phase2_smoke.gd` and `godot --headless --path . --script res://tests/village_dialogue_smoke.gd`, and `godot --headless --path . --script res://tests/quest_smoke.gd`, and `godot --headless --path . --script res://tests/update_checker_smoke.gd`; no command line is required on Android to run the game normally.

A separately supplied Android **debug preview APK** was exported before the quest was added; its signature was verified, but installation and runtime on a phone remain untested. That APK does not contain the quest or update checker. See `docs/TEST_BUILDS.md` for installation, update signing, and export workaround notes. The final release is not available yet.

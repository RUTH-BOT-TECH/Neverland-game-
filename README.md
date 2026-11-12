# THE FIVE MISSING ORBS — development workspace

A Godot 4.6.3 Android-first project for Eldoria. **Work in progress, not the full game.** The current build is a small third-person movement prototype and village blockout using built-in primitives together with included free-licensed textures, models and motion capture. It needs no additional asset downloads or plugins at runtime. See `docs/ASSET_CREDITS.md` for sources and licensing. Canonical story remains as supplied by the project owner.

## Current state

- Phase 1: configured project, folder structure, small 3D test environment.
- Phase 2: prototype player controller, gravity, jump, third-person orbit camera, touchscreen joystick, camera drag, jump button, keyboard input and an animated human-proportioned adventurer made from CC0 character assets and free-to-use motion capture. Idle, run and sword clips are wired; classes, customisation and final character art are not implemented.
- Phase 3: village blockout started: timber house blockouts with textured roofs, chimneys, gables, doors, windows and crates; a textured road and ground; stylized broadleaf trees, an original faceted mountain backdrop and MultiMesh grass and flowers. Royal banners carry five empty Orb settings; a roadside sign points toward the ruins and the temporary trial grounds. Vines and a wagon add village detail. House doors are decorative and cannot be entered. The nearby survey ruins have weathered stone columns, a rear lintel and five empty decorative inlays. One human-proportioned NPC, Mira the guild herald, patrols and has context-sensitive conversations based on local progress. Village gameplay and final art are not complete.
- Phase 4: one data-driven local introductory quest, dialogue, ordered objectives, tracker and 25 locally saved XP. This is an early quest prototype, not the full quest system.
- Phase 5: a local first-Orb encounter prototype: a stationary Cinder Warden with a visible attack danger circle, player health and basic melee, and a guarded Orb of Flame at a temporary, textured Ashen shrine blockout. This blockout is a testing shortcut, not the final Ashen Mountains region.
- Phase 6: a unique-Orb collection counter and local prototype checkpoints exist; equipment, a general inventory, cloud/account saving and authoritative multiplayer persistence are not implemented.
- Phases 7–10: not implemented. There is **no multiplayer, authentication, authoritative validation, account or server-side persistence, Champion system, large open world or commercial release build**. Combat, enemy AI, Orb effects and content are prototypes, not the complete systems.
- An update-check prototype is configured for the public GitHub repository `RUTH-BOT-TECH/Neverland-game-`. The end-to-end update flow is not yet tested. It opens a release page; Android installation still requires user action. See `docs/GITHUB_SETUP.md`.
- The blue crystal in the village ruins is a survey marker, not an Orb; its five surrounding inlays are decorative. The orange Orb of Flame is a separate collectible behind the local trial guardian.

## Android installation and run (for when a release ZIP is supplied)

1. Install **Godot 4.6.3 Standard for Android** from https://godotengine.org/download/archive/4.6.3-stable/ (Android → Standard). If installing the APK, only approve installation from a source you trust.
2. Extract the project ZIP with the Android Files app, for example to Downloads. Inside `The_Five_Missing_Orbs` you should see `project.godot`.
3. Open Godot and allow file access if prompted. If it cannot see the folder, enable All files access for Godot when available, or place the project in Documents/Downloads. Android Go can restrict this permission.
4. Choose Import in the project manager, select the extracted `project.godot` (or its parent folder, depending on the picker), confirm and open the project. Keep Compatibility renderer.
5. Tap Run Project in the editor toolbar. You should see the title, a basic character, a village street, houses, grass and trees. The ruins and blue test marker are off to the side. Use the Stop button or Android back/app switching to return to the editor.

Godot 4.6's documented minimum for a simple project with Compatibility is Android 6, OpenGL ES 3.0 and 3 GB RAM; this does not guarantee performance. Android editor is early access and is not optimised for phones. https://docs.godotengine.org/en/4.6/about/system_requirements.html and https://docs.godotengine.org/en/4.6/tutorials/editor/using_the_android_editor.html

## Controls and testing

- Touch: drag the bottom-left circular stick to move; drag elsewhere on the right half of the screen to orbit the camera; tap JUMP or ATTACK at bottom-right. Multiple fingers are supported. The character respawns if it falls below the ground.
- Follow the quest tracker. Approach Mira on the village street, tap TALK and use Next through her final line. Closing early does not advance the quest. Go to the ruins on the eastern side of the village (to the player’s right and further along the street) and tap EXAMINE when near the glowing blue survey marker. The marker is not an Orb. A completion message and +25 local XP appear on the tracker. After completing that quest, follow the Flame trial hint east of the ruins to the Cinder Warden. Face the guardian and use ATTACK within range; wait for the attack cooldown. When the red-orange circle appears, move outside its edge before the strike lands. The circle marks the guardian’s horizontal damage radius; its attack also checks height. After defeating it, approach the orange Orb and tap COLLECT. The HUD shows 1/5 Orbs. Return to Mira and tap TALK again to hear a clue about why the Orbs may have been separated. Her reminders change after the opening, survey, guardian defeat and Orb collection. Further regions are not yet playable.
- Player movement and the NPC patrol pause during dialogue. On defeat, the player respawns with full health and an undefeated guardian resets. The introductory quest objective, its XP, a defeated guardian and Flame Orb ownership are checkpointed locally on the device. Close and reopen the game to check restoration. Player position, health, an undefeated guardian’s partial damage and other state are not saved. Uninstalling or clearing app data can erase local saves; these are not cloud saves or multiplayer-authoritative.
- Keyboard (optional): WASD moves relative to the camera, arrow keys orbit, Space jumps, F attacks, and E interacts with nearby people and objects.
- Walk from the street through the gap between the eastern houses to the ruins; approach the platform edge and examine the marker when prompted. Jump to get on the platform; rotate the view; jump and land. Walk into a house wall to check its collision. Run on an Android device to evaluate controls, visibility, smoothness and overheating. The house doors are decorative; houses cannot be entered. The royal banners, signpost, wagon, mountain backdrop, ruin columns, step, pedestal, inlays, trees, road tiles and grass are visual-only and currently have no collision. The ground, platform and house walls have collision.
- If the screen is black or an error occurs, check the editor Output/Debugger and record the exact message, phone model, Android version, and Godot version.

## Settings and input map

`project.godot` already specifies main scene `res://scenes/world/Foundation.tscn`, Compatibility rendering on desktop/mobile, 1280×720 base viewport, canvas-items stretch, expanded aspect and landscape. No autoload scripts are registered yet. The Input Map defines `move_left` A, `move_right` D, `move_forward` W, `move_back` S, `jump` Space, `attack` F, `interact` E and `look_left/right/up/down` arrow keys, using physical key codes. Touch uses custom signals rather than emulating keyboard actions.

## Scene hierarchy and script connections

`res://scenes/world/Foundation.tscn`:

```
Foundation (Node3D)
├── OrbInventory (Node; scripts/inventory/orb_inventory.gd)
├── QuestManager (Node; res://scripts/quests/quest_manager.gd)
├── LocalSaveManager (Node; res://scripts/progression/local_save_manager.gd)
├── WorldEnvironment (WorldEnvironment)
├── Sun (DirectionalLight3D)
├── Ground (StaticBody3D)
│   ├── Mesh (MeshInstance3D)
│   └── Collision (CollisionShape3D)
├── Platform (StaticBody3D)
│   ├── Mesh (MeshInstance3D)
│   └── Collision (CollisionShape3D)
├── Ruins (Node3D)
│   ├── PillarNorthWest (hidden original MeshInstance3D)
│   ├── PillarNorthEast (hidden original MeshInstance3D)
│   ├── PillarSouthWest (hidden original MeshInstance3D)
│   ├── PillarSouthEast (hidden original MeshInstance3D)
│   ├── Pedestal (MeshInstance3D)
│   ├── TestMarker (MeshInstance3D)
│   ├── Step (MeshInstance3D)
│   ├── RuinDetails (Node3D; scripts/world/ruins_art.gd)
│   └── MarkerLabel (Label3D)
├── Village (instance of res://scenes/world/Village.tscn)
├── AshenShrine (instance of res://scenes/world/AshenShrine.tscn)
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
    ├── UpdateNotice (instance of res://scenes/ui/UpdateNotice.tscn)
    ├── FlameTrialUI (instance of res://scenes/ui/FlameTrialUI.tscn)
    └── SaveWarning (Label)
```

`res://scenes/characters/Player.tscn`:

```
Player (CharacterBody3D; res://scripts/player/player_controller.gd)
├── Vitals (Node; scripts/player/player_vitals.gd)
├── Combat (Node; scripts/combat/player_combat.gd)
├── Collision (CollisionShape3D)
├── Visual (Node3D)
│   ├── Body, Belt, Head, Hair (hidden primitive MeshInstance3D placeholders)
│   ├── LeftLeg, RightLeg (hidden Node3D; each contains Mesh)
│   ├── LeftArm, RightArm (hidden Node3D; each contains Mesh and Hand)
│   ├── Sword (hidden Node3D; contains Blade and Hilt)
│   └── KnightModel (instanced `assets/models/eldoria_adventurer/Adventurer.glb`; AnimationPlayer contains Idle, Walk, Run, Sword slash and Jump)
└── CameraPivot (Node3D)
    └── SpringArm3D (SpringArm3D)
        └── Camera3D (Camera3D)
```

`res://scenes/characters/VillageHerald.tscn`:

```
VillageHerald (Node3D; scripts/world/village_npc.gd)
├── Model (Node3D)
│   └── Peasant (instanced `assets/models/eldoria_adventurer/Mira.glb`; AnimationPlayer has Idle and Walk)
└── NameLabel (Label3D)
```

Its `dialogue` property points to `res://resources/dialogue/village_herald.tres`, whose content schema lives in `res://scripts/world/dialogue_data.gd`. Four more resources (`mira_survey.tres`, `mira_trial.tres`, `mira_warden_defeated.tres` and `mira_flame_recovered.tres`) use the same schema. The Foundation instance supplies paths to QuestManager, the guardian and OrbInventory; `current_dialogue()` chooses the matching local story conversation, and a dialogue remains stable while open even if progress changes. Missing optional dependencies fall back to the opening. The NPC patrol and conversation are local prototypes, not multiplayer-authoritative. The child name `Peasant` remains for existing animation paths; its model is now the custom-generated Mira at world scale.

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

`Foundation.tscn` assigns the QuestManager node `res://resources/quests/heralds_warning.tres`, whose schema is `res://scripts/quests/quest_definition.gd`. QuestUI is under Overlay and receives paths to Player, QuestManager, and Ruins/TestMarker. DialogueUI emits `dialogue_finished` only when the last line of the opening conversation is advanced; Foundation connects that signal to `QuestManager.on_herald_dialogue_finished()`. QuestUI's ExamineButton connects to `examine_marker()`. The manager accepts the correct event only for the current objective and grants the local session reward once. This prototype is not server-authoritative, and local XP must not be trusted in multiplayer.

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

`res://scenes/world/AshenShrine.tscn`:

```
AshenShrine (Node3D)
├── AshGround (MeshInstance3D)
├── Plinth (MeshInstance3D)
├── Guardian (instance of scenes/bosses/CinderWarden.tscn)
│   ├── Model (Node3D)
│   │   └── Juggernaut (instanced GLB, includes AnimationPlayer)
│   ├── NameLabel (Label3D)
│   └── AttackWarning (Node3D)
│       ├── Fill (MeshInstance3D)
│       └── Edge (MeshInstance3D)
└── FlameOrb (instance of scenes/orbs/FlameOrb.tscn)
    └── Visual (Node3D)
        ├── Core (MeshInstance3D)
        ├── Ring (MeshInstance3D)
        └── Sparks (GPUParticles3D)
```

`res://scenes/ui/FlameTrialUI.tscn`:

```
FlameTrialUI (Control; scripts/orbs/flame_trial_ui.gd)
├── Status (PanelContainer)
│   └── Margin (MarginContainer)
│       └── Content (VBoxContainer)
│           ├── HealthText (Label)
│           ├── Health (ProgressBar)
│           └── Info (Label)
└── CollectButton (Button)
```

Foundation instances AshenShrine, OrbInventory and FlameTrialUI. Guardian's `scripts/ai/cinder_warden.gd` uses paths to Player and QuestManager. Its `AttackWarning` uses a transparent filled disk and an opaque edge, no collision or shadows. It appears for the 1.1-second wind-up and scales its edge to the same 2.3-unit horizontal radius used by the hit check. It hides after the hit, on respawn, defeat or restoration of a defeated guardian; pausing controls freezes both the warning and wind-up. Actual timing and visibility still need testing on phones. Orb's `scripts/orbs/flame_orb.gd` uses paths to Player, Guardian and OrbInventory and `resources/items/orb_flame.tres`; its data schema is `scripts/orbs/orb_definition.gd`. FlameTrialUI receives paths to those nodes and connects CollectButton to `collect_orb()`. TouchControls `attack_pressed` connects to Player/Combat `try_attack()`. Quest completion gates guardian damage, and guardian defeat and player proximity gate collection. OrbInventory rejects duplicate and unknown identifiers. All of these checks are local only and do not provide multiplayer security.

### Village survey ruins

`Foundation.tscn` keeps the quest's `Ruins/TestMarker` node and platform collision. `Ruins/RuinDetails`, using `scripts/world/ruins_art.gd`, replaces only the marker mesh with a blue crystal and generates four decorative columns, a lintel, pedestal crown and five empty brass inlays. The original pillar meshes are retained but hidden. These decorations have no collision; the platform remains solid. The ruin and platform were moved together away from the eastern house walls. The marker's interaction range is 3.7 units so it can be examined from the platform edge without jumping. The inlays and marker are **not collectible Orbs**.

### Local checkpoint prototype

`Foundation.tscn` adds `LocalSaveManager` (`scripts/progression/local_save_manager.gd`) as a child of Foundation, after the Overlay. Its exported paths point to QuestManager, OrbInventory, AshenShrine/Guardian, AshenShrine/FlameOrb and Overlay/SaveWarning. It restores only after those nodes are ready, then listens for quest changes, guardian defeat and Orb additions. Checkpoints are written to `user://eldoria_local_progress_v1.json` via a temporary file, retaining a previous `.bak` checkpoint. If the primary is damaged and a valid backup exists, it loads that older checkpoint, shows a warning, and preserves the damaged primary as `.damaged` before the next replacement. If no usable checkpoint exists or a newer schema is encountered, it warns and pauses writes to avoid overwriting data. It validates supported milestone combinations but is **not cheat-proof**; no local file can authorize multiplayer rewards or the Champion. Progress is device-local, with no reset UI or account migration yet. Clearing data/uninstalling may delete it.

The guardian's `restore_defeated()` and Orb's `restore_collected()` restore presentation without re-emitting a reward event. Quest XP is reconstructed once from the completed quest definition. `session_xp` is the existing internal variable name; its single supported quest value is locally saved through the checkpoint.

`scenes/world/Village.tscn` has a Village (Node3D) root with `res://scripts/world/village_builder.gd` attached. At runtime the script generates its road, houses, decorative VillageLandmarks (banner poles, royal banners, wagon, waypost, boards and labels), trees, faceted backdrop and three meadow MultiMesh nodes. The landmarks and backdrop are visual-only; house doors are decorative. `assets/textures/eldoria/royal_banner.png` is original art; `tools/generate_royal_banner.py` can regenerate it offline with Pillow. These generated children do not appear in the editor scene tree until the scene runs.

In `Foundation.tscn`, TouchControls signals `move_changed`, `look_dragged` and `jump_pressed` connect to Player methods `set_touch_move`, `look_by` and `queue_jump`. The `attack_pressed` signal connects to Player/Combat `try_attack`. The player script excludes its own collision RID from the spring arm. The KnightModel node name is retained for existing connections; it now instances the human-proportioned adventurer at world scale, rotated to face the controller’s forward direction. Idle and Run loop; the sword attack clip is sped up to fit the existing combat cooldown. The imported Jump clip is not yet wired to the jump state. Character selection, final art and device optimization remain future work.

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
└── tests/phase2_smoke.gd, village_dialogue_smoke.gd, quest_smoke.gd, update_checker_smoke.gd, flame_trial_smoke.gd, village_art_smoke.gd, local_save_smoke.gd, local_save_restart_smoke.gd, ruins_access_smoke.gd, warden_warning_smoke.gd, adventurer_visual_smoke.gd, mira_story_smoke.gd
```

Empty folders contain `.gitkeep` placeholders; these are not scripts. Godot may hide them in its FileSystem dock.

## Test record

Godot 4.6.3 Linux: project imported and ran; automated headless smoke script checked scene loading, landing on the ground, movement, upward jump velocity, camera rotation, joystick touch and release, and that the Run animation is selected while moving. A second headless smoke test checked proximity, dialogue buttons, input lock, keyboard interaction, all lines and closing. A third headless smoke test checked ordered quest events, early dialogue close, tracker updates, proximity, keyboard interaction and single-award XP. The Flame trial smoke test exercised quest gating, attack direction and cooldown, guardian damage, player respawn, defeat, collection, and duplicate prevention. The update-checker smoke test exercised disabled mode, version selection, unsafe URL and invalid JSON rejection, offline behavior, and notice display. A live request to an unrelated public GitHub Releases endpoint returned HTTP 200 on Linux; no actual Eldoria repository or Android update flow was tested. A ruins access test drove the character from the street through the houses to the marker and completed the quest at the platform edge. An adventurer visual-integration smoke test checked imported hero and Mira animation clips, movement, patrol and sword playback; a desktop render was also inspected. The guardian warning smoke test checked the displayed radius against hit detection, escape during actual physics movement, pausing, respawning and defeat. The local-save smoke test checked checkpoint restore, duplicate prevention, corruption recovery and future-version protection. The Mira story smoke test checks each conversation, early closure, distance and control rechecks, stable dialogue and no repeated reward. A separate two-process Linux restart test wrote a completed trial in one process and restored it and the corresponding story dialogue in the next. A village art smoke test checked houses, landmarks, sign labels, backdrop, foliage batches and tree placement headlessly; the foliage approach exclusions were also checked using the desktop Compatibility renderer. Desktop software-rendered screenshots were captured. The visual style remains an early stylized blockout and does not yet match the reference image. Neither test verifies physical touch devices, Android editor behavior or phone performance. Run the automated tests from a desktop command line with `godot --headless --path . --script res://tests/phase2_smoke.gd` and `godot --headless --path . --script res://tests/village_dialogue_smoke.gd`, and `godot --headless --path . --script res://tests/quest_smoke.gd`, and `godot --headless --path . --script res://tests/update_checker_smoke.gd`, and `godot --headless --path . --script res://tests/flame_trial_smoke.gd`, and `godot --headless --path . --script res://tests/village_art_smoke.gd`, and `godot --headless --path . --script res://tests/local_save_smoke.gd`, and `godot --headless --path . --script res://tests/ruins_access_smoke.gd`, and `godot --headless --path . --script res://tests/warden_warning_smoke.gd`, and `godot --headless --path . --script res://tests/adventurer_visual_smoke.gd`, and `godot --headless --path . --script res://tests/mira_story_smoke.gd`. For an actual process restart, run `godot --headless --path . --script res://tests/local_save_restart_smoke.gd -- write` followed by `godot --headless --path . --script res://tests/local_save_restart_smoke.gd -- read`; no command line is required on Android to run the game normally.

A separately supplied Android **debug preview APK** was exported before the quest was added; its signature was verified, but installation and runtime on a phone remain untested. That earlier APK does not contain the quest, update checker or Flame trial. GitHub Preview 2 contains the quest and update checker, but not the later Flame trial, village art changes, local saves, the new warning or the new adventurer unless a newer release is published. See `docs/TEST_BUILDS.md` for installation, update signing, and export workaround notes. The final release is not available yet.

# Car Simulator Work Log

Last updated: 2026-04-10 (physics fix + road rebuild)
Workspace: /home/barak/car_simulator

## Project Goal Snapshot
Build a Godot urban car simulation backbone with:
- Player arcade-style car controller
- NPC traffic on fixed routes
- Multi-camera vehicle rig (front/rear/left/right + aerial helper)
- HUD with camera feeds and controls
- Clean Git history and runnable project skeleton

## What Was Implemented

### 1. Full backbone scaffolding
Created full project layout from the design document:
- scenes/, scripts/, assets/, data/, shaders/
- Core scenes: main/world/vehicles/cameras/ui/debug
- Core scripts: player, NPC, traffic, camera feeds, HUD, speedometer, debug

Key files:
- project.godot
- scenes/main/main.tscn
- scenes/vehicles/player_car.tscn
- scenes/vehicles/npc_car.tscn
- scenes/cameras/vehicle_camera_rig.tscn
- scenes/ui/hud.tscn
- scripts/vehicles/player_car_controller.gd
- scripts/vehicles/npc_car_controller.gd
- scripts/traffic/traffic_manager.gd
- scripts/cameras/vehicle_camera_rig.gd
- scripts/ui/hud_controller.gd

### 2. Git setup and hygiene
Repository initialized and cleaned:
- .gitignore configured for Godot/editor artifacts
- .gitattributes added
- VS Code transient DB files removed from tracking

Recent commits:
- 9168762 Fix GDScript indentation and strict typing parse errors
- a599df3 Stop tracking VS Code browse database files
- 78210a7 Ignore generated editor and Godot UID artifacts
- fcb9616 Initialize Godot car simulator backbone

### 3. Major parser/runtime fixes
Several scripts were auto-flattened and caused parser errors.
Fixed indentation/typing issues across camera/UI/vehicle/traffic scripts.

Runtime error fixed in traffic spawning:
- Problem: npc.global_position assigned before add_child(), causing !is_inside_tree() warning.
- Fix: add_child(npc) first, then assign global_position.
- File: scripts/traffic/traffic_manager.gd

### 4. HUD redesign (as requested)
New HUD behavior implemented:
- Fullscreen main camera area
- Right-side camera stack (front/rear/left/right)
- Click side feed to promote it to main view
- Minimap panel at top-left (aerial feed)
- Bottom info bar with speed/status/help
- FOV slider + numeric value per side camera panel
- Tab cycles main feed

Files updated:
- scenes/ui/hud.tscn
- scenes/ui/camera_panel.tscn
- scripts/ui/hud_controller.gd
- scripts/ui/camera_panel.gd
- scripts/cameras/vehicle_camera_rig.gd

### 5. FOV lock feature
Added per-camera lock toggles:
- Each camera panel has Lock toggle
- If a locked panel's FOV changes, all locked panels sync to same FOV
- Unlocked panels remain independent

Files:
- scenes/ui/camera_panel.tscn
- scripts/ui/camera_panel.gd
- scripts/ui/hud_controller.gd

### 6. Car and camera visual alignment
- Player car body material set to red
- Camera rig anchors lowered/repositioned to sit on the box body better

Files:
- scenes/vehicles/player_car.tscn
- scenes/cameras/vehicle_camera_rig.tscn

### 7. Axis/orientation changes requested and applied
- Player forward convention switched to +Z in controller
- Front/rear probes and wheel marker semantics adjusted to match

Files:
- scripts/vehicles/player_car_controller.gd
- scenes/vehicles/player_car.tscn

### 8. Left/right camera iterations
User requested multiple directional and positional changes.
Current state should be treated as intentional latest user preference:
- Left and right camera anchors are swapped in position per latest request.
- Orientation was preserved while swapping positions at that stage.

Current camera rig file to inspect first if more changes are needed:
- scenes/cameras/vehicle_camera_rig.tscn

### 9. Input handling fix - arrow keys now usable during gameplay
Problem: Arrow keys (ui_up/ui_down/ui_left/ui_right) were being consumed by HUD UI buttons,
preventing player car from receiving directional input when UI was focused.

Solution implemented:
- Added _unhandled_input() method to hud_controller.gd that consumes arrow key inputs
  and marks them as handled, so they bypass UI navigation and reach player controller
- Set focus_mode = 0 (FOCUS_NONE) on SelectButton and LockToggle in camera_panel.tscn
  to prevent buttons from grabbing keyboard focus

Result: Arrow keys now reliably control player car movement regardless of HUD focus state.

Files modified:
- scripts/ui/hud_controller.gd
- scenes/ui/camera_panel.tscn

### 10. Car color scheme update
Updated vehicle colors for visual distinction:
- Player car: Changed from red to green (0.1, 0.8, 0.2)
- NPC cars: Changed to red (0.83, 0.08, 0.1) - added material to npc_car scene

Files modified:
- scenes/vehicles/player_car.tscn
- scenes/vehicles/npc_car.tscn

### 11. World environment - meaningful colors and trees
Added realistic colors to world objects and introduced vegetation:

Colors applied:
- Ground: Green grass (0.2, 0.6, 0.15)
- Roads: Dark asphalt (0.15, 0.15, 0.18)
- Intersections: Darker asphalt (0.12, 0.12, 0.15)
- Sidewalks: Light gray concrete (0.7, 0.7, 0.75)
- Buildings: Brown brick (0.6, 0.4, 0.3)

Tree system:
- Created new tree asset (scenes/world/tree.tscn) with brown trunk + green foliage
- Added 6 trees scattered around city block at varied positions

Files created:
- scenes/world/tree.tscn

Files modified:
- scenes/world/city_block.tscn (added Trees container with 6 tree instances)
- scenes/world/road_segment_straight.tscn (asphalt material)
- scenes/world/intersection_4way.tscn (darker asphalt material)
- scenes/world/sidewalk_block.tscn (concrete material)
- scenes/world/building_block_a.tscn (brick material)

### 12. Vehicle input fix - proper keyboard pass-through
Problem: Player couldn't drive vehicle with arrow keys. HUD Control node was blocking input 
from reaching the vehicle controller despite button focus fixes.

Solution implemented:
- Set mouse_filter = IGNORE on MainArea and MainFeedPanel (non-interactive areas)
  This allows keyboard input to pass through to the vehicle controller
- Removed overly-aggressive _unhandled_input() method that was consuming ui_* actions
- Kept side panel interactive buttons functional for camera selection and FOV control

Result: Arrow keys now properly reach the vehicle controller. Vehicle movement works with:
- Up/W: Forward
- Down/S: Backward
- Left/A: Steer left
- Right/D: Steer right
- Space: Brake
- R: Reset vehicle

Files modified:
- scenes/ui/hud.tscn (added mouse_filter = 2 to MainArea and MainFeedPanel)
- scripts/ui/hud_controller.gd (removed _unhandled_input method)

### 13. Map-ready world layout pass
Addressed map readiness issues where the player could spawn into clutter and roads were not laid out.

Layout changes:
- Built a connected road network in city block with a center intersection and multi-segment north/south/east/west corridors
- Added sidewalks framing the inner road ring
- Placed building blocks in outer zones (not at world origin), scattered around roads to keep drive lanes open
- Kept trees and environment dressing without blocking main road loop

Player spawn fix:
- Moved player spawn in main scene to a safe road position away from the map center clutter
- New player start transform in main: (-20, 0.7, 0)

NPC road path setup:
- Added explicit NPC waypoint markers on road lanes in city block (group: npc_waypoint)
- Added explicit NPC spawn markers on road lanes (group: npc_spawn)
- Added visible NPC path guide strips on roads so the traffic loop is clearly visible in game
- Updated traffic manager to auto-collect and sort these markers by name, then drive NPCs along that road loop
- Added fallback route behavior if markers are missing

Result:
- Map now has a usable drivable layout
- Player starts on open road instead of at blocked center
- NPCs follow a road-aligned loop path defined by scene markers

Files modified:
- scenes/world/city_block.tscn
- scripts/traffic/traffic_manager.gd
- scenes/main/main.tscn

### 14. Playability fixes: controls, blue player, and road visibility
Addressed three blocking issues reported during play test.

Arrow-key movement reliability:
- Disabled keyboard focus for FOV slider and FOV spinbox so arrow keys are not captured by UI widgets
- Camera panel controls remain mouse-usable, while movement keys now pass through consistently

Player car color update:
- Changed player car body material from green to blue

Road visibility and collision/spawn alignment:
- Raised all road/intersection meshes above the ground plane so asphalt is visible
- Raised sidewalks above terrain so they render correctly
- Corrected building Y placement so buildings sit on top of terrain instead of being half-buried
- Raised player start and respawn height to avoid spawning partially inside terrain
- Raised NPC path guide strips to sit above roads

Result:
- Arrow keys can control the car without UI stealing focus
- Player car is now blue
- Roads are clearly visible and drivable

Files modified:
- scenes/ui/camera_panel.tscn
- scenes/vehicles/player_car.tscn
- scenes/world/city_block.tscn
- scenes/main/main.tscn

### 15. Physics fix + complete road network rebuild
Root cause found for car not moving + roads completely rebuilt.

Physics fix (THE critical fix):
- RigidBody3D default can_sleep=true caused the body to sleep when stationary
- Once asleep, _integrate_forces() stops being called → input is NEVER sampled
- Set can_sleep=false and contact_monitor=true on PlayerCar RigidBody3D
- This ensures the physics callback runs every frame, reading input and applying forces

Road layout complete rebuild:
- Replaced the broken clustered road layout with a proper connected road network:
  - Center intersection at origin (16x16)
  - 4 main roads extending from center (EW and NS, each 64m long)
  - 4 corner intersections at (±80, ±80) forming a rectangular perimeter
  - 4 perimeter roads connecting corners (each 144m long)
  - 8 connector roads from center axes to perimeter corners
- All roads scaled from base 20x6 mesh using transform scaling
- Roads sit at Y=0.55 (just above ground top at Y=0.5)

Building placement:
- 4 buildings in each quadrant at (-40,-40), (40,-40), (-40,40), (40,40)
- 2 outer buildings for variety
- All buildings properly sit on ground (center Y = 12.5 for 24m tall mesh)

NPC path updated:
- Waypoints follow the rectangular perimeter loop (8 points at corners and midpoints)
- Spawn points placed on perimeter roads
- Yellow guide strips match perimeter road positions and sizes
- All NPC Y positions set to 1.0 (above ground collision surface)

Player spawn:
- Positioned at (-30, 1.2, 0) on the main east-west road
- Clear of any buildings or intersections

Result:
- Car physics now work — arrow keys/WASD will move the car
- Roads form a clear, connected, drivable network
- Large open perimeter loop for NPC traffic
- Buildings placed properly in quadrants between roads

Files modified:
- scenes/vehicles/player_car.tscn (can_sleep=false, contact_monitor=true)
- scenes/world/city_block.tscn (complete rewrite)
- scenes/main/main.tscn (player spawn position)

## Environment and Tooling Notes

### Godot install detection result
Current executable chain:
- command path: /home/barak/.local/bin/godot
- resolves to: /home/barak/.local/godot/4.6.1-stable/Godot_v4.6.1-stable_linux.x86_64
- version: 4.6.1.stable.official.14d19694e

Conclusion: manual/local install (not apt/snap/flatpak managed).

### Stable update path configured
Symlink chain now supports easy upgrades:
- /home/barak/.local/bin/godot -> /home/barak/.local/godot/current
- /home/barak/.local/godot/current -> active version binary

To switch to a new version:
ln -sfn ~/.local/godot/<new-version-folder>/Godot_v<new-version>_linux.x86_64 ~/.local/godot/current

Verify:
- godot --version
- readlink -f ~/.local/godot/current

## Known Current Focus Areas
- Validate camera left/right semantics in play mode whenever transforms are changed.
- Continue world blockout and driving feel tuning.
- Add README polish and export verification once gameplay loop stabilizes.

## Quick Resume Checklist
1. Open scenes/main/main.tscn and run project.
2. Verify vehicle controls work: arrow keys/WASD for movement, space for brake, R to reset.
3. Test camera switching: click side feeds to promote to main view.
4. Verify side-camera mapping in HUD matches intended left/right semantics.
5. Tune player handling in scripts/vehicles/player_car_controller.gd.
6. Expand world roads/intersections in scenes/world/city_block.tscn.
7. Tune traffic spacing/speeds in scripts/traffic/traffic_manager.gd and scripts/vehicles/npc_car_controller.gd.
8. Export test build after stabilizing camera/UI behavior.

## 2026-04-10 Update - Implemented and Working

This section records only items that were implemented and verified in-session.

### Camera and HUD behavior
- Main layout set to: large main camera view + top-left minimap + right camera column (front/rear/left/right).
- Main camera defaults to Front on start.
- Side camera panels are clickable and can promote their feed to main view.
- Tab cycles main view through front/rear/left/right.
- Minimap is always on and uses the aerial camera feed.
- Minimap zoom changed from slider UI to mouse-wheel while hovering over minimap panel.

### Camera rig fixes
- Fixed camera follow issue by keeping source cameras on the vehicle rig and syncing dedicated SubViewport feed cameras to source transforms.
- Set feed cameras active (`current = true`) so SubViewport textures render.
- Corrected aerial camera orientation and applied 180-degree Y rotation per request.

### FOV controls
- Side camera panels use per-camera FOV slider + numeric value.
- Per-camera lock behavior now works as sync grouping:
  - editing a locked camera updates all locked cameras,
  - editing an unlocked camera updates only itself.
- Removed global "lock all" behavior.

### Driving and physics tuning
- Removed temporary debug print logging from player controller.
- Reverse driving behavior fixed (input handling and direction-switch logic updated).
- Acceleration tuning adjusted for stronger launch and improved responsiveness.
- Speed cap fixed to real 80 km/h target by using 22.2 m/s and applying absolute velocity clamp.

### World collision and boundaries
- Added border collision walls around the ground to prevent falling out of world bounds.
- Added collision to buildings (`building_block_a.tscn`).
- Added collision to trees (`tree.tscn`, trunk + foliage colliders).

### HUD diagnostics
- Added live FPS overlay in the main window (top-right), updated from engine FPS each frame.

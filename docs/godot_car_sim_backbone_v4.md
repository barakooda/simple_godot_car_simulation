# Godot Car Simulation Backbone

**Project:** Urban Car Simulation / Robotics-style Vehicle Sandbox  
**Engine:** Godot 4.6.2-stable  
**Language:** GDScript  
**Physics approach:** `RigidBody3D` for the player car, lightweight scripted traffic for NPC cars  
**Target:** Windows desktop build  
**Scope:** Small, clean, playable prototype with a user-controlled car, simple traffic, 4 attached cameras, and a UI that displays all camera feeds. The first target map is a compact **400×400 meter** urban slice built mostly from simple primitives.

---

## 1. Project goals

Build a compact, modular project that demonstrates:

- A controllable urban car
- Basic vehicle feel (arcade, not high-fidelity dynamics)
- A compact **400×400 m** urban slice with a simple but intentional road network
- NPC cars moving on predefined paths
- Four physical cameras attached to the player car
- A HUD that shows all four live camera feeds
- Code structure that is easy to explain in an interview

This project should optimize for:

- learning
- simplicity
- clarity
- clean architecture
- reliable delivery

It should **not** optimize for:

- realistic tire physics
- advanced traffic AI
- complex destruction/collision systems
- large world streaming
- visual polish beyond what is needed

---

## 2. Design philosophy

### Core decision
This is an **arcade simulation backbone**, not a realistic vehicle dynamics simulator.

### Why
Godot can support this project well, but the project should stay understandable and stable. The player car should use a custom controller over `RigidBody3D`, and NPC traffic should use lightweight scripted movement instead of full vehicle physics.

### Main rule
Whenever a choice appears between:

- more realism and more complexity
- slightly less realism and much more control

choose the second.

---

## 3. Minimal feature set


## 3A. Assignment coverage matrix

This section maps the project backbone directly to the assignment goals so implementation decisions stay aligned.

| Assignment need | Planned Godot solution |
|---|---|
| User-controlled urban car | `player_car.tscn` with `RigidBody3D` + custom arcade street-driving controller |
| Acceleration / braking / steering | `player_car_controller.gd` + `vehicle_input.gd` |
| Vehicle should not feel like free sliding | lateral grip correction, angular damping, speed-based steering reduction |
| Basic urban environment with roads, turns, intersections | `city_block.tscn` composed from road and intersection scenes inside a compact **400×400 m** playable area |
| Drivable area of at least several dozen meters | one compact **400×400 m** city slice / loop with multiple turns and at least one intersection |
| Additional moving vehicles | `npc_car.tscn` + `traffic_manager.gd` + path following |
| Additional vehicles on predefined routes or simple driving logic | lane paths (`Path3D`) + look-ahead follow logic |
| Avoid obviously unrealistic NPC collisions/jitter | lane constraints + follow-distance braking + optional intersection gate |
| Four cameras attached to the car | `vehicle_camera_rig.tscn` with front / rear / left / right anchors parented to the player vehicle |
| Cameras move and rotate with the vehicle | camera rig is part of the player car scene, not world-anchored |
| Camera FOV should be configurable | exported `fov` values per camera in `vehicle_camera_rig.gd` |
| Live UI from all four cameras | `SubViewport` feeds shown inside `hud.tscn` |
| Optional aerial / hover view for presentation | lightweight top-down helper camera, minimap, or debug aerial capture |
| Clear labeling of each feed | `Front / Rear / Left / Right` panels in HUD |
| One of the required display layouts | default to `driver view + 3 PiP`, optional toggle to `2x2 grid` |
| Reasonable refresh / smoothness | reduce `SubViewport` resolution, keep shaders/materials simple, target stable realtime playback |
| Code structure that is easy to review | separate scripts for player control, cameras, traffic, UI |
| Windows runnable build | standard Windows export preset |
| README + architecture explanation | README skeleton included below |
| Full source delivery | repo/project tree kept clean, no generated junk required for running |
| 2–3 minute demo video | explicit capture checklist included below |
| Optional short design doc | markdown section can be exported as the design note |

**Scope guard:** whenever a feature threatens the assignment schedule, prefer the simpler option that still satisfies the row above.

---


### Required

1. Player-controlled car
2. Forward / reverse / steering / brake
3. Small urban environment with turns and intersections
4. 3 to 6 NPC cars moving on routes with simple anti-collision behavior
5. Four mounted cameras:
   - front
   - rear
   - left
   - right
6. HUD with live views from all cameras
7. Windows export
8. README with setup and architecture notes

### Nice to have

1. Switch between layouts:
   - 2x2 grid
   - main front camera + 3 small views
2. Minimap, aerial helper camera, or debug top-down helper
3. Speed readout
4. Reverse indicator
5. Reset car hotkey
6. Simple obstacle props and lane markings

### Explicitly out of scope

1. realistic suspension tuning
2. traffic lights with full logic
3. pedestrian AI
4. pathfinding traffic system
5. advanced sensor simulation
6. networking

---

## 3B. World layout target

The first MVP world should be a **400×400 meter** urban slice.

### Why this size

- clearly exceeds the minimum drivable space the assignment asks for
- still small enough to block out and tune quickly
- large enough for visible NPC traffic and multiple turns
- small enough to avoid wasting time on empty space

### Recommended layout inside 400×400 m

- one main 4-way intersection
- one T intersection
- one loop road that NPC cars can drive continuously
- 2 to 3 side streets
- straight segments long enough to show acceleration and braking
- simple buildings made from boxes / primitives
- optional sidewalks / curbs if they are easy to add

### Environment art rule for MVP

Use **simple polygons / primitives first**.

That means:

- road meshes can be simple planes or boxes
- buildings can be box blocks
- intersections can be custom assembled from simple pieces
- visual polish is secondary to drivability, cameras, and UI

Do not spend early time on detailed modeling. The project should first prove:

- the player car can drive comfortably
- the city layout reads clearly
- NPC traffic has a believable route
- the four camera feeds are useful

---

## 4. Folder structure

```text
res://
  scenes/
    main/
      main.tscn
    world/
      city_block.tscn
      road_segment_straight.tscn
      road_segment_turn.tscn
      intersection_4way.tscn
      building_block_a.tscn
      sidewalk_block.tscn
    vehicles/
      player_car.tscn
      npc_car.tscn
      traffic_manager.tscn
    cameras/
      vehicle_camera_rig.tscn
    ui/
      hud.tscn
      camera_panel.tscn
      speedometer.tscn
    debug/
      debug_overlay.tscn

  scripts/
    core/
      game.gd
      config.gd
      signal_bus.gd
    vehicles/
      player_car_controller.gd
      npc_car_controller.gd
      vehicle_input.gd
      vehicle_state.gd
      wheel_visual_sync.gd
      respawn_manager.gd
    traffic/
      traffic_manager.gd
      traffic_path.gd
      path_follower.gd
    cameras/
      vehicle_camera_rig.gd
      camera_feed_registry.gd
    ui/
      hud_controller.gd
      camera_panel.gd
      layout_controller.gd
      speedometer.gd
    world/
      world_loader.gd
      checkpoint.gd
    debug/
      debug_draw.gd
      debug_metrics.gd

  assets/
    models/
      vehicles/
      urban/
    materials/
    textures/
    icons/

  shaders/

  data/
    traffic_routes/
      route_a.tres
      route_b.tres
      route_c.tres
    tuning/
      player_car_settings.tres
      npc_car_settings.tres

  README.md
  project.godot
```

---

## 5. Scene architecture

## 5.1 Main scene

`main.tscn`

Root:

```text
Main (Node3D)
├── WorldRoot (Node3D)
│   └── CityBlock (instance)
├── VehicleRoot (Node3D)
│   ├── PlayerCar (instance)
│   └── TrafficManager (instance)
├── UIRoot (CanvasLayer)
│   └── HUD (instance)
└── DebugRoot (CanvasLayer)
    └── DebugOverlay (instance)
```

Responsibilities:

- boot the level
- spawn or connect the player car
- connect UI to camera feeds
- initialize traffic
- expose one obvious project entry point

---

## 5.2 Player car scene

`player_car.tscn`

Recommended structure:

```text
PlayerCar (RigidBody3D)
├── BodyMesh (Node3D or MeshInstance3D)
├── CollisionShape3D
├── VisualWheels (Node3D)
│   ├── WheelFL
│   ├── WheelFR
│   ├── WheelRL
│   └── WheelRR
├── CameraRig (instance: vehicle_camera_rig.tscn)
├── RespawnAnchor (Marker3D)
├── GroundProbeFront (RayCast3D)
├── GroundProbeRear (RayCast3D)
├── GroundProbeLeft (RayCast3D)
├── GroundProbeRight (RayCast3D)
└── EngineAudioPlaceholder (AudioStreamPlayer3D)
```

### Why `RigidBody3D`
Use a custom arcade controller over `RigidBody3D` so you control:

- acceleration force
- drag
- steering response
- angular damping
- lateral grip approximation
- collision response without building a fake body system from scratch

That gives you a more educational and controllable architecture.

### Player physics notes
Keep the player controller intentionally simple:

- apply drive force along the local forward axis
- clamp top speed manually
- damp lateral velocity to fake tire grip
- scale steering down as speed increases
- add extra angular damping when the car is nearly aligned
- use raycasts only for lightweight ground/debug checks, not for a full suspension simulation

### Player car script split

- `player_car_controller.gd`
  - movement logic
  - throttle/brake/steer processing
  - force application
  - fake grip stabilization
  - reset logic hooks

- `vehicle_input.gd`
  - collects player inputs
  - converts raw input into normalized control values

- `vehicle_state.gd`
  - current speed
  - steering amount
  - gear direction state
  - grounded state
  - camera references

- `wheel_visual_sync.gd`
  - visual wheel turning/spin only
  - no gameplay logic

---

## 5.3 NPC car scene

`npc_car.tscn`

```text
NPCCar (Node3D)
├── VisualRoot (Node3D)
├── BodyMesh (MeshInstance3D or imported scene)
├── FrontSensor (RayCast3D)
├── FrontLeftSensor (RayCast3D)
├── FrontRightSensor (RayCast3D)
├── RouteAnchor (Marker3D)
└── DebugMarker (Marker3D)
```

### NPC philosophy
NPC vehicles should be cheap, predictable, and easy to tune.

They do **not** need full physics.

Use a scripted path-following approach:

- move along predefined lane paths
- orient smoothly toward the next path sample
- maintain a target cruise speed
- slow down or stop if another NPC is too close ahead
- keep routes loopable and deterministic

Scripts:

- `npc_car_controller.gd`
- `path_follower.gd`

This is enough to create the feeling of traffic.

### Recommended NPC driving model
Do **not** make NPCs free-drive with full navigation.

Instead:

- each NPC is assigned to a lane path (`Path3D` or waypoint list)
- the NPC samples a look-ahead point on the path
- steering is derived from the direction to that look-ahead point
- speed is driven toward `target_speed`
- if the forward sensors detect another car inside `safe_follow_distance`, reduce desired speed
- if the distance is below `hard_stop_distance`, stop completely

This gives you simple non-collision behavior without trying to build a full traffic AI system.

---

## 5.4 Camera rig scene

`vehicle_camera_rig.tscn`

```text
VehicleCameraRig (Node3D)
├── FrontCameraAnchor (Marker3D)
│   ├── FrontCamera (Camera3D)
│   └── FrontViewport (SubViewport)
├── RearCameraAnchor (Marker3D)
│   ├── RearCamera (Camera3D)
│   └── RearViewport (SubViewport)
├── LeftCameraAnchor (Marker3D)
│   ├── LeftCamera (Camera3D)
│   └── LeftViewport (SubViewport)
├── RightCameraAnchor (Marker3D)
│   ├── RightCamera (Camera3D)
│   └── RightViewport (SubViewport)
├── OptionalMainDriverCamera (Camera3D)
└── OptionalAerialHelperCamera (Camera3D)
```

**Important:** the four required feeds are always Front / Rear / Left / Right.  
The aerial/helper camera is optional and exists only to support presentation, debugging, or a lightweight “hover shot” interpretation if you want to cover that wording from the PDF without changing the mandatory four-feed UI.

### Camera mounting suggestions

- front: windshield height, slight downward angle
- rear: rear center, looking back
- left: left side mirror area or side window
- right: right side mirror area or side window

### Camera settings

Keep all side/rear cameras lightweight:

- lower viewport resolution than main display
- configurable FOV values exposed in the inspector
- disable expensive post effects where possible
- update continuously during play so all feeds are visibly live

Recommended starting viewport sizes:

- front/main: 1024x576 or 1280x720
- side/rear feeds: 512x288 or 640x360

---

## 5.5 HUD scene

`hud.tscn`

```text
HUD (Control)
├── MarginContainer
│   └── RootLayout
│       ├── MainFeedPanel
│       │   ├── MainFeedLabel
│       │   └── MainFeedTextureRect
│       ├── SidePanelContainer
│       │   ├── FrontPanel
│       │   ├── RearPanel
│       │   ├── LeftPanel
│       │   └── RightPanel
│       ├── Speedometer
│       ├── StatusLabel
│       └── HelpText
└── PauseOverlay
```

Alternative layout mode:

```text
2x2 GridContainer
├── FrontPanel
├── RearPanel
├── LeftPanel
└── RightPanel
```

Each panel should show:

- camera label
- live texture
- optional border/highlight

Scripts:

- `hud_controller.gd`
- `camera_panel.gd`
- `layout_controller.gd`
- `speedometer.gd`

---

## 6. Systems breakdown

## 6.1 Vehicle control system

### Inputs

Actions to define:

```text
move_forward
move_backward
steer_left
steer_right
brake
handbrake
reset_vehicle
toggle_camera_layout
toggle_debug
quit
```

### Vehicle control model

Use a simple arcade model:

- forward thrust when accelerating
- reverse thrust when backing up
- steering stronger at low/medium speeds
- reduced steering at high speed
- lateral velocity damping to fake grip
- separate braking force
- handbrake exaggerates rear slip slightly if desired

### Key exposed tuning variables

In `player_car_settings.tres` or exported properties:

- `engine_force`
- `reverse_force`
- `brake_force`
- `max_speed`
- `steer_rate`
- `max_steer_angle`
- `lateral_grip`
- `angular_stability`
- `linear_drag`
- `reset_height_threshold`

Keep all tuning in one place.


### Suggested starting player tuning
Use rough starting values first, then tune in-editor:

- `engine_force`: medium-high
- `reverse_force`: 40% to 60% of forward force
- `brake_force`: stronger than forward acceleration
- `max_speed`: intentionally limited
- `lateral_grip`: high enough to stop drift from feeling like ice
- `angular_stability`: enough to prevent spin-outs from small impacts

The goal is not realism. The goal is a stable, convincing car feel.

### Street-driving feel tuning guide
The player car should feel like a normal urban vehicle, not like a drift car.

#### Core handling targets

- turns feel deliberate, not twitchy
- sideways slip is small and short-lived
- braking is strong and readable
- the car settles quickly after steering corrections
- higher speed means less steering authority
- light bumps should not spin the car easily

#### Anti-drift strategy
Apply these ideas inside `player_car_controller.gd`:

1. **Separate forward and lateral velocity**
   - compute local velocity each physics tick
   - keep forward speed mostly intact
   - aggressively damp the sideways component

2. **Speed-based steering**
   - allow stronger steering at low speed
   - gradually reduce max steering as speed rises
   - avoid instant yaw changes at high speed

3. **Strong braking authority**
   - braking should overpower throttle
   - when braking hard, also reduce forward velocity smoothly

4. **Yaw stabilization**
   - increase angular damping while grounded
   - optionally apply extra yaw correction if sideways slip exceeds a threshold

5. **Grounded-only grip logic**
   - only apply the strongest lateral grip correction while the car is considered grounded
   - this avoids strange corrections when the body lifts or flips

#### Recommended first-pass ranges
These are not “real car” values. They are starting points for a believable street-driving feel:

- `max_speed`: low to medium for the map size
- `steer_rate`: medium
- `max_steer_angle`: modest
- `lateral_grip`: high
- `angular_stability`: medium-high
- `linear_drag`: low to medium
- `brake_force`: high

#### Behavioral rules
During tuning, prefer these outcomes:

- if the car feels floaty, increase `lateral_grip`
- if the car keeps rotating after turns, increase `angular_stability`
- if the car turns too sharply at speed, reduce speed-scaled steering
- if the car feels dead and cannot rotate at all, reduce grip or angular damping slightly
- if braking feels weak, raise `brake_force` before changing steering

#### Non-goals
Do **not** try to simulate:

- tire temperature
- true suspension dynamics
- slip angle modeling
- realistic differential behavior

The assignment only needs a convincing controllable car, not a vehicle dynamics research model.

#### Tuning pass checklist
A tuning pass is good enough when:

- the player can accelerate, brake, reverse, and turn reliably
- the car does not visibly drift during normal steering input
- the car can take a 90-degree urban corner without spinning out
- releasing the steering recenters the motion quickly
- minor wall contacts do not make the car rotate unrealistically
- the handling is understandable within 10 seconds of driving

---

## 6.2 Traffic system

### Architecture

Traffic should be managed by a central `TrafficManager`.

Responsibilities:

- spawn NPC cars
- assign routes
- despawn/recycle if needed
- update simple separation logic

### Traffic path representation

A route can be:

- a `Path3D` in scene, or
- a saved resource containing waypoint positions

Preferred for clarity:

- `TrafficPath` scene or resource with ordered points

### NPC logic level

Minimal:

- follow route at target speed
- loop route
- slow down if car ahead is near
- stop if another car is too close ahead

Optional:

- choose random route at intersection
- stop briefly at a yield zone
- simple intersection lock so only one car enters a narrow conflict area at a time

### Recommended anti-collision strategy
Keep the traffic rules simple and layered:

1. **Lane constraint** — cars never leave their predefined path.
2. **Follow-distance braking** — cars compare forward sensor hits against `safe_follow_distance`.
3. **Hard stop distance** — cars fully stop if the distance is too small.
4. **Intersection gating** — optional trigger volumes or manager-owned tokens prevent two cars from entering the same conflict zone at once.

This is much easier than general avoidance and is the right level for this project.

---

## 6.3 Camera feed system

### Goal
Expose each vehicle-mounted camera as a texture for the HUD.

### Recommended implementation

Each live feed uses:

- `SubViewport`
- a `Camera3D` assigned inside that viewport
- `ViewportTexture` displayed in a `TextureRect`

### Registry pattern

Use `camera_feed_registry.gd` to expose a stable interface:

```text
get_feed("front")
get_feed("rear")
get_feed("left")
get_feed("right")
```

This keeps HUD logic independent from the vehicle internals.

---

## 6.4 UI system

The UI should not know vehicle movement details.

The UI only needs:

- speed value
- current layout mode
- references to camera textures
- optional status values

### Recommended UI data flow

```text
PlayerCar -> VehicleState -> SignalBus / direct signal -> HUDController
CameraRig -> CameraFeedRegistry -> HUDController
```

Avoid letting the HUD search deeply into the scene tree every frame.

---

## 6.5 Respawn system

Provide a simple recovery path so the demo never gets stuck.

### Reset conditions

- player presses reset key
- car flips upside down for too long
- car falls below world threshold

### Reset behavior

- zero linear velocity
- zero angular velocity
- reposition to last valid transform or start point
- restore upright rotation

Script:

- `respawn_manager.gd`

---

## 7. Suggested implementation order

## Phase 1 — bootstrap

1. Create project in Godot 4.6.2
2. Create folder structure
3. Create `main.tscn`
4. Add flat test floor
5. Add temporary box-based player car
6. Add input map

**Goal:** move something on screen.

---

## Phase 2 — vehicle controller

1. Implement `vehicle_input.gd`
2. Implement `player_car_controller.gd`
3. Tune simple forces until driving feels decent
4. Add reset vehicle hotkey
5. Add speed calculation

**Goal:** controllable and stable player vehicle.

---

## Phase 3 — camera rig

1. Attach 4 camera anchors
2. Add `SubViewport` feeds
3. Verify front/rear/left/right all move with the car
4. Tune FOV and angles

**Goal:** camera system works before UI polish.

---

## Phase 4 — HUD

1. Create HUD root
2. Add 4 camera panels
3. Connect textures from camera registry
4. Add labels
5. Add speed display
6. Add layout switch hotkey

**Goal:** the central assignment requirement is visible and solid.

---

## Phase 5 — urban block

1. Block out the **400×400 m** playable area
2. Build one compact driveable city slice with a main loop
3. Add road pieces and intersections
4. Add simple buildings from primitives
5. Add barriers so player stays in useful space

**Goal:** make the demo look intentional.

---

## Phase 6 — NPC traffic

1. Create one simple lane route
2. Create `npc_car.tscn`
3. Implement path following with look-ahead steering
4. Spawn 3 NPC cars
5. Add route loops and speed variety
6. Add simple follow-distance braking
7. Add optional intersection gate if needed

**Goal:** create traffic feeling without fragile AI.

---

## Phase 7 — cleanup and explanation

1. Add comments only where logic is non-obvious
2. Rename confusing nodes/scripts
3. Remove dead experiments
4. Write README
5. Record short demo video

**Goal:** make the project easy to review.

---

## 8. Coding conventions

## Naming

Use descriptive names.

Good:

- `player_car_controller.gd`
- `traffic_manager.gd`
- `camera_feed_registry.gd`

Avoid:

- `car2.gd`
- `temp_ui.gd`
- `logic.gd`

## One responsibility per script

Examples:

- movement logic stays in controller
- UI layout logic stays in HUD/layout controller
- feed plumbing stays in camera code

Avoid giant scripts that mix:

- movement
- camera setup
- UI
- spawning
- debug

## Signals over scene crawling

Prefer clear connections/signals rather than repeated `get_node("../../../...")` chains.

## Exported variables

Expose tuning values in inspector so behavior can be adjusted without rewriting code.

---

## 9. NPC traffic tuning values

Give `npc_car_controller.gd` a very small set of exposed parameters:

- `target_speed`
- `acceleration_rate`
- `brake_rate`
- `look_ahead_distance`
- `safe_follow_distance`
- `hard_stop_distance`
- `turn_speed_factor`

### Practical defaults
Start with conservative values:

- low to medium NPC speeds
- long enough follow distance to hide timing mistakes
- stronger braking than acceleration
- larger look-ahead distance for smoother curves

When in doubt, make traffic slower and calmer. It will look more intentional and collide less.

---

## 10. Debug strategy

Add a simple debug mode.

Useful metrics:

- speed
- steering input
- grounded state
- active layout mode
- number of NPC cars
- distance to next path point for one selected NPC
- current desired speed vs actual speed for one selected NPC

Optional debug visuals:

- draw route points
- draw forward vector
- draw respawn point

Hotkey:

- `toggle_debug`

---

## 11. MVP acceptance checklist

The project is “good enough” when all of the following are true:

- [ ] Project opens without confusion
- [ ] Main scene runs immediately
- [ ] World fits inside a clear **400×400 m** urban slice
- [ ] Player car drives in a believable way
- [ ] Car can accelerate, brake, reverse, steer, and reset
- [ ] Car does not feel like it is freely drifting during normal street driving
- [ ] World has roads, turns, and at least one intersection
- [ ] 3 to 6 NPC cars move continuously
- [ ] NPC cars do not obviously ram each other in normal lane-following cases
- [ ] Four cameras are clearly mounted on the player car
- [ ] HUD shows all four feeds live at once
- [ ] Each feed is clearly labeled Front / Rear / Left / Right
- [ ] Performance feels smooth enough on dev machine
- [ ] Code is split logically across player control, traffic, cameras, and UI
- [ ] README explains how to run and where logic lives
- [ ] Demo can be shown in 2–3 minutes without troubleshooting

---


## 12. Submission / deliverables checklist

This section mirrors the PDF submission requirements so the project backbone does not stop at implementation.

### Must prepare for submission

- [ ] Windows `.exe` build
- [ ] Full Godot project source
- [ ] README in text or PDF form
- [ ] 2–3 minute demo video
- [ ] Optional short design note / architecture note

### README must explicitly include

- engine name and exact version
- how to open the project
- which scene to run as the main scene
- any plugin / dependency / export requirement
- short architecture summary for:
  - player car
  - cameras
  - NPC cars
  - UI

### Demo video must visibly show

- manual driving of the player car
- additional moving vehicles
- simultaneous display of the four required camera feeds
- enough of the environment to show roads, turns, and intersections

### Packaging notes

- keep `main.tscn` as the obvious entry point
- keep input mappings saved in `project.godot`
- document any non-default project setting in the README
- remove dead scenes/scripts before submission

---

## 12. README skeleton

```md
# Urban Car Simulation in Godot

## Engine
Godot 4.6.2-stable

## Overview
This project is a small urban driving simulation prototype built in Godot.
It includes a player-controlled car, simple NPC traffic, four attached vehicle cameras,
and a HUD that shows all camera feeds live.
The handling is intentionally tuned for stable street-driving feel rather than drift-heavy behavior.

## Run
1. Open the project in Godot 4.6.2-stable.
2. Open `res://scenes/main/main.tscn`.
3. Confirm it is the main entry scene.
4. Run the main scene.

## Dependencies / special setup
- List any plugin, addon, or export dependency here.
- If there are no special dependencies, explicitly say so.

## Controls
- W / Up: accelerate
- S / Down: reverse
- A / Left: steer left
- D / Right: steer right
- Space: brake / handbrake
- R: reset vehicle
- Tab: switch camera layout
- F3: toggle debug

## Project structure
- `scenes/vehicles` — player and NPC vehicles
- `scenes/cameras` — vehicle camera rig
- `scenes/ui` — HUD and camera panels
- `scripts/vehicles` — driving logic
- `scripts/traffic` — NPC traffic/path logic
- `scripts/cameras` — camera feed plumbing
- `scripts/ui` — HUD logic

The submission should include the full Godot project source, not only the exported build.

## Architecture summary
- `player_car_controller.gd` handles arcade `RigidBody3D` driving behavior.
- `vehicle_camera_rig.gd` owns front/rear/left/right cameras.
- `camera_feed_registry.gd` exposes viewport textures to the HUD.
- `traffic_manager.gd` spawns and manages NPC traffic.
- `npc_car_controller.gd` follows lane paths and applies simple anti-collision speed control.
- `hud_controller.gd` binds feed textures and status labels to the UI.

## Notes
This project intentionally favors a small, understandable architecture over advanced vehicle realism.
The controller is tuned to satisfy the assignment's controllable-car requirement with a stable non-drifty feel, while traffic, cameras, and UI are kept modular and easy to review.
```

---

## 13. First playable milestone

Aim for this exact vertical slice first:

1. One rectangular test map
2. One controllable box-car
3. Four cameras attached and working
4. One HUD showing all four feeds
5. One NPC car looping a square path
6. NPC forward sensor slows or stops behind a blocked target

Do not build beyond this until it works end to end.

---

## 14. Recommended next files to create immediately

Create these first:

```text
res://scenes/main/main.tscn
res://scenes/vehicles/player_car.tscn
res://scenes/vehicles/npc_car.tscn
res://scenes/cameras/vehicle_camera_rig.tscn
res://scenes/ui/hud.tscn
res://scripts/vehicles/player_car_controller.gd
res://scripts/vehicles/npc_car_controller.gd
res://scripts/cameras/vehicle_camera_rig.gd
res://scripts/ui/hud_controller.gd
res://scripts/traffic/traffic_manager.gd
```

---

## 15. Final advice

Keep the project intentionally small.

A clean, stable, understandable project with:

- one good player car
- one small urban block
- a few moving NPC cars with simple lane-following and spacing
- four working camera feeds
- a readable codebase

is much better than a more ambitious project that is half-broken.

The main value of this backbone is not only to finish the assignment, but to help you build something you can explain with confidence.

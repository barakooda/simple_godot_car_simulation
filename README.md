# Urban Car Simulation in Godot

## Engine
Godot 4.6.2-stable

## Overview
This project is a compact urban driving simulation backbone built in Godot.
It includes a player-controlled car, simple NPC traffic, four attached vehicle cameras,
and a HUD that displays all camera feeds live.

The architecture is intentionally modular and beginner-friendly:
- player vehicle control
- NPC traffic flow
- camera feed registry
- HUD layout and binding

## Run
1. Open this folder in Godot 4.6.2-stable.
2. Open `res://scenes/main/main.tscn`.
3. Confirm it is the main scene.
4. Run the project.

## Controls
- `W` / `Up`: accelerate
- `S` / `Down`: reverse
- `A` / `Left`: steer left
- `D` / `Right`: steer right
- `Space`: brake / handbrake
- `R`: reset vehicle
- `Tab`: switch camera layout
- `F3`: toggle debug
- `Esc`: quit

## Project structure
- `scenes/vehicles`: player and NPC scenes
- `scenes/cameras`: camera rig scene
- `scenes/ui`: HUD and panel scenes
- `scripts/vehicles`: movement and state scripts
- `scripts/traffic`: traffic and path logic
- `scripts/cameras`: feed plumbing
- `scripts/ui`: UI control scripts

## Architecture summary
- `player_car_controller.gd` applies arcade-style `RigidBody3D` driving logic.
- `vehicle_camera_rig.gd` owns the Front/Rear/Left/Right mounted cameras.
- `camera_feed_registry.gd` exposes camera textures by stable feed id.
- `traffic_manager.gd` spawns and manages NPC route followers.
- `npc_car_controller.gd` follows lane paths and performs simple spacing-based braking.
- `hud_controller.gd` binds camera feeds and speed data to HUD elements.

## Dependencies
No plugins or external addons are required for this backbone.

## Notes
This is a practical scaffold designed to be easy to extend. It prioritizes clarity and iteration speed over full vehicle realism.

# Repository Guidelines

## Project Structure & Module Organization

This repository is a Minecraft resource pack named `Waypoint Pack`.

- `pack.mcmeta` defines pack metadata and supported pack format.
- `assets/minecraft/items/leather_horse_armor.json` maps `custom_model_data` values to waypoint item models.
- `assets/minecraft/atlases/blocks.json` exposes the `walmart:shaders/*` texture directory to the atlas.
- `assets/minecraft/shaders/core/` contains core shader overrides. Treat these as version-sensitive Minecraft internals.
- `assets/walmart/models/shaders/` contains Blockbench-style item model JSON files.
- `assets/walmart/textures/shaders/` contains PNG textures referenced by the models.

Keep model paths and texture paths aligned. For example, model `walmart:shaders/waypoint_circle` should resolve to `assets/walmart/models/shaders/waypoint_circle.json`, and its texture should resolve under `assets/walmart/textures/shaders/`.

## Build, Test, and Development Commands

There is no Gradle, npm, or Make build system in this pack. Use validation commands before committing:

- `python3 -m json.tool pack.mcmeta >/dev/null` checks the root metadata JSON.
- `find assets -name '*.json' -print0 | xargs -0 -n1 python3 -m json.tool >/dev/null` validates all JSON assets.
- `zip -r waypoint-pack.zip pack.mcmeta assets` creates a distributable resource-pack archive.

For in-game testing, copy or symlink the repository folder into `.minecraft/resourcepacks/`, enable it, then reload resources with `F3+T`.

## Coding Style & Naming Conventions

Use lowercase snake_case for asset names, matching the existing `waypoint_*` pattern. Keep namespace paths explicit: Minecraft overrides belong in `assets/minecraft`, and project assets belong in `assets/walmart`.

JSON in this repo uses both two-space indentation and Blockbench tab indentation. Preserve the style of the file being edited. Do not reformat generated Blockbench model files unless the model data is intentionally changing.

## Testing Guidelines

Validate JSON syntax after every edit. When changing `leather_horse_armor.json`, test each affected `custom_model_data` threshold in game with an `item_display` or held item. Confirm missing textures do not appear and that shader-related changes render correctly on the target Minecraft version.

## Commit & Pull Request Guidelines

The current Git history is minimal, so use short imperative commit messages, for example `Add waypoint floor model` or `Fix leather horse armor dispatch`.

Pull requests should include a brief summary, changed custom model data values, target Minecraft pack format, and screenshots or short clips for visual changes. Mention any shader edits separately because they are more likely to break across Minecraft versions.

# Fix for the ArtCraft Suite on macOS Sequoia (OCLP / legacy GPUs)

This fix resolves the crash (`SIGABRT` / `abort trap: 6` / `Parent device is lost`) that occurs when launching **any app from the ArtCraft suite** (`FilmCraft.app`, `ArtCraft Launcher.app`, `PhotoCraft.app`, etc.) on Macs not officially supported by macOS 15, running **macOS Sequoia** via **OpenCore Legacy Patcher (OCLP)** (e.g. MacBooks with Intel Iris Pro or NVIDIA GeForce GT 750M / Kepler GPUs).

---

## Root cause

The ArtCraft apps are written in Rust and use the `wgpu` graphics engine for their UIs (`egui`). On macOS 15 (Sequoia), `wgpu` assumes support for the **Metal 3.2** standard (`-std=metal3.2`) by default. On legacy GPUs with OCLP-patched drivers, the Metal compiler rejects that standard, causing the app to abort immediately when initializing the graphics window (`egui_pipeline` or `ComputePipeline`).

---

## What this script does

It scans `/Applications` and patches **every ArtCraft suite app it finds** (anything with a bundle id starting with `ai.storyteller.` or a name ending in `Craft.app`). For each one it:

1. **Clears quarantine:** removes the `com.apple.quarantine` attributes Gatekeeper assigns to web downloads.
2. **Injects `SYSTEM_VERSION_COMPAT=1`:** adds the `LSEnvironment` key to `Contents/Info.plist`, telling macOS to report a compatible API version instead of requesting Metal 3.2.
3. **Re-signs the bundle ad-hoc:** so AMFI doesn't kill the process due to the modified `Info.plist`.
4. **Refreshes LaunchServices:** notifies the system to register the changes immediately.

---

## How to use it after an update or fresh install

Whenever you download a new version — or a new ArtCraft app — and copy it into `/Applications`, just run in your terminal:

```bash
cd fixes-crash-apps/fix-filmcraft
./fix-filmcraft.sh
```

Or from the repository root:

```bash
./fix-filmcraft/fix-filmcraft.sh
```

---

## Optional: keep the command always at hand

If you want to run `fix-filmcraft` from anywhere:

```bash
cp fix-filmcraft.sh ~/.local/bin/fix-filmcraft
```

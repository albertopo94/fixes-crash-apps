# Fix for Godot on macOS Sequoia (OCLP / legacy GPUs)

This fix resolves the problem of **subwindows, popups and dialogs rendering completely black** when opening or using **Godot 4** on Macs with legacy graphics (Intel Iris Pro / NVIDIA Kepler) running **macOS Sequoia** via **OpenCore Legacy Patcher (OCLP)**.

---

## Root cause

1. **Multi-window composition bug on macOS Sequoia + OCLP:**
   By default, Godot 4 tries to open each dialog ("Import", "Scan", "New Project", settings, or floating menus) as a **separate native window (`NSWindow`)**. The macOS window compositor fails to synchronize the secondary OpenGL contexts on legacy GPUs, causing the secondary window to render as a solid black rectangle.
2. **MoltenVK (Metal 3.2) incompatibility:**
   When trying to initialize Vulkan/MoltenVK, the engine requests Metal standards that pre-2016 GPUs don't support.

---

## What this script does

1. **Injects `--single-window`:** configures a wrapper inside `Godot.app/Contents/MacOS/Godot` so that the Project Manager and the Editor always launch with `--single-window`, forcing all dialogs to be drawn embedded in the main window's canvas and never create black secondary windows.
2. **Enables `single_window_mode` in the user settings:** updates the `editor_settings-*.tres` files in `~/Library/Application Support/Godot/`.
3. **Injects `SYSTEM_VERSION_COMPAT=1`:** avoids Metal 3.2 shader validation errors in MoltenVK.
4. **Removes Gatekeeper quarantine and re-signs ad-hoc:** ensures macOS opens the application without warnings or AMFI blocks.

---

## How to use it after updating Godot

Whenever you download a new version of Godot (for example Godot 4.8 or a maintenance update) and replace it in `/Applications/Godot.app`:

### Option A (from the terminal, anywhere):
```bash
fix-godot
```

### Option B (from this folder):
```bash
cd "/Users/albertmac11/Downloads/fixes-crash-apps/fix-godot"
./fix-godot.sh
```

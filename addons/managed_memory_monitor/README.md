# Managed Memory Monitor for Godot
A managed memory monitor add-on for Godot 4.x projects.

**Displays managed memory performance information in a Godot project during gameplay.**
Can be used when running from the editor and in exported projects.

## Features

- Features compact and full display modes, with the compact mode only displaying Garbage Collections.
- Works with the Forward+, Mobile and Compatibility rendering methods.
- Works with 2D and 3D projects.
- Works when running the project from the editor, but also in exported projects (debug and release).

## Why use this monitor?

- Analyize memory allocations and garbage collections generated by managed code (C#).

## Installation

### Using the Asset Library

- Open the Godot editor.
- Navigate to the **AssetLib** tab at the top of the editor and search for
  "managed memory monitor".
- Install the
  [*Managed Memory Monitor*](https://godotengine.org/asset-library/asset/TODO_FIX_ME)
  plugin. Keep all files checked during installation.
- In the editor, open **Project > Project Settings**, go to **Plugins**
  and enable the **Managed Memory Monitor** plugin.

### Manual installation

Manual installation lets you use pre-release versions of this add-on by
following its `main` branch.

- Clone this Git repository:

```bash
git clone https://github.com/PumpkinPaul/godot-managed-memory-monitor.git
```

## Usage

Press <kbd>F4</kbd> while the project is running. This cycles between no memory monitor, a compact monitor (only Garbage Collections are visible) and a full monitor.

The key to cycle the debug menu is set to <kbd>F4</kbd> by default. This can be
changed by setting the `cycle_managed_memory_monitor` action in the Input Map to a different
key. This action is not created by the plugin in the editor, so you will have to
create it in the Project Settings if you wish to override the key.

To toggle the debug menu from code, use:

- `ManagedMemoryMonitor.style = ManagedMemoryMonitor.DisplayStyle.NONE` to hide the monitor.
- `ManagedMemoryMonitor.style = ManagedMemoryMonitor.DisplayStyle.VISIBLE_COMPACT` to show the compact monitor.
- `ManagedMemoryMonitor.style = ManagedMemoryMonitor.DisplayStyle.VISIBLE_DETAILED` to show the detailed monitor.

## License

Copyright © 2023-present Paul Cunningham and contributors

Unless otherwise specified, files in this repository are licensed under the MIT license. 
See [LICENSE](LICENSE) for more information.

## Credits

### Inspiration:

- [Debug Menu](https://github.com/godot-extended-libraries/godot-debug-menu) by Hugo Locurcio and contributors


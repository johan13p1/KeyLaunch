# KeyLaunch

KeyLaunch is a native macOS app for remapping function keys and launching apps, websites, or system functions with custom F-key shortcuts.

**Website:** [keylaunch.org](https://keylaunch.org/)

## Features

- Remap function keys using macOS `hidutil`
- Open apps and websites with an F-key
- Multiple profiles and app-specific mappings
- Custom presets and importing existing mappings
- Optional background launch via a LaunchAgent
- German and English interface
- App updates through Sparkle

All features are available without restrictions. There is no account and no paid version.

## Technology

- Swift and SwiftUI
- AppKit and the macOS Accessibility API
- `hidutil` and `launchd`
- Sparkle

Mappings are stored locally. KeyLaunch requires macOS Accessibility permission for global keyboard shortcuts.

## Build locally

Requirements: Xcode and macOS 15.6 or later.

1. Clone the repository.
2. Open `KeyLaunch.xcodeproj` and let the Swift package dependency (Sparkle) resolve.
3. Run the **KeyLaunch** scheme.

For your own build, signing must be set to your own developer identity.

## Structure

```text
KeyLaunch/
├── App/            App entry point and lifecycle
├── Models/         Keys, actions, profiles, and presets
├── Services/       hidutil, LaunchAgent, shortcuts, permissions, updates
├── ViewModels/     Central UI and profile management
├── Views/          Main window, settings, and onboarding
├── Localization/   German and English text
└── Resources/      App icon and assets
```

Key files:

| File | Purpose |
| --- | --- |
| `ViewModels/KeyLaunchViewModel.swift` | UI state, profiles, and keybindings |
| `Services/KeyRemappingService.swift` | `hidutil` calls, LaunchAgent, and persistence |
| `Services/AppShortcutMonitor.swift` | Global app and website shortcuts |
| `Services/PermissionCenter.swift` | macOS permissions |
| `Services/UpdateManager.swift` | Sparkle updates |

## Status

An independent learning and portfolio project that applies key mappings using macOS Accessibility permission.

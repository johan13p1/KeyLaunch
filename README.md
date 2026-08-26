# KeyLaunch

KeyLaunch ist eine native macOS-App zum Umbelegen der Funktionstasten und zum Starten von Apps, Websites oder Systemfunktionen über eigene F-Key-Shortcuts.

**Website:** [keylaunch.org](https://keylaunch.org/)

## Funktionen

- Funktionstasten über macOS `hidutil` neu belegen
- Apps und Websites per F-Taste öffnen
- mehrere Profile und appabhängige Belegungen
- eigene Presets sowie Import der vorhandenen Belegung
- optionaler Hintergrundstart über einen LaunchAgent
- deutsch- und englischsprachige Oberfläche
- App-Updates über Sparkle

Alle Funktionen sind ohne Einschränkung nutzbar. Es gibt weder einen Account noch eine Bezahlversion.

## Technik

- Swift und SwiftUI
- AppKit und macOS Accessibility API
- `hidutil` und `launchd`
- Sparkle

Die Belegungen werden lokal gespeichert. Für globale Tastenkürzel benötigt KeyLaunch die Bedienungshilfen-Berechtigung von macOS.

## Lokal bauen

Voraussetzungen: Xcode und macOS 15.6 oder neuer.

1. Das Repository klonen.
2. `KeyLaunch.xcodeproj` öffnen und die Swift-Package-Abhängigkeit (Sparkle) auflösen lassen.
3. Das Scheme **KeyLaunch** starten.

Für einen eigenen Build muss die Signierung auf die eigene Entwicklerkennung gestellt werden.

## Aufbau

```text
KeyLaunch/
├── App/            App-Einstieg und Lebenszyklus
├── Models/         Tasten, Aktionen, Profile und Presets
├── Services/       hidutil, LaunchAgent, Shortcuts, Berechtigungen, Updates
├── ViewModels/     zentrale UI- und Profilsteuerung
├── Views/          Hauptfenster, Einstellungen und Ersteinrichtung
├── Localization/   deutsche und englische Texte
└── Resources/      App-Icon und Assets
```

Zentrale Dateien:

| Datei | Aufgabe |
| --- | --- |
| `ViewModels/KeyLaunchViewModel.swift` | Zustand der Oberfläche, Profile und Keybinds |
| `Services/KeyRemappingService.swift` | `hidutil`-Aufrufe, LaunchAgent und Persistenz |
| `Services/AppShortcutMonitor.swift` | globale App- und Website-Shortcuts |
| `Services/PermissionCenter.swift` | macOS-Berechtigungen |
| `Services/UpdateManager.swift` | Sparkle-Updates |

## Status

Eigenständiges Lern- und Portfolio-Projekt, das unter der macOS-Bedienungshilfen-Berechtigung Tastenbelegungen setzt.

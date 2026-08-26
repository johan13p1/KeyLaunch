# KeyLaunch

KeyLaunch ist eine native macOS-App zum Umbelegen der Funktionstasten und zum Starten von Apps, Websites oder Tastenkombinationen über eigene F-Key-Shortcuts.

## Funktionen

- Funktionstasten über macOS `hidutil` neu belegen
- Apps und Websites per F-Taste öffnen
- mehrere Profile und appabhängige Belegungen
- eigene Presets sowie Import der vorhandenen Belegung
- optionaler Hintergrundstart über einen LaunchAgent
- deutsch- und englischsprachige Oberfläche
- Account- und Lizenzfunktionen über Firebase
- App-Updates über Sparkle

## Technik

- Swift und SwiftUI
- AppKit und macOS Accessibility API
- `hidutil` und `launchd`
- Firebase Authentication
- Sparkle

Die Belegungen werden lokal gespeichert. Für globale Tastenkürzel benötigt KeyLaunch die Bedienungshilfen-Berechtigung von macOS.

## Lokal bauen

Voraussetzungen: Xcode und macOS 15.6 oder neuer.

1. Das Repository klonen.
2. Eine eigene Firebase-iOS/macOS-App anlegen und deren `GoogleService-Info.plist` nach `KeyLaunch/` kopieren.
3. `KeyLaunch.xcodeproj` öffnen und die Swift-Package-Abhängigkeiten auflösen lassen.
4. Das Scheme **KeyLaunch** starten.

Die Firebase-Konfiguration wird absichtlich nicht versioniert. Die Kernfunktionen zur Tastenbelegung liegen vollständig im Repository.

## Aufbau

```text
KeyLaunch/
├── KeyLaunchViewModel.swift       zentrale UI- und Profilsteuerung
├── KeyRemappingService.swift     hidutil-, LaunchAgent- und Persistenzlogik
├── AppShortcutMonitor.swift      globale App-Shortcuts
├── PermissionCenter.swift        macOS-Berechtigungen
├── AccountManager.swift          Firebase-Accountfunktionen
├── UpdateManager.swift           Sparkle-Updates
└── AppSettingsView.swift         Einstellungen, Profile und Account
```

## Status

Eigenständiges Lern- und Portfolio-Projekt. Release-Dienste und Signierung müssen für einen eigenen Build mit eigenen Kennungen konfiguriert werden.

import Foundation

struct KeyLaunchPreset: Identifiable, Sendable {
    let id: String
    let name: String
    let detail: String
    let mappings: [KeyMapping]

    static let all: [KeyLaunchPreset] = [
        KeyLaunchPreset(
            id: "keyboard-light-f3-f4",
            name: "Keyboard Light F3 & F4",
            detail: "Use F3 and F4 for keyboard backlight brightness.",
            mappings: makeSystemMappings([
                (2, .keyboardBrightnessDown),
                (3, .keyboardBrightnessUp)
            ])
        ),
        KeyLaunchPreset(
            id: "keyboard-light-f5-f6",
            name: "Keyboard Light F5 & F6",
            detail: "Use F5 and F6 for keyboard backlight brightness.",
            mappings: makeSystemMappings([
                (4, .keyboardBrightnessDown),
                (5, .keyboardBrightnessUp)
            ])
        ),
        KeyLaunchPreset(
            id: "spotify-f6",
            name: "Spotify on F6",
            detail: "Open Spotify with F6.",
            mappings: [
                makeAppMapping(
                    keyIndex: 5,
                    displayName: "Spotify",
                    path: "/Applications/Spotify.app",
                    bundleIdentifier: "com.spotify.client"
                )
            ].compactMap { $0 }
        ),
        KeyLaunchPreset(
            id: "music-f6",
            name: "Music on F6",
            detail: "Open Apple Music with F6.",
            mappings: [
                makeAppMapping(
                    keyIndex: 5,
                    displayName: "Music",
                    path: "/System/Applications/Music.app",
                    bundleIdentifier: "com.apple.Music"
                )
            ].compactMap { $0 }
        ),
        KeyLaunchPreset(
            id: "notes-f6",
            name: "Notes on F6",
            detail: "Open Notes with F6.",
            mappings: [
                makeAppMapping(
                    keyIndex: 5,
                    displayName: "Notes",
                    path: "/System/Applications/Notes.app",
                    bundleIdentifier: "com.apple.Notes"
                )
            ].compactMap { $0 }
        ),
        KeyLaunchPreset(
            id: "terminal-f6",
            name: "Terminal on F6",
            detail: "Open Terminal with F6.",
            mappings: [
                makeAppMapping(
                    keyIndex: 5,
                    displayName: "Terminal",
                    path: "/System/Applications/Utilities/Terminal.app",
                    bundleIdentifier: "com.apple.Terminal"
                )
            ].compactMap { $0 }
        )
    ]

    private static func makeSystemMappings(_ entries: [(Int, RemapAction)]) -> [KeyMapping] {
        entries.compactMap { index, action in
            guard SourceKey.allKeys.indices.contains(index) else {
                return nil
            }

            return KeyMapping(
                source: SourceKey.allKeys[index],
                action: .systemFunction(action)
            )
        }
    }

    private static func makeAppMapping(
        keyIndex: Int,
        displayName: String,
        path: String,
        bundleIdentifier: String
    ) -> KeyMapping? {
        guard SourceKey.allKeys.indices.contains(keyIndex) else {
            return nil
        }

        return KeyMapping(
            source: SourceKey.allKeys[keyIndex],
            action: .openApplication(
                ApplicationLaunchTarget(
                    displayName: displayName,
                    url: URL(fileURLWithPath: path),
                    bundleIdentifier: bundleIdentifier
                )
            )
        )
    }
}

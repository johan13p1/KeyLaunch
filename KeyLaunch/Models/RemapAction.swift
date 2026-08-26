import Foundation

enum RemapAction: String, CaseIterable, Identifiable, Sendable {
    case displayBrightnessDown
    case displayBrightnessUp
    case keyboardBrightnessDown
    case keyboardBrightnessUp
    case missionControl
    case spotlight
    case dictation
    case doNotDisturb
    case previousTrack
    case playPause
    case nextTrack
    case mute
    case volumeDown
    case volumeUp

    nonisolated var id: String { rawValue }

    var title: String {
        title(in: .english)
    }

    func title(in language: AppLanguage) -> String {
        switch self {
        case .displayBrightnessDown:
            return language == .english ? "Display Brightness Down" : "Bildschirm dunkler"
        case .displayBrightnessUp:
            return language == .english ? "Display Brightness Up" : "Bildschirm heller"
        case .keyboardBrightnessDown:
            return language == .english ? "Keyboard Brightness Down" : "Tastatur dunkler"
        case .keyboardBrightnessUp:
            return language == .english ? "Keyboard Brightness Up" : "Tastatur heller"
        case .missionControl:
            return "Mission Control"
        case .spotlight:
            return "Spotlight"
        case .dictation:
            return language == .english ? "Dictation" : "Diktat"
        case .doNotDisturb:
            return language == .english ? "Do Not Disturb" : "Nicht stören"
        case .previousTrack:
            return language == .english ? "Previous Track" : "Vorheriger Titel"
        case .playPause:
            return language == .english ? "Play/Pause" : "Wiedergabe/Pause"
        case .nextTrack:
            return language == .english ? "Next Track" : "Nächster Titel"
        case .mute:
            return language == .english ? "Mute" : "Ton aus"
        case .volumeDown:
            return language == .english ? "Volume Down" : "Lautstärke leiser"
        case .volumeUp:
            return language == .english ? "Volume Up" : "Lautstärke lauter"
        }
    }

    var detail: String {
        detail(in: .english)
    }

    func detail(in language: AppLanguage) -> String {
        switch self {
        case .displayBrightnessDown:
            return language == .english ? "Decreases the display brightness." : "Verringert die Helligkeit des Bildschirms."
        case .displayBrightnessUp:
            return language == .english ? "Increases the display brightness." : "Erhöht die Helligkeit des Bildschirms."
        case .keyboardBrightnessDown:
            return language == .english ? "Decreases the keyboard backlight brightness." : "Verringert die Helligkeit der Tastaturbeleuchtung."
        case .keyboardBrightnessUp:
            return language == .english ? "Increases the keyboard backlight brightness." : "Erhöht die Helligkeit der Tastaturbeleuchtung."
        case .missionControl:
            return language == .english ? "Opens the overview of all windows." : "Öffnet die Übersicht aller Fenster."
        case .spotlight:
            return language == .english ? "Opens system search." : "Öffnet die Systemsuche."
        case .dictation:
            return language == .english ? "Starts voice input." : "Startet die Spracheingabe."
        case .doNotDisturb:
            return language == .english ? "Quickly toggles Focus mode." : "Schaltet den Fokusmodus schnell um."
        case .previousTrack:
            return language == .english ? "Skips to the previous track." : "Springt zum vorherigen Titel."
        case .playPause:
            return language == .english ? "Starts or pauses playback." : "Startet oder pausiert die Wiedergabe."
        case .nextTrack:
            return language == .english ? "Skips to the next track." : "Springt zum nächsten Titel."
        case .mute:
            return language == .english ? "Mutes the sound." : "Schaltet den Ton stumm."
        case .volumeDown:
            return language == .english ? "Decreases the volume." : "Verringert die Lautstärke."
        case .volumeUp:
            return language == .english ? "Increases the volume." : "Erhöht die Lautstärke."
        }
    }

    var symbolName: String {
        switch self {
        case .displayBrightnessDown:
            return "sun.min.fill"
        case .displayBrightnessUp:
            return "sun.max.fill"
        case .keyboardBrightnessDown:
            return "sun.min"
        case .keyboardBrightnessUp:
            return "sun.max"
        case .missionControl:
            return "square.3.layers.3d"
        case .spotlight:
            return "magnifyingglass"
        case .dictation:
            return "mic"
        case .doNotDisturb:
            return "moon"
        case .previousTrack:
            return "backward.fill"
        case .playPause:
            return "playpause.fill"
        case .nextTrack:
            return "forward.fill"
        case .mute:
            return "speaker.slash.fill"
        case .volumeDown:
            return "speaker.wave.1.fill"
        case .volumeUp:
            return "speaker.wave.3.fill"
        }
    }

    var systemToken: String {
        switch self {
        case .displayBrightnessDown:
            return "display_brightness_down"
        case .displayBrightnessUp:
            return "display_brightness_up"
        case .keyboardBrightnessDown:
            return "keyboard_brightness_down"
        case .keyboardBrightnessUp:
            return "keyboard_brightness_up"
        case .missionControl:
            return "mission_control"
        case .spotlight:
            return "spotlight"
        case .dictation:
            return "dictation"
        case .doNotDisturb:
            return "do_not_disturb"
        case .previousTrack:
            return "previous_track"
        case .playPause:
            return "play_pause"
        case .nextTrack:
            return "next_track"
        case .mute:
            return "mute"
        case .volumeDown:
            return "volume_down"
        case .volumeUp:
            return "volume_up"
        }
    }

    nonisolated var destinationUsageValue: UInt64 {
        canonicalDestinationUsageValue
    }

    nonisolated static func from(destinationUsageValue: UInt64) -> RemapAction? {
        resolve(destinationUsageValue: destinationUsageValue)?.action
    }

    nonisolated static func resolve(destinationUsageValue: UInt64) -> Resolution? {
        for action in allCases {
            if destinationUsageValue == action.canonicalDestinationUsageValue {
                return Resolution(action: action, requiresMigration: false)
            }

            if action.legacyDestinationUsageValues.contains(destinationUsageValue) {
                return Resolution(action: action, requiresMigration: true)
            }
        }

        return nil
    }

    nonisolated private var canonicalDestinationUsageValue: UInt64 {
        switch self {
        case .displayBrightnessDown:
            return 0xFF00000005
        case .displayBrightnessUp:
            return 0xFF00000004
        case .keyboardBrightnessDown:
            return 0xFF00000009
        case .keyboardBrightnessUp:
            return 0xFF00000008
        case .missionControl:
            return 0xFF0100000010
        case .spotlight:
            return 0xC00000221
        case .dictation:
            return 0xC000000CF
        case .doNotDisturb:
            return 0x10000009B
        case .previousTrack:
            return 0xC000000B4
        case .playPause:
            return 0xC000000CD
        case .nextTrack:
            return 0xC000000B3
        case .mute:
            return 0xC000000E2
        case .volumeDown:
            return 0xC000000EA
        case .volumeUp:
            return 0xC000000E9
        }
    }

    nonisolated private var legacyDestinationUsageValues: [UInt64] {
        switch self {
        case .displayBrightnessDown:
            return [0xC00000070, 0xFF0100000021]
        case .displayBrightnessUp:
            return [0xC0000006F, 0xFF0100000020]
        case .keyboardBrightnessDown:
            return [0xFF00000008, 0xC0000007A]
        case .keyboardBrightnessUp:
            return [0xFF00000009, 0xC00000079]
        case .previousTrack:
            return [0xC000000B6]
        case .nextTrack:
            return [0xC000000B5]
        default:
            return []
        }
    }

    struct Resolution: Sendable {
        let action: RemapAction
        let requiresMigration: Bool
    }
}

import Foundation

struct SourceKey: Identifiable, Equatable, Sendable {
    let displayName: String
    let remapSourceValue: UInt64
    let sortOrder: Int

    nonisolated var id: UInt64 { remapSourceValue }

    nonisolated static let allKeys: [SourceKey] = TopRowKey.allCases.enumerated().map { index, key in
        SourceKey(
            displayName: key.displayName,
            remapSourceValue: key.remapSourceValue,
            sortOrder: 100 + index
        )
    }

    nonisolated static func from(remapSourceValue: UInt64) -> SourceKey? {
        if let key = allKeys.first(where: { $0.remapSourceValue == remapSourceValue }) {
            return key
        }

        return legacyTopRowSourceReplacements[remapSourceValue].flatMap { replacementValue in
            allKeys.first { $0.remapSourceValue == replacementValue }
        }
    }

    nonisolated static func from(functionKeyCode: UInt16) -> SourceKey? {
        functionKeyCodeReplacements[functionKeyCode].flatMap { sourceValue in
            allKeys.first { $0.remapSourceValue == sourceValue }
        }
    }

    nonisolated static func from(appShortcutTriggerKeyCode: UInt16) -> SourceKey? {
        appShortcutTriggerKeyCodes.first { $0.value == appShortcutTriggerKeyCode }.flatMap { entry in
            allKeys.first { $0.remapSourceValue == entry.key }
        }
    }

    nonisolated var appShortcutTriggerUsageValue: UInt64? {
        Self.appShortcutTriggerUsageValues[remapSourceValue]
    }

    nonisolated var appShortcutTriggerKeyCode: UInt16? {
        Self.appShortcutTriggerKeyCodes[remapSourceValue]
    }

    nonisolated static func from(systemKeyType: Int) -> SourceKey? {
        systemKeyTypeReplacements[systemKeyType].flatMap { sourceValue in
            allKeys.first { $0.remapSourceValue == sourceValue }
        }
    }

    nonisolated private static let legacyTopRowSourceReplacements: [UInt64: UInt64] = [
        0xC00000070: 0xFF00000005,
        0xC0000006F: 0xFF00000004,
        0xC000000B6: 0xC000000B4,
        0xC000000B5: 0xC000000B3
    ]

    nonisolated private static let functionKeyCodeReplacements: [UInt16: UInt64] = [
        122: 0xFF00000005,
        120: 0xFF00000004,
        99: 0xFF0100000010,
        118: 0xC00000221,
        96: 0xC000000CF,
        97: 0x10000009B,
        98: 0xC000000B4,
        100: 0xC000000CD,
        101: 0xC000000B3,
        109: 0xC000000E2,
        103: 0xC000000EA,
        111: 0xC000000E9
    ]

    nonisolated private static let systemKeyTypeReplacements: [Int: UInt64] = [
        0: 0xC000000E9,
        1: 0xC000000EA,
        2: 0xFF00000004,
        3: 0xFF00000005,
        7: 0xC000000E2,
        13: 0xC000000CF,
        16: 0xC000000CD,
        17: 0xC000000B3,
        18: 0xC000000B4,
        21: 0xFF00000008,
        22: 0xFF00000009
    ]

    nonisolated private static let appShortcutTriggerKeyCodes: [UInt64: UInt16] = [
        0xFF00000005: 0x69,
        0xFF00000004: 0x6B,
        0xFF0100000010: 0x71,
        0xC00000221: 0x6A,
        0xC000000CF: 0x40,
        0x10000009B: 0x4F,
        0xC000000B4: 0x50,
        0xC000000CD: 0x5A
    ]

    nonisolated private static let appShortcutTriggerUsageValues: [UInt64: UInt64] = [
        0xFF00000005: 0x700000068,
        0xFF00000004: 0x700000069,
        0xFF0100000010: 0x70000006A,
        0xC00000221: 0x70000006B,
        0xC000000CF: 0x70000006C,
        0x10000009B: 0x70000006D,
        0xC000000B4: 0x70000006E,
        0xC000000CD: 0x70000006F
    ]

}

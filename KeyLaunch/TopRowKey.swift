import Foundation

struct TopRowKey: Identifiable, Equatable, Sendable {
    let displayName: String
    let remapSourceValue: UInt64
    nonisolated var id: UInt64 { remapSourceValue }

    nonisolated private static let supportedKeys: [TopRowKey] = [
        TopRowKey(displayName: "F1", remapSourceValue: 0xFF00000005),
        TopRowKey(displayName: "F2", remapSourceValue: 0xFF00000004),
        TopRowKey(displayName: "F3", remapSourceValue: 0xFF0100000010),
        TopRowKey(displayName: "F4", remapSourceValue: 0xC00000221),
        TopRowKey(displayName: "F5", remapSourceValue: 0xC000000CF),
        TopRowKey(displayName: "F6", remapSourceValue: 0x10000009B),
        TopRowKey(displayName: "F7", remapSourceValue: 0xC000000B4),
        TopRowKey(displayName: "F8", remapSourceValue: 0xC000000CD),
        TopRowKey(displayName: "F9", remapSourceValue: 0xC000000B3),
        TopRowKey(displayName: "F10", remapSourceValue: 0xC000000E2),
        TopRowKey(displayName: "F11", remapSourceValue: 0xC000000EA),
        TopRowKey(displayName: "F12", remapSourceValue: 0xC000000E9)
    ]

    nonisolated static let allCases: [TopRowKey] = supportedKeys

    nonisolated static func from(remapSourceValue: UInt64) -> TopRowKey? {
        supportedKeys.first { $0.remapSourceValue == remapSourceValue }
    }
}

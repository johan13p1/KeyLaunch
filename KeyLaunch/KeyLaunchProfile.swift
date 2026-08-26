import Foundation

struct KeyLaunchProfile: Identifiable, Equatable, Sendable {
    let id: UUID
    var name: String
    var mappings: [KeyMapping]
    var assignedApplications: [ApplicationLaunchTarget]
    var isDefault: Bool

    nonisolated init(
        id: UUID = UUID(),
        name: String,
        mappings: [KeyMapping] = [],
        assignedApplications: [ApplicationLaunchTarget] = [],
        isDefault: Bool = false
    ) {
        self.id = id
        self.name = name
        self.mappings = mappings
        self.assignedApplications = assignedApplications
        self.isDefault = isDefault
    }
}

struct KeyLaunchProfileState: Equatable, Sendable {
    var profiles: [KeyLaunchProfile]
    var activeProfileID: UUID

    nonisolated var activeProfile: KeyLaunchProfile? {
        profiles.first { $0.id == activeProfileID }
    }

    nonisolated var activeMappings: [KeyMapping] {
        activeProfile?.mappings ?? []
    }

    nonisolated func mappings(for profileID: UUID) -> [KeyMapping] {
        profiles.first { $0.id == profileID }?.mappings ?? activeMappings
    }

    nonisolated func normalized() -> KeyLaunchProfileState {
        let normalizedProfiles = profiles.isEmpty
            ? [Self.defaultProfile()]
            : profiles

        let activeID = normalizedProfiles.contains { $0.id == activeProfileID }
            ? activeProfileID
            : normalizedProfiles[0].id

        return KeyLaunchProfileState(
            profiles: normalizedProfiles,
            activeProfileID: activeID
        )
    }

    nonisolated static func defaultProfile(mappings: [KeyMapping] = []) -> KeyLaunchProfile {
        KeyLaunchProfile(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            name: "Default",
            mappings: mappings,
            isDefault: true
        )
    }
}

import Foundation

struct KeyRemappingService {
    nonisolated static let shared = KeyRemappingService()

    private struct MappingLoadResult {
        let mappings: [KeyMapping]
        let shouldRewriteLaunchAgent: Bool
    }

    private struct ProfileLoadResult {
        let state: KeyLaunchProfileState
        let shouldRewriteLaunchAgent: Bool
    }

    private let label = "com.local.KeyRemapping"
    private let launchAgentFileName = "com.local.keyRemapping.plist"
    private let appShortcutLaunchAgentLabel = "com.local.KeyLaunch.AppShortcuts"
    private let appShortcutLaunchAgentFileName = "com.local.KeyLaunch.AppShortcuts.plist"
    private let applicationSupportFolderName = "KeyLaunch"
    private let legacyApplicationSupportFolderNames = [
        "KeySwitch"
    ]
    private let mappingsFileName = "mappings-v1.json"
    private let profilesFileName = "profiles-v1.json"
    private let legacyPayloadFileName = "user-key-mapping.json"

    private let legacyLaunchAgentFileNames = [
        "com.local.KeySwitch.AppShortcuts.plist",
        "com.johan.keylaunch-helper.plist",
        "com.johan.keyswitch-helper.plist"
    ]

    private let legacyLabels = [
        "com.local.KeySwitch.AppShortcuts",
        "com.johan.KeyLaunchHelper",
        "com.johan.KeySwitchHelper"
    ]

    nonisolated private var launchAgentURL: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/LaunchAgents", isDirectory: true)
            .appendingPathComponent(launchAgentFileName)
    }

    nonisolated private var appShortcutLaunchAgentURL: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/LaunchAgents", isDirectory: true)
            .appendingPathComponent(appShortcutLaunchAgentFileName)
    }

    nonisolated private var applicationSupportDirectoryURL: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support", isDirectory: true)
            .appendingPathComponent(applicationSupportFolderName, isDirectory: true)
    }

    nonisolated private var legacyPayloadURL: URL {
        applicationSupportDirectoryURL.appendingPathComponent(legacyPayloadFileName)
    }

    nonisolated private var mappingsURL: URL {
        applicationSupportDirectoryURL.appendingPathComponent(mappingsFileName)
    }

    nonisolated private var profilesURL: URL {
        applicationSupportDirectoryURL.appendingPathComponent(profilesFileName)
    }

    nonisolated private var legacyMappingURLs: [URL] {
        legacyApplicationSupportFolderNames.map { folderName in
            FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent("Library/Application Support", isDirectory: true)
                .appendingPathComponent(folderName, isDirectory: true)
                .appendingPathComponent(mappingsFileName)
        }
    }

    nonisolated private var legacyPayloadURLs: [URL] {
        legacyApplicationSupportFolderNames.map { folderName in
            FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent("Library/Application Support", isDirectory: true)
                .appendingPathComponent(folderName, isDirectory: true)
                .appendingPathComponent(legacyPayloadFileName)
        }
    }

    nonisolated func cachedMappings() -> [KeyMapping] {
        cachedProfileState().activeMappings
    }

    nonisolated func cachedProfileState() -> KeyLaunchProfileState {
        (try? loadProfileStateFromExistingConfiguration().state)
            ?? KeyLaunchProfileState(
                profiles: [KeyLaunchProfileState.defaultProfile()],
                activeProfileID: KeyLaunchProfileState.defaultProfile().id
            )
    }

    nonisolated func prepareEnvironment() throws -> KeyLaunchProfileState {
        try ensureDirectoriesExist()

        let loadResult = try loadProfileStateFromExistingConfiguration()
        let state = loadResult.state.normalized()
        try writeStoredProfileState(state)
        try writeStoredMappings(state.activeMappings)

        if loadResult.shouldRewriteLaunchAgent || !FileManager.default.fileExists(atPath: launchAgentURL.path) {
            try writeLaunchAgent(for: state.activeMappings)
        }

        try cleanupLegacyLaunchAgents()
        try cleanupObsoleteFiles()
        try refreshAppShortcutBackgroundStartIfNeeded()
        try reloadLaunchAgent()
        try applyMappingsNow(state.activeMappings)

        return state
    }

    nonisolated func apply(_ mappings: [KeyMapping]) throws {
        try ensureDirectoriesExist()
        try writeLaunchAgent(for: mappings)
        try cleanupLegacyLaunchAgents()
        try cleanupObsoleteFiles()
        try refreshAppShortcutBackgroundStartIfNeeded()
        try reloadLaunchAgent()
        try applyMappingsNow(mappings)
        try writeStoredMappings(mappings)
    }

    nonisolated func apply(_ state: KeyLaunchProfileState) throws {
        let normalizedState = state.normalized()
        let mappings = normalizedState.activeMappings

        try apply(normalizedState, mappings: mappings)
    }

    nonisolated func apply(_ state: KeyLaunchProfileState, activeRuntimeProfileID: UUID) throws {
        let normalizedState = state.normalized()
        let mappings = normalizedState.mappings(for: activeRuntimeProfileID)

        try apply(normalizedState, mappings: mappings)
    }

    nonisolated private func apply(_ normalizedState: KeyLaunchProfileState, mappings: [KeyMapping]) throws {
        try ensureDirectoriesExist()
        try writeLaunchAgent(for: mappings)
        try cleanupLegacyLaunchAgents()
        try cleanupObsoleteFiles()
        try refreshAppShortcutBackgroundStartIfNeeded()
        try reloadLaunchAgent()
        try applyMappingsNow(mappings)
        try writeStoredProfileState(normalizedState)
        try writeStoredMappings(mappings)
    }

    nonisolated func isAppShortcutBackgroundStartEnabled() -> Bool {
        FileManager.default.fileExists(atPath: appShortcutLaunchAgentURL.path)
    }

    nonisolated func hasApplicationKeybinds() -> Bool {
        cachedProfileState().profiles.contains { profile in
            profile.mappings.contains {
                $0.action.applicationTarget != nil || $0.action.websiteTarget != nil
            }
        }
    }

    nonisolated func hasProfileAssignments() -> Bool {
        cachedProfileState().profiles.contains { !$0.assignedApplications.isEmpty }
    }

    nonisolated func setAppShortcutBackgroundStartEnabled(_ isEnabled: Bool) throws {
        try ensureDirectoriesExist()

        if isEnabled {
            try writeAppShortcutLaunchAgent()
            try reloadAppShortcutLaunchAgent()
        } else {
            try removeAppShortcutLaunchAgentIfNeeded()
        }
    }

    nonisolated private var uid: UInt32 {
        getuid()
    }

    nonisolated private func ensureDirectoriesExist() throws {
        try FileManager.default.createDirectory(
            at: launchAgentURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        try FileManager.default.createDirectory(
            at: applicationSupportDirectoryURL,
            withIntermediateDirectories: true
        )
    }

    nonisolated private func loadMappingsFromExistingConfiguration() throws -> MappingLoadResult {
        if let storedMappings = try? loadStoredMappings() {
            return MappingLoadResult(
                mappings: storedMappings,
                shouldRewriteLaunchAgent: true
            )
        }

        if let canonicalData = try? Data(contentsOf: launchAgentURL),
           let loadResult = parseMappingsFromLaunchAgentPlist(canonicalData) {
            return loadResult
        }

        for payloadURL in [legacyPayloadURL] + legacyPayloadURLs {
            if let payloadData = try? Data(contentsOf: payloadURL),
               let payloadResult = parseMappings(from: payloadData) {
                return MappingLoadResult(
                    mappings: payloadResult.mappings,
                    shouldRewriteLaunchAgent: true
                )
            }
        }

        if let legacyMappings = loadLegacyMappings() {
            return legacyMappings
        }

        return MappingLoadResult(
            mappings: [],
            shouldRewriteLaunchAgent: !FileManager.default.fileExists(atPath: launchAgentURL.path)
        )
    }

    nonisolated private func loadProfileStateFromExistingConfiguration() throws -> ProfileLoadResult {
        if let state = try? loadStoredProfileState() {
            return ProfileLoadResult(
                state: state.normalized(),
                shouldRewriteLaunchAgent: true
            )
        }

        let mappingLoadResult = try loadMappingsFromExistingConfiguration()
        let defaultProfile = KeyLaunchProfileState.defaultProfile(mappings: mappingLoadResult.mappings)

        return ProfileLoadResult(
            state: KeyLaunchProfileState(
                profiles: [defaultProfile],
                activeProfileID: defaultProfile.id
            ),
            shouldRewriteLaunchAgent: true
        )
    }

    nonisolated private func loadStoredProfileState() throws -> KeyLaunchProfileState {
        let data = try Data(contentsOf: profilesURL)
        let storedState = try JSONDecoder().decode(StoredProfileState.self, from: data)
        return storedState.profileState.normalized()
    }

    nonisolated private func loadLegacyMappings() -> MappingLoadResult? {
        for legacyURL in legacyLaunchAgentURLs {
            guard let plistData = try? Data(contentsOf: legacyURL) else {
                continue
            }

            if let loadResult = parseMappingsFromLaunchAgentPlist(plistData) {
                return MappingLoadResult(
                    mappings: loadResult.mappings,
                    shouldRewriteLaunchAgent: true
                )
            }
        }

        return nil
    }

    nonisolated private func loadStoredMappings() throws -> [KeyMapping] {
        if let mappings = try? loadStoredMappings(from: mappingsURL) {
            return mappings
        }

        for legacyMappingURL in legacyMappingURLs {
            if let mappings = try? loadStoredMappings(from: legacyMappingURL) {
                return mappings
            }
        }

        return try loadStoredMappings(from: mappingsURL)
    }

    nonisolated private func loadStoredMappings(from url: URL) throws -> [KeyMapping] {
        let data = try Data(contentsOf: url)
        let storedMappings = try JSONDecoder().decode([StoredMapping].self, from: data)

        return storedMappings.compactMap { storedMapping in
            guard let source = SourceKey.from(remapSourceValue: storedMapping.source),
                  let action = storedMapping.keybindAction
            else {
                return nil
            }

            return KeyMapping(source: source, action: action)
        }
        .deduplicatedBySource()
        .sorted { $0.source.sortOrder < $1.source.sortOrder }
    }

    nonisolated private func writeStoredMappings(_ mappings: [KeyMapping]) throws {
        let storedMappings = mappings
            .deduplicatedBySource()
            .sorted { $0.source.sortOrder < $1.source.sortOrder }
            .map(StoredMapping.init)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let data = try encoder.encode(storedMappings)
        try data.write(to: mappingsURL, options: .atomic)
    }

    nonisolated private func writeStoredProfileState(_ state: KeyLaunchProfileState) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let data = try encoder.encode(StoredProfileState(state.normalized()))
        try data.write(to: profilesURL, options: .atomic)
    }

    nonisolated private func parseMappingsFromLaunchAgentPlist(_ plistData: Data) -> MappingLoadResult? {
        guard
            let plist = try? PropertyListSerialization.propertyList(from: plistData, format: nil) as? [String: Any],
            let arguments = plist["ProgramArguments"] as? [String],
            arguments.count >= 4,
            arguments[0] == "/usr/bin/hidutil",
            arguments[1] == "property",
            arguments[2] == "--set"
        else {
            return nil
        }

        let jsonString = arguments[3]
        guard let jsonData = normalizeLegacyJSON(jsonString).data(using: .utf8),
              let loadResult = parseMappings(from: jsonData)
        else {
            return nil
        }

        return MappingLoadResult(
            mappings: loadResult.mappings,
            shouldRewriteLaunchAgent: loadResult.shouldRewriteLaunchAgent
        )
    }

    nonisolated private func parseMappings(from jsonData: Data) -> MappingLoadResult? {
        guard
            let payload = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
            let mappings = payload["UserKeyMapping"] as? [[String: Any]]
        else {
            return nil
        }

        var parsedMappings: [KeyMapping] = []
        var requiresMigration = false

        for entry in mappings {
            guard
                let sourceNumber = entry["HIDKeyboardModifierMappingSrc"] as? NSNumber,
                let destinationNumber = entry["HIDKeyboardModifierMappingDst"] as? NSNumber,
                let source = SourceKey.from(remapSourceValue: sourceNumber.uint64Value),
                let resolution = RemapAction.resolve(destinationUsageValue: destinationNumber.uint64Value)
            else {
                continue
            }

            parsedMappings.append(KeyMapping(source: source, action: .systemFunction(resolution.action)))
            requiresMigration = requiresMigration || resolution.requiresMigration
        }

        let normalizedMappings = parsedMappings
            .deduplicatedBySource()
            .sorted { $0.source.sortOrder < $1.source.sortOrder }
        let shouldRewriteLaunchAgent = requiresMigration
            || normalizedMappings.count != mappings.count

        return MappingLoadResult(
            mappings: normalizedMappings,
            shouldRewriteLaunchAgent: shouldRewriteLaunchAgent
        )
    }

    nonisolated private func cleanupObsoleteFiles() throws {
        let obsoleteFiles = [
            applicationSupportDirectoryURL.appendingPathComponent("apply-keylaunch-mapping.sh"),
            applicationSupportDirectoryURL.appendingPathComponent("apply-keyswitch-mapping.sh"),
            legacyPayloadURL
        ] + legacyApplicationSupportFolderNames.flatMap { folderName in
            let supportDirectory = FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent("Library/Application Support", isDirectory: true)
                .appendingPathComponent(folderName, isDirectory: true)

            return [
                supportDirectory.appendingPathComponent("apply-keylaunch-mapping.sh"),
                supportDirectory.appendingPathComponent("apply-keyswitch-mapping.sh"),
                supportDirectory.appendingPathComponent(legacyPayloadFileName)
            ]
        }

        for fileURL in obsoleteFiles where FileManager.default.fileExists(atPath: fileURL.path) {
            try? FileManager.default.removeItem(at: fileURL)
        }
    }

    nonisolated private func writeLaunchAgent(for mappings: [KeyMapping]) throws {
        let jsonString = try makeJSONPayload(from: mappings)
        let plist: [String: Any] = [
            "Label": label,
            "ProgramArguments": [
                "/usr/bin/hidutil",
                "property",
                "--set",
                jsonString
            ],
            "RunAtLoad": true
        ]

        let data = try PropertyListSerialization.data(
            fromPropertyList: plist,
            format: .xml,
            options: 0
        )

        try data.write(to: launchAgentURL, options: .atomic)
    }

    nonisolated private func refreshAppShortcutBackgroundStartIfNeeded() throws {
        if isAppShortcutBackgroundStartEnabled() {
            try writeAppShortcutLaunchAgent()
        }
    }

    nonisolated private func writeAppShortcutLaunchAgent() throws {
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.johan.KeyLaunch"
        let plist: [String: Any] = [
            "Label": appShortcutLaunchAgentLabel,
            "ProgramArguments": [
                "/usr/bin/open",
                "-gj",
                "-b",
                bundleIdentifier,
                "--args",
                "--background"
            ],
            "RunAtLoad": true
        ]

        let data = try PropertyListSerialization.data(
            fromPropertyList: plist,
            format: .xml,
            options: 0
        )

        try data.write(to: appShortcutLaunchAgentURL, options: .atomic)
    }

    nonisolated private func cleanupLegacyLaunchAgents() throws {
        for legacyLabel in legacyLabels {
            _ = try? runCommand("/bin/launchctl", arguments: ["bootout", "gui/\(uid)/\(legacyLabel)"])
        }

        for legacyURL in legacyLaunchAgentURLs where FileManager.default.fileExists(atPath: legacyURL.path) {
            _ = try? runCommand("/bin/launchctl", arguments: ["bootout", "gui/\(uid)", legacyURL.path])
            try? FileManager.default.removeItem(at: legacyURL)
        }
    }

    nonisolated private func reloadLaunchAgent() throws {
        unloadLaunchAgentIfNeeded()
        try runCommand("/bin/launchctl", arguments: ["bootstrap", "gui/\(uid)", launchAgentURL.path])
    }

    nonisolated private func unloadLaunchAgentIfNeeded() {
        _ = try? runCommand("/bin/launchctl", arguments: ["bootout", "gui/\(uid)/\(label)"])
        _ = try? runCommand("/bin/launchctl", arguments: ["bootout", "gui/\(uid)", launchAgentURL.path])
    }

    nonisolated private func reloadAppShortcutLaunchAgent() throws {
        unloadAppShortcutLaunchAgentIfNeeded()
        try runCommand("/bin/launchctl", arguments: ["bootstrap", "gui/\(uid)", appShortcutLaunchAgentURL.path])
    }

    nonisolated private func removeAppShortcutLaunchAgentIfNeeded() throws {
        unloadAppShortcutLaunchAgentIfNeeded()

        if FileManager.default.fileExists(atPath: appShortcutLaunchAgentURL.path) {
            try FileManager.default.removeItem(at: appShortcutLaunchAgentURL)
        }
    }

    nonisolated private func unloadAppShortcutLaunchAgentIfNeeded() {
        _ = try? runCommand("/bin/launchctl", arguments: ["bootout", "gui/\(uid)/\(appShortcutLaunchAgentLabel)"])
        _ = try? runCommand("/bin/launchctl", arguments: ["bootout", "gui/\(uid)", appShortcutLaunchAgentURL.path])
    }

    nonisolated private func applyMappingsNow(_ mappings: [KeyMapping]) throws {
        let jsonString = try makeJSONPayload(from: mappings)
        try runCommand(
            "/usr/bin/hidutil",
            arguments: ["property", "--set", jsonString]
        )
    }

    nonisolated private func makeJSONPayload(from mappings: [KeyMapping]) throws -> String {
        let payload: [String: Any] = [
            "UserKeyMapping": mappings
                .compactMap { mapping -> (source: SourceKey, destinationUsageValue: UInt64)? in
                    switch mapping.action {
                    case .systemFunction(let action):
                        return (mapping.source, action.destinationUsageValue)
                    case .openApplication:
                        guard let triggerUsageValue = mapping.source.appShortcutTriggerUsageValue else {
                            return nil
                        }

                        return (mapping.source, triggerUsageValue)
                    case .openWebsite:
                        guard let triggerUsageValue = mapping.source.appShortcutTriggerUsageValue else {
                            return nil
                        }

                        return (mapping.source, triggerUsageValue)
                    }
                }
                .sorted { $0.source.sortOrder < $1.source.sortOrder }
                .map { mapping in
                    [
                        "HIDKeyboardModifierMappingSrc": mapping.source.remapSourceValue,
                        "HIDKeyboardModifierMappingDst": mapping.destinationUsageValue
                    ]
                }
        ]

        let data = try JSONSerialization.data(withJSONObject: payload, options: [])
        guard let string = String(data: data, encoding: .utf8) else {
            throw NSError(
                domain: "KeyLaunch",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "The mapping data could not be created."]
            )
        }

        return string
    }

    nonisolated private func normalizeLegacyJSON(_ string: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: #"0x[0-9A-Fa-f]+"#) else {
            return string
        }

        let range = NSRange(string.startIndex..., in: string)
        let matches = regex.matches(in: string, range: range).reversed()
        var normalized = string

        for match in matches {
            guard let matchRange = Range(match.range, in: normalized) else {
                continue
            }

            let hexLiteral = String(normalized[matchRange].dropFirst(2))
            guard let value = UInt64(hexLiteral, radix: 16) else {
                continue
            }

            normalized.replaceSubrange(matchRange, with: String(value))
        }

        return normalized
    }

    nonisolated private var legacyLaunchAgentURLs: [URL] {
        legacyLaunchAgentFileNames.map { fileName in
            FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent("Library/LaunchAgents", isDirectory: true)
                .appendingPathComponent(fileName)
        }
    }

    @discardableResult
    nonisolated private func runCommand(_ launchPath: String, arguments: [String]) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: launchPath)
        process.arguments = arguments

        let stdout = Pipe()
        let stderr = Pipe()
        process.standardOutput = stdout
        process.standardError = stderr

        try process.run()
        process.waitUntilExit()

        let outputData = stdout.fileHandleForReading.readDataToEndOfFile()
        let errorData = stderr.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: outputData, encoding: .utf8) ?? ""
        let errorOutput = String(data: errorData, encoding: .utf8) ?? ""

        if process.terminationStatus != 0 {
            let message = errorOutput.isEmpty ? output : errorOutput
            throw NSError(
                domain: "KeyLaunch",
                code: Int(process.terminationStatus),
                userInfo: [NSLocalizedDescriptionKey: message.trimmingCharacters(in: .whitespacesAndNewlines)]
            )
        }

        return output
    }

    private struct StoredMapping: Codable {
        let source: UInt64
        let action: String?
        let actionKind: String?
        let applicationName: String?
        let applicationURL: String?
        let applicationBundleIdentifier: String?
        let websiteURL: String?

        nonisolated init(_ mapping: KeyMapping) {
            source = mapping.source.remapSourceValue

            switch mapping.action {
            case .systemFunction(let remapAction):
                action = remapAction.rawValue
                actionKind = "systemFunction"
                applicationName = nil
                applicationURL = nil
                applicationBundleIdentifier = nil
                websiteURL = nil
            case .openApplication(let target):
                action = nil
                actionKind = "openApplication"
                applicationName = target.displayName
                applicationURL = target.url.path
                applicationBundleIdentifier = target.bundleIdentifier
                websiteURL = nil
            case .openWebsite(let target):
                action = nil
                actionKind = "openWebsite"
                applicationName = nil
                applicationURL = nil
                applicationBundleIdentifier = nil
                websiteURL = target.url.absoluteString
            }
        }

        nonisolated var keybindAction: KeybindAction? {
            if actionKind == "openApplication" {
                guard let applicationName,
                      let applicationURL
                else {
                    return nil
                }

                return .openApplication(
                    ApplicationLaunchTarget(
                        displayName: applicationName,
                        url: URL(fileURLWithPath: applicationURL),
                        bundleIdentifier: applicationBundleIdentifier
                    )
                )
            }

            if actionKind == "openWebsite" {
                guard let websiteURL,
                      let url = URL(string: websiteURL)
                else {
                    return nil
                }

                return .openWebsite(WebsiteLaunchTarget(url: url))
            }

            guard let action,
                  let remapAction = RemapAction(rawValue: action)
            else {
                return nil
            }

            return .systemFunction(remapAction)
        }

        nonisolated var keyMapping: KeyMapping? {
            guard let source = SourceKey.from(remapSourceValue: source),
                  let keybindAction
            else {
                return nil
            }

            return KeyMapping(source: source, action: keybindAction)
        }
    }

    private struct StoredProfileState: Codable {
        let activeProfileID: String
        let profiles: [StoredProfile]

        nonisolated init(_ state: KeyLaunchProfileState) {
            let normalizedState = state.normalized()
            activeProfileID = normalizedState.activeProfileID.uuidString
            profiles = normalizedState.profiles.map(StoredProfile.init)
        }

        nonisolated var profileState: KeyLaunchProfileState {
            let loadedProfiles = profiles.map(\.profile)
            let fallbackID = loadedProfiles.first?.id ?? KeyLaunchProfileState.defaultProfile().id
            let activeID = UUID(uuidString: activeProfileID) ?? fallbackID

            return KeyLaunchProfileState(
                profiles: loadedProfiles,
                activeProfileID: activeID
            )
        }
    }

    private struct StoredProfile: Codable {
        let id: String
        let name: String
        let mappings: [StoredMapping]
        let assignedApplications: [StoredApplication]
        let isDefault: Bool

        nonisolated init(_ profile: KeyLaunchProfile) {
            id = profile.id.uuidString
            name = profile.name
            mappings = profile.mappings
                .deduplicatedBySource()
                .sorted { $0.source.sortOrder < $1.source.sortOrder }
                .map(StoredMapping.init)
            assignedApplications = profile.assignedApplications.map(StoredApplication.init)
            isDefault = profile.isDefault
        }

        nonisolated var profile: KeyLaunchProfile {
            KeyLaunchProfile(
                id: UUID(uuidString: id) ?? UUID(),
                name: name,
                mappings: mappings.compactMap(\.keyMapping)
                    .deduplicatedBySource()
                    .sorted { $0.source.sortOrder < $1.source.sortOrder },
                assignedApplications: assignedApplications.map(\.applicationTarget),
                isDefault: isDefault
            )
        }
    }

    private struct StoredApplication: Codable {
        let displayName: String
        let url: String
        let bundleIdentifier: String?

        nonisolated init(_ target: ApplicationLaunchTarget) {
            displayName = target.displayName
            url = target.url.path
            bundleIdentifier = target.bundleIdentifier
        }

        nonisolated var applicationTarget: ApplicationLaunchTarget {
            ApplicationLaunchTarget(
                displayName: displayName,
                url: URL(fileURLWithPath: url),
                bundleIdentifier: bundleIdentifier
            )
        }
    }
}

private extension Array where Element == KeyMapping {
    nonisolated func deduplicatedBySource() -> [KeyMapping] {
        var mappingsBySource: [UInt64: KeyMapping] = [:]

        for mapping in self {
            mappingsBySource[mapping.source.remapSourceValue] = mapping
        }

        return Array(mappingsBySource.values)
    }
}

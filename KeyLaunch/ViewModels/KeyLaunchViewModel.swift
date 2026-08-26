import Combine
import AppKit
import SwiftUI
import UniformTypeIdentifiers

@MainActor
final class KeyLaunchViewModel: ObservableObject {
    enum ActionMode: String, CaseIterable, Identifiable {
        case systemFunction
        case openApplication
        case openWebsite

        var id: String { rawValue }
    }

    @Published var selectedKey: SourceKey?
    @Published var selectedAction: RemapAction = .keyboardBrightnessDown
    @Published var selectedActionMode: ActionMode = .systemFunction
    @Published var selectedApplication: ApplicationLaunchTarget?
    @Published var websiteURLString = ""
    @Published private(set) var statusMessage = "Choose a key and a function."
    @Published private(set) var profiles: [KeyLaunchProfile] = []
    @Published private(set) var activeProfileID = KeyLaunchProfileState.defaultProfile().id
    @Published private(set) var runtimeProfileID = KeyLaunchProfileState.defaultProfile().id
    @Published private(set) var savedMappings: [KeyMapping] = []
    @Published private(set) var isBackgroundStartEnabled = KeyRemappingService.shared.isAppShortcutBackgroundStartEnabled()

    private var hasPreparedEnvironment = false
    private var appActivationObserver: Any?

    init() {
        let cachedState = KeyRemappingService.shared.cachedProfileState().normalized()
        applyProfileState(cachedState)

        if !savedMappings.isEmpty {
            statusMessage = "\(savedMappings.count) keybind\(savedMappings.count == 1 ? "" : "s") loaded."
        }

        startAppActivationMonitor()
    }

    deinit {
        if let appActivationObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(appActivationObserver)
        }
    }

    var canSave: Bool {
        guard selectedKey != nil else {
            return false
        }

        switch selectedActionMode {
        case .systemFunction:
            return true
        case .openApplication:
            return selectedApplication != nil
        case .openWebsite:
            return !websiteURLString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    var activeProfileName: String {
        activeProfile?.name ?? "Default"
    }

    var runtimeProfileName: String {
        runtimeProfile?.name ?? activeProfileName
    }

    var isUsingRuntimeProfileOverride: Bool {
        runtimeProfileID != activeProfileID
    }

    var activeAssignedApplications: [ApplicationLaunchTarget] {
        activeProfile?.assignedApplications ?? []
    }

    var canDeleteActiveProfile: Bool {
        guard let activeProfile else {
            return false
        }

        return canDeleteProfile(activeProfile)
    }

    func canDeleteProfile(_ profile: KeyLaunchProfile) -> Bool {
        !profile.isDefault && profiles.count > 1
    }

    func selectKey(_ key: SourceKey) {
        selectedKey = key
        statusMessage = "\(key.displayName) selected."
    }

    func saveCurrentMapping() {
        guard let activeKey = selectedKey else {
            statusMessage = "Choose a key first."
            return
        }

        let previousState = currentProfileState()
        let previousRuntimeProfileID = runtimeProfileID
        var updatedMappings = savedMappings
        guard let mapping = makeCurrentMapping(source: activeKey) else {
            return
        }

        if let existingIndex = updatedMappings.firstIndex(where: { $0.source == activeKey }) {
            updatedMappings[existingIndex] = mapping
        } else {
            updatedMappings.append(mapping)
            updatedMappings.sort { $0.source.sortOrder < $1.source.sortOrder }
        }

        setMappingsForActiveProfile(updatedMappings)

        do {
            try applyProfileStateForCurrentRuntime()
            statusMessage = "\(activeKey.displayName) was saved as a keybind."
        } catch {
            applyProfileState(previousState)
            runtimeProfileID = previousRuntimeProfileID
            AppShortcutMonitor.shared.updateMappings(runtimeMappings)
            statusMessage = "The mapping could not be applied: \(error.localizedDescription)"
            return
        }

        selectedKey = nil
        resetActionSelection()
    }

    func removeMapping(_ mapping: KeyMapping) {
        let previousState = currentProfileState()
        let previousRuntimeProfileID = runtimeProfileID
        var updatedMappings = savedMappings
        updatedMappings.removeAll { $0.id == mapping.id }
        setMappingsForActiveProfile(updatedMappings)

        do {
            try applyProfileStateForCurrentRuntime()
            statusMessage = "\(mapping.source.displayName) was removed."
        } catch {
            applyProfileState(previousState)
            runtimeProfileID = previousRuntimeProfileID
            AppShortcutMonitor.shared.updateMappings(runtimeMappings)
            statusMessage = "The mapping could not be removed: \(error.localizedDescription)"
        }
    }

    func resetComposer() {
        selectedKey = nil
        resetActionSelection()
        statusMessage = "Selection reset."
    }

    func selectActionMode(_ mode: ActionMode) {
        selectedActionMode = mode
    }

    func chooseApplication() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.application]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = true
        panel.treatsFilePackagesAsDirectories = false
        panel.directoryURL = URL(fileURLWithPath: "/Applications", isDirectory: true)
        panel.prompt = "Choose"

        if let window = NSApp.keyWindow {
            panel.beginSheetModal(for: window) { [weak self] response in
                guard response == .OK,
                      let url = panel.url
                else {
                    return
                }

                Task { @MainActor in
                    self?.selectApplication(at: url)
                }
            }
        } else {
            panel.begin { [weak self] response in
                guard response == .OK,
                      let url = panel.url
                else {
                    return
                }

                Task { @MainActor in
                    self?.selectApplication(at: url)
                }
            }
        }
    }

    func prepareEnvironmentIfNeeded() {
        guard !hasPreparedEnvironment else {
            return
        }

        hasPreparedEnvironment = true

        Task {
            do {
                let state = try await Task.detached(priority: .userInitiated) {
                    try KeyRemappingService.shared.prepareEnvironment()
                }.value

                applyProfileState(state)
                refreshBackgroundStartStatus()
                try applyProfileStateForCurrentRuntime()
                statusMessage = savedMappings.isEmpty
                    ? "Choose a key and a function."
                    : "\(savedMappings.count) keybind\(savedMappings.count == 1 ? "" : "s") loaded."
            } catch {
                if savedMappings.isEmpty {
                    statusMessage = "KeyLaunch could not prepare its system files: \(error.localizedDescription)"
                }
            }
        }
    }

    func enableBackgroundStart() {
        setBackgroundStartEnabled(true)
    }

    func disableBackgroundStart() {
        setBackgroundStartEnabled(false)
    }

    func refreshBackgroundStartStatus() {
        isBackgroundStartEnabled = KeyRemappingService.shared.isAppShortcutBackgroundStartEnabled()
    }

    func switchProfile(_ profile: KeyLaunchProfile) {
        switchProfile(id: profile.id)
    }

    func createProfile() {
        let profile = KeyLaunchProfile(name: nextProfileName())
        profiles.append(profile)
        activeProfileID = profile.id
        savedMappings = []
        persistProfileState(successMessage: "\(profile.name) created.")
    }

    func createProfile(from preset: KeyLaunchPreset) {
        var profile = KeyLaunchProfile(
            name: uniqueProfileName(for: preset.name),
            mappings: preset.mappings
        )
        profile.isDefault = false

        profiles.append(profile)
        activeProfileID = profile.id
        savedMappings = profile.mappings
        persistProfileState(successMessage: "\(profile.name) preset added.")
    }

    func deleteActiveProfile() {
        guard canDeleteActiveProfile,
              let profile = activeProfile
        else {
            return
        }

        deleteProfile(profile)
    }

    func deleteProfile(_ profile: KeyLaunchProfile) {
        guard canDeleteProfile(profile) else {
            return
        }

        profiles.removeAll { $0.id == profile.id }
        if activeProfileID == profile.id {
            activeProfileID = defaultProfileID
        }
        if runtimeProfileID == profile.id {
            runtimeProfileID = activeProfileID
        }
        savedMappings = activeProfile?.mappings ?? []
        persistProfileState(successMessage: "\(profile.name) deleted.")
    }

    func renameProfile(_ profile: KeyLaunchProfile, to newName: String) {
        let cleanedName = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedName.isEmpty,
              let index = profiles.firstIndex(where: { $0.id == profile.id })
        else {
            return
        }

        profiles[index].name = cleanedName
        persistProfileState(successMessage: "Profile renamed.")
    }

    func chooseApplicationForActiveProfile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.application]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = true
        panel.canChooseFiles = true
        panel.treatsFilePackagesAsDirectories = false
        panel.directoryURL = URL(fileURLWithPath: "/Applications", isDirectory: true)
        panel.prompt = "Assign"

        let completion: (NSApplication.ModalResponse) -> Void = { [weak self] response in
            guard response == .OK,
                  let url = panel.url
            else {
                return
            }

            Task { @MainActor in
                self?.assignApplicationToActiveProfile(at: url)
            }
        }

        if let window = NSApp.keyWindow {
            panel.beginSheetModal(for: window, completionHandler: completion)
        } else {
            panel.begin(completionHandler: completion)
        }
    }

    func removeAssignedApplication(_ target: ApplicationLaunchTarget) {
        guard let profileIndex = profiles.firstIndex(where: { $0.id == activeProfileID }) else {
            return
        }

        profiles[profileIndex].assignedApplications.removeAll { $0.id == target.id }
        persistProfileState(successMessage: "\(target.displayName) assignment removed.")
    }

    private func setBackgroundStartEnabled(_ isEnabled: Bool) {
        do {
            try KeyRemappingService.shared.setAppShortcutBackgroundStartEnabled(isEnabled)
            isBackgroundStartEnabled = isEnabled
            statusMessage = isEnabled
                ? "Background start is enabled."
                : "Background start is disabled."
        } catch {
            refreshBackgroundStartStatus()
            statusMessage = "Background start could not be updated: \(error.localizedDescription)"
        }
    }

    private func makeCurrentMapping(source: SourceKey) -> KeyMapping? {
        switch selectedActionMode {
        case .systemFunction:
            return KeyMapping(source: source, action: .systemFunction(selectedAction))
        case .openApplication:
            guard let selectedApplication else {
                statusMessage = "Choose an app first."
                return nil
            }

            requestAccessibilityIfNeeded()
            return KeyMapping(source: source, action: .openApplication(selectedApplication))
        case .openWebsite:
            guard let websiteURL = normalizedWebsiteURL(from: websiteURLString) else {
                statusMessage = "Enter a valid website URL."
                return nil
            }

            requestAccessibilityIfNeeded()
            websiteURLString = websiteURL.absoluteString
            return KeyMapping(source: source, action: .openWebsite(WebsiteLaunchTarget(url: websiteURL)))
        }
    }

    private func resetActionSelection() {
        selectedAction = .keyboardBrightnessDown
        selectedActionMode = .systemFunction
        selectedApplication = nil
        websiteURLString = ""
    }

    private func normalizedWebsiteURL(from rawValue: String) -> URL? {
        let trimmedValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.isEmpty else {
            return nil
        }

        let candidate = trimmedValue.contains("://") ? trimmedValue : "https://\(trimmedValue)"
        guard let url = URL(string: candidate),
              let scheme = url.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              url.host?.nilIfEmpty != nil
        else {
            return nil
        }

        return url
    }

    private func appDisplayName(for url: URL) -> String {
        if let displayName = FileManager.default.displayName(atPath: url.path).nilIfEmpty {
            return displayName.replacingOccurrences(of: ".app", with: "")
        }

        return url.deletingPathExtension().lastPathComponent
    }

    private func selectApplication(at url: URL) {
        selectedApplication = ApplicationLaunchTarget(
            displayName: appDisplayName(for: url),
            url: url,
            bundleIdentifier: Bundle(url: url)?.bundleIdentifier
        )
        selectedActionMode = .openApplication
        requestAccessibilityIfNeeded()
        statusMessage = "\(selectedApplication?.displayName ?? "App") selected."
    }

    private func requestAccessibilityIfNeeded() {
        guard !PermissionCenter.shared.isAccessibilityTrusted else {
            return
        }

        PermissionCenter.shared.requestAccessibility()
    }

    private var activeProfile: KeyLaunchProfile? {
        profiles.first { $0.id == activeProfileID }
    }

    private var runtimeProfile: KeyLaunchProfile? {
        profiles.first { $0.id == runtimeProfileID }
    }

    private var runtimeMappings: [KeyMapping] {
        runtimeProfile?.mappings ?? activeProfile?.mappings ?? []
    }

    private var defaultProfileID: UUID {
        profiles.first { $0.isDefault }?.id ?? profiles.first?.id ?? KeyLaunchProfileState.defaultProfile().id
    }

    private func applyProfileState(_ state: KeyLaunchProfileState) {
        let normalizedState = state.normalized()
        profiles = normalizedState.profiles
        activeProfileID = normalizedState.activeProfileID
        runtimeProfileID = normalizedState.activeProfileID
        savedMappings = normalizedState.activeMappings
        AppShortcutMonitor.shared.updateMappings(runtimeMappings)
    }

    private func currentProfileState() -> KeyLaunchProfileState {
        KeyLaunchProfileState(
            profiles: profiles,
            activeProfileID: activeProfileID
        )
        .normalized()
    }

    private func setMappingsForActiveProfile(_ mappings: [KeyMapping]) {
        guard let index = profiles.firstIndex(where: { $0.id == activeProfileID }) else {
            return
        }

        let normalizedMappings = mappings
            .deduplicatedBySource()
            .sorted { $0.source.sortOrder < $1.source.sortOrder }
        profiles[index].mappings = normalizedMappings
        savedMappings = normalizedMappings
    }

    private func persistProfileState(successMessage: String) {
        do {
            try applyProfileStateForCurrentRuntime()
            statusMessage = successMessage
        } catch {
            statusMessage = "Profiles could not be saved: \(error.localizedDescription)"
        }
    }

    private func applyProfileStateForCurrentRuntime() throws {
        refreshRuntimeProfileForCurrentApplication()
        try KeyRemappingService.shared.apply(
            currentProfileState(),
            activeRuntimeProfileID: runtimeProfileID
        )
        AppShortcutMonitor.shared.updateMappings(runtimeMappings)
    }

    private func nextProfileName() -> String {
        var index = profiles.count + 1
        var name = "Profile \(index)"

        while profiles.contains(where: { $0.name == name }) {
            index += 1
            name = "Profile \(index)"
        }

        return name
    }

    private func uniqueProfileName(for baseName: String) -> String {
        guard profiles.contains(where: { $0.name == baseName }) else {
            return baseName
        }

        var index = 2
        var name = "\(baseName) \(index)"

        while profiles.contains(where: { $0.name == name }) {
            index += 1
            name = "\(baseName) \(index)"
        }

        return name
    }

    private func assignApplicationToActiveProfile(at url: URL) {
        guard let profileIndex = profiles.firstIndex(where: { $0.id == activeProfileID }) else {
            return
        }

        let target = ApplicationLaunchTarget(
            displayName: appDisplayName(for: url),
            url: url,
            bundleIdentifier: Bundle(url: url)?.bundleIdentifier
        )

        profiles[profileIndex].assignedApplications.removeAll { $0.id == target.id }
        profiles[profileIndex].assignedApplications.append(target)
        persistProfileState(successMessage: "\(target.displayName) now opens \(profiles[profileIndex].name).")
    }

    private func switchProfile(id: UUID) {
        guard activeProfileID != id,
              let profile = profiles.first(where: { $0.id == id })
        else {
            return
        }

        activeProfileID = id
        savedMappings = profile.mappings
        persistProfileState(successMessage: "\(profile.name) selected.")
    }

    private func startAppActivationMonitor() {
        appActivationObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor [weak self] in
                self?.handleActiveApplicationChange()
            }
        }
    }

    private func handleActiveApplicationChange() {
        let previousRuntimeProfileID = runtimeProfileID
        refreshRuntimeProfileForCurrentApplication()

        guard runtimeProfileID != previousRuntimeProfileID else {
            return
        }

        do {
            try KeyRemappingService.shared.apply(
                currentProfileState(),
                activeRuntimeProfileID: runtimeProfileID
            )
            AppShortcutMonitor.shared.updateMappings(runtimeMappings)

            if isUsingRuntimeProfileOverride,
               let frontmostApplicationName = NSWorkspace.shared.frontmostApplication?.localizedName {
                statusMessage = "\(runtimeProfileName) is active for \(frontmostApplicationName)."
            } else {
                statusMessage = "\(activeProfileName) is active."
            }
        } catch {
            runtimeProfileID = previousRuntimeProfileID
            AppShortcutMonitor.shared.updateMappings(runtimeMappings)
            statusMessage = "The active profile could not be updated: \(error.localizedDescription)"
        }
    }

    private func refreshRuntimeProfileForCurrentApplication() {
        guard let runningApplication = NSWorkspace.shared.frontmostApplication,
              let matchedProfile = profile(for: runningApplication)
        else {
            runtimeProfileID = activeProfileID
            return
        }

        runtimeProfileID = matchedProfile.id
    }

    private func profile(for runningApplication: NSRunningApplication) -> KeyLaunchProfile? {
        profiles.first { profile in
            profile.assignedApplications.contains { target in
                if let bundleIdentifier = target.bundleIdentifier,
                   bundleIdentifier == runningApplication.bundleIdentifier {
                    return true
                }

                return target.url == runningApplication.bundleURL
            }
        }
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

private extension Array where Element == KeyMapping {
    func deduplicatedBySource() -> [KeyMapping] {
        var mappingsBySource: [UInt64: KeyMapping] = [:]

        for mapping in self {
            mappingsBySource[mapping.source.remapSourceValue] = mapping
        }

        return Array(mappingsBySource.values)
    }
}

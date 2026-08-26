import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = KeyLaunchViewModel()
    @StateObject private var permissions = PermissionCenter.shared
    @State private var isShowingSettings = false
    @State private var shouldFocusPremiumSettings = false
    @State private var isSidebarCollapsed = false
    @State private var profileBeingRenamed: KeyLaunchProfile?
    @State private var profilePendingDeletion: KeyLaunchProfile?
    @State private var profileNameDraft = ""
    @AppStorage(AppLanguage.storageKey) private var appLanguageRawValue = AppLanguage.english.rawValue
    @AppStorage("permissionsSetupCompleted") private var permissionsSetupCompleted = false

    private var language: AppLanguage {
        AppLanguage(rawValue: appLanguageRawValue) ?? .english
    }

    private var sidebarWidth: CGFloat {
        isSidebarCollapsed ? 76 : 284
    }

    private var windowContentSize: CGSize {
        CGSize(width: isSidebarCollapsed ? 1016 : 1080, height: 720)
    }

    var body: some View {
        ZStack {
            Color(nsColor: .windowBackgroundColor)
                .ignoresSafeArea()

            if !permissionsSetupCompleted {
                PermissionsSetupView(
                    permissions: permissions,
                    viewModel: viewModel
                ) {
                    permissionsSetupCompleted = true
                }
                .transition(.opacity)
            } else if isShowingSettings {
                AppSettingsView(
                    permissions: permissions,
                    viewModel: viewModel,
                    focusPremium: shouldFocusPremiumSettings
                ) {
                    shouldFocusPremiumSettings = false
                    isShowingSettings = false
                }
                .transition(.opacity)
            } else {
                mainInterface
                    .ignoresSafeArea(.container, edges: [.leading, .trailing])
            }
        }
        .frame(minWidth: isSidebarCollapsed ? 900 : 980, minHeight: 620)
        .background(WindowConfigurationView(contentSize: windowContentSize))
        .alert(language.renameProfileTitle, isPresented: isRenamingProfile) {
            TextField(language.profileNameTitle, text: $profileNameDraft)

            Button(language.cancelTitle, role: .cancel) {
                profileBeingRenamed = nil
            }

            Button(language.saveTitle) {
                if let profileBeingRenamed {
                    viewModel.renameProfile(profileBeingRenamed, to: profileNameDraft)
                }

                profileBeingRenamed = nil
            }
        }
        .alert(language.deleteProfileConfirmationTitle, isPresented: isConfirmingProfileDeletion) {
            Button(language.cancelTitle, role: .cancel) {
                profilePendingDeletion = nil
            }

            Button(language.deleteProfileTitle, role: .destructive) {
                if let profilePendingDeletion {
                    viewModel.deleteProfile(profilePendingDeletion)
                }

                profilePendingDeletion = nil
            }
        } message: {
            Text(language.deleteProfileConfirmationDetail(profilePendingDeletion?.name ?? ""))
        }
        .onAppear {
            viewModel.prepareEnvironmentIfNeeded()
        }
        .onChange(of: viewModel.premiumUpsellRequestID) { _, requestID in
            guard requestID > 0 else {
                return
            }

            showPremiumSettings()
        }
    }

    private var isRenamingProfile: Binding<Bool> {
        Binding(
            get: { profileBeingRenamed != nil },
            set: { isPresented in
                if !isPresented {
                    profileBeingRenamed = nil
                }
            }
        )
    }

    private var isConfirmingProfileDeletion: Binding<Bool> {
        Binding(
            get: { profilePendingDeletion != nil },
            set: { isPresented in
                if !isPresented {
                    profilePendingDeletion = nil
                }
            }
        )
    }

    private var mainInterface: some View {
        HStack(spacing: 0) {
            profileSidebar

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    configurationSection
                    mappingsSection
                }
                .padding(24)
                .frame(maxWidth: 920, alignment: .topLeading)
            }
        }
        .animation(.spring(response: 0.26, dampingFraction: 0.9), value: isSidebarCollapsed)
    }

    private var profileSidebar: some View {
        VStack(alignment: .leading, spacing: 14) {
            sidebarHeader

            Divider()

            sidebarProfiles

            if !isSidebarCollapsed {
                sidebarAssignedApplications
            }

            Spacer(minLength: 12)
        }
        .padding(.horizontal, isSidebarCollapsed ? 10 : 16)
        .padding(.vertical, 16)
        .frame(width: sidebarWidth)
        .frame(maxHeight: .infinity, alignment: .top)
        .background {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea(.container, edges: [.leading, .top, .bottom])
        }
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(Color(nsColor: .separatorColor).opacity(0.35))
                .frame(width: 1)
        }
    }

    private var sidebarHeader: some View {
        Group {
            if isSidebarCollapsed {
                VStack(spacing: 12) {
                    sidebarAppIcon

                    sidebarHeaderIconButtons
                }
                .frame(maxWidth: .infinity)
            } else {
                HStack(spacing: 12) {
                    sidebarAppIcon

                    Spacer(minLength: 0)

                    sidebarHeaderIconButtons
                }
            }
        }
    }

    private var sidebarAppIcon: some View {
        Image(nsImage: NSApp.applicationIconImage)
            .resizable()
            .interpolation(.high)
            .antialiased(true)
            .scaledToFit()
            .frame(width: 36, height: 36)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    @ViewBuilder
    private var sidebarHeaderIconButtons: some View {
        if isSidebarCollapsed {
            VStack(spacing: 8) {
                premiumButton
                settingsIconButton
                sidebarToggleButton
            }
        } else {
            HStack(spacing: 8) {
                premiumButton
                settingsIconButton
                sidebarToggleButton
            }
        }
    }

    private var premiumButton: some View {
        Button {
            isShowingSettings = true
        } label: {
            Image(systemName: viewModel.isPremiumUnlocked ? "checkmark.seal.fill" : "lock.fill")
                .frame(width: 18, height: 18)
        }
        .buttonStyle(SidebarIconButtonStyle(isEmphasized: viewModel.isPremiumUnlocked))
        .help(viewModel.isPremiumUnlocked ? language.premiumUnlockedTitle : language.premiumLockedTitle)
    }

    private var settingsIconButton: some View {
        Button {
            isShowingSettings = true
        } label: {
            Image(systemName: "gearshape")
                .frame(width: 18, height: 18)
        }
        .buttonStyle(SidebarIconButtonStyle())
        .help(language.settingsButtonTitle)
    }

    private var sidebarToggleButton: some View {
        Button {
            isSidebarCollapsed.toggle()
        } label: {
            Image(systemName: isSidebarCollapsed ? "chevron.right" : "chevron.left")
                .frame(width: 18, height: 18)
        }
        .buttonStyle(SidebarIconButtonStyle())
        .help(language.profilesTitle)
    }

    private func showPremiumSettings() {
        shouldFocusPremiumSettings = true
        isShowingSettings = true
    }

    private var sidebarProfiles: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !isSidebarCollapsed {
                Text(language.profilesTitle)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
            }

            VStack(spacing: 6) {
                ForEach(viewModel.profiles) { profile in
                    sidebarProfileRow(profile)
                }
            }

            Group {
                if isSidebarCollapsed {
                    VStack(spacing: 8) {
                        newProfileButton
                        presetsMenu
                    }
                } else {
                    HStack(spacing: 8) {
                        newProfileButton
                        presetsMenu
                    }
                }
            }
        }
    }

    private func sidebarProfileRow(_ profile: KeyLaunchProfile) -> some View {
        let isSelected = profile.id == viewModel.activeProfileID
        let isUsedProfile = isSelected || !profile.assignedApplications.isEmpty

        return HStack(spacing: 6) {
            Button {
                viewModel.switchProfile(profile)
            } label: {
                sidebarRowLabel(
                    title: profile.name,
                    systemImage: profile.isDefault ? "house.fill" : "person.crop.square",
                    trailingSystemImages: sidebarProfileBadges(isUsedProfile: isUsedProfile)
                )
            }
            .buttonStyle(SidebarRowButtonStyle(isActive: isSelected))
            .help(profile.name)

            if !isSidebarCollapsed {
                HStack(spacing: 4) {
                    Button {
                        beginRenaming(profile)
                    } label: {
                        Image(systemName: "pencil")
                            .frame(width: 14, height: 14)
                    }
                    .buttonStyle(SidebarInlineIconButtonStyle())
                    .disabled(!viewModel.isPremiumUnlocked)
                    .help(language.renameProfileTitle)

                    Button {
                        profilePendingDeletion = profile
                    } label: {
                        Image(systemName: "trash")
                            .frame(width: 14, height: 14)
                    }
                    .buttonStyle(SidebarInlineIconButtonStyle())
                    .disabled(!viewModel.canDeleteProfile(profile))
                    .help(language.deleteProfileTitle)
                }
                .opacity(isSelected ? 1 : 0.72)
            }
        }
    }

    private func sidebarProfileBadges(isUsedProfile: Bool) -> [String] {
        isUsedProfile ? ["bolt.fill"] : []
    }

    private func beginRenaming(_ profile: KeyLaunchProfile) {
        profileNameDraft = profile.name
        profileBeingRenamed = profile
    }

    private var newProfileButton: some View {
        Button {
            if viewModel.isPremiumUnlocked {
                viewModel.createProfile()
            } else {
                showPremiumSettings()
            }
        } label: {
            sidebarCompactActionLabel(title: language.newProfileTitle, systemImage: "plus")
        }
        .buttonStyle(SidebarActionButtonStyle(isDimmed: !viewModel.isPremiumUnlocked))
        .help(language.newProfileTitle)
    }

    @ViewBuilder
    private var presetsMenu: some View {
        if viewModel.isPremiumUnlocked {
            Menu {
                ForEach(KeyLaunchPreset.all) { preset in
                    Button {
                        viewModel.createProfile(from: preset)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(preset.name)
                            Text(preset.detail)
                        }
                    }
                }
            } label: {
                sidebarCompactActionLabel(title: language.presetsTitle, systemImage: "sparkles")
            }
            .menuStyle(.borderlessButton)
            .buttonStyle(SidebarActionButtonStyle(isDimmed: false))
            .help(language.presetsTitle)
        } else {
            Button {
                showPremiumSettings()
            } label: {
                sidebarCompactActionLabel(title: language.presetsTitle, systemImage: "sparkles")
            }
            .buttonStyle(SidebarActionButtonStyle(isDimmed: true))
            .help(language.presetsTitle)
        }
    }

    private var sidebarAssignedApplications: some View {
        VStack(alignment: .leading, spacing: 10) {
            Divider()

            HStack {
                Text(language.assignedApplicationsTitle)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    if viewModel.isPremiumUnlocked {
                        viewModel.chooseApplicationForActiveProfile()
                    } else {
                        showPremiumSettings()
                    }
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 16, height: 16)
                }
                .buttonStyle(.borderless)
                .help(language.assignApplicationTitle)
            }
            .padding(.horizontal, 10)

            if viewModel.activeAssignedApplications.isEmpty {
                Text(language.noAssignedApplicationsTitle)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                VStack(spacing: 6) {
                    ForEach(viewModel.activeAssignedApplications, id: \.id) { target in
                        HStack(spacing: 10) {
                            ApplicationIconView(target: target, size: 20)

                            Text(target.displayName)
                                .font(.system(size: 13, weight: .medium))
                                .lineLimit(1)

                            Spacer()

                            Button {
                                viewModel.removeAssignedApplication(target)
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .buttonStyle(.borderless)
                            .foregroundStyle(.secondary)
                            .disabled(!viewModel.isPremiumUnlocked)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(nsColor: .controlBackgroundColor).opacity(0.62))
                        )
                    }
                }
            }
        }
    }

    private func sidebarRowLabel(
        title: String,
        systemImage: String,
        trailingSystemImages: [String] = []
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .semibold))
                .frame(width: 22, height: 22)

            if !isSidebarCollapsed {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .lineLimit(1)

                Spacer(minLength: 8)

                if !trailingSystemImages.isEmpty {
                    HStack(spacing: 5) {
                        ForEach(trailingSystemImages, id: \.self) { trailingSystemImage in
                            Image(systemName: trailingSystemImage)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: isSidebarCollapsed ? .center : .leading)
    }

    private func sidebarCompactActionLabel(title: String, systemImage: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .semibold))
                .frame(width: 18, height: 18)

            if !isSidebarCollapsed {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)

                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: isSidebarCollapsed ? .center : .leading)
    }

    private var configurationSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(language.createKeybindTitle)
                .font(.system(size: 18, weight: .semibold))

            HStack(alignment: .top, spacing: 16) {
                sourceCard
                Image(systemName: "arrow.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 20, alignment: .center)
                    .padding(.top, 34)
                targetCard
            }

            HStack(spacing: 12) {
                Button {
                    viewModel.saveCurrentMapping()
                } label: {
                    Text(language.saveKeybindTitle)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(KeyLaunchPrimaryButtonStyle())
                .disabled(!viewModel.canSave)

                Button {
                    viewModel.resetComposer()
                } label: {
                    Text(language.resetTitle)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(KeyLaunchSecondaryButtonStyle())
            }
        }
        .sectionCardStyle()
    }

    private var sourceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(language.keyTitle, systemImage: "keyboard")
                .font(.system(size: 14, weight: .semibold))

            Menu {
                ForEach(SourceKey.allKeys) { key in
                    Button {
                        viewModel.selectKey(key)
                    } label: {
                        HStack {
                            Text(key.displayName)

                            if viewModel.selectedKey == key {
                                Spacer()
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Text(viewModel.selectedKey?.displayName ?? language.chooseKeyTitle)
                        .foregroundStyle(viewModel.selectedKey == nil ? .secondary : .primary)

                    Spacer(minLength: 12)

                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(nsColor: .controlBackgroundColor))
                )
            }
            .menuStyle(.borderlessButton)
            .buttonStyle(.plain)

            Text(
                viewModel.selectedKey == nil
                    ? language.chooseFunctionKeyDetail
                    : language.selectedKeyDetail(viewModel.selectedKey?.displayName ?? "")
            )
            .font(.system(size: 12))
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 128, alignment: .topLeading)
        .panelStyle()
    }

    private var targetCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(language.functionTitle, systemImage: "slider.horizontal.3")
                .font(.system(size: 14, weight: .semibold))

            Picker(
                language.actionTypeTitle,
                selection: Binding(
                    get: { viewModel.selectedActionMode },
                    set: { viewModel.selectActionMode($0) }
                )
            ) {
                Text(language.systemFunctionTitle).tag(KeyLaunchViewModel.ActionMode.systemFunction)
                Text(language.openApplicationTitle).tag(KeyLaunchViewModel.ActionMode.openApplication)
                Label(
                    language.openWebsiteTitle,
                    systemImage: viewModel.isPremiumUnlocked ? "globe" : "lock.fill"
                )
                    .tag(KeyLaunchViewModel.ActionMode.openWebsite)
            }
            .pickerStyle(.menu)
            .tint(.primary)
            .frame(maxWidth: 220, alignment: .leading)

            if !viewModel.isPremiumUnlocked {
                freeUsageSummary
            }

            switch viewModel.selectedActionMode {
            case .systemFunction:
                Picker(language.functionTitle, selection: $viewModel.selectedAction) {
                    ForEach(RemapAction.allCases) { action in
                        Text(action.title(in: language)).tag(action)
                    }
                }
                .pickerStyle(.menu)

            case .openApplication:
                HStack(spacing: 10) {
                    Button {
                        viewModel.chooseApplication()
                    } label: {
                        Label(language.chooseApplicationTitle, systemImage: "app.badge")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(KeyLaunchSecondaryButtonStyle())

                    if let selectedApplication = viewModel.selectedApplication {
                        Text(selectedApplication.displayName)
                            .font(.system(size: 13, weight: .medium))
                            .lineLimit(1)
                    }
                }

            case .openWebsite:
                VStack(alignment: .leading, spacing: 8) {
                    TextField(language.websiteURLPlaceholder, text: $viewModel.websiteURLString)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13, weight: .medium))
                        .padding(.horizontal, 12)
                        .frame(height: 34)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.white.opacity(0.08))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .stroke(Color.white.opacity(0.08), lineWidth: 1)
                        )

                    HStack(spacing: 6) {
                        Image(systemName: "safari")
                            .font(.system(size: 10, weight: .semibold))

                        Text(language.websiteURLHelp)
                            .lineLimit(1)
                    }
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 128, alignment: .topLeading)
        .panelStyle()
    }

    private var freeUsageSummary: some View {
        Button {
            showPremiumSettings()
        } label: {
            HStack(spacing: 8) {
                usageText(language.systemFunctionTitle, usage: viewModel.systemFunctionUsage)

                Text("·")
                    .foregroundStyle(.tertiary)

                usageText(language.openApplicationTitle, usage: viewModel.openApplicationUsage, showsLock: true)
            }
        }
        .buttonStyle(.plain)
        .help(language.premiumLockedTitle)
    }

    private func usageText(
        _ title: String,
        usage: (used: Int, limit: Int),
        showsLock: Bool = false
    ) -> some View {
        HStack(spacing: 4) {
            Text(title)
                .lineLimit(1)

            Text("\(usage.used)/\(usage.limit)")
                .fontWeight(.semibold)

            if showsLock {
                Image(systemName: "lock.fill")
                    .font(.system(size: 8, weight: .bold))
            }
        }
        .font(.system(size: 11, weight: .medium))
        .foregroundStyle(.secondary)
    }

    private var mappingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(language.savedKeybindsTitle)
                .font(.system(size: 18, weight: .semibold))

            if viewModel.savedMappings.isEmpty {
                Text(language.noKeybindsTitle)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            } else {
                ForEach(viewModel.savedMappings) { mapping in
                    HStack(spacing: 12) {
                        Text(mapping.source.displayName)
                            .font(.system(size: 14, weight: .semibold))
                            .frame(minWidth: 110, alignment: .leading)

                        Image(systemName: "arrow.right")
                            .foregroundStyle(.secondary)

                        mappingActionIcon(for: mapping.action)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(mapping.action.title(in: language))
                                .font(.system(size: 14, weight: .medium))
                            Text(mapping.summary(in: language))
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Button {
                            viewModel.removeMapping(mapping)
                        } label: {
                            Image(systemName: "trash")
                        }
                        .buttonStyle(.borderless)
                        .foregroundStyle(.secondary)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(Color(nsColor: .controlBackgroundColor))
                    )
                }
            }
        }
        .sectionCardStyle()
    }

    @ViewBuilder
    private func mappingActionIcon(for action: KeybindAction) -> some View {
        if let target = action.applicationTarget {
            ApplicationIconView(target: target, size: 24)
        } else if action.websiteTarget != nil {
            Image(systemName: "globe")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 24, height: 24)
        }
    }
}

#Preview {
    ContentView()
}

private extension View {
    func sectionCardStyle() -> some View {
        padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color(nsColor: .separatorColor).opacity(0.35), lineWidth: 1)
            )
    }

    func panelStyle(isActive: Bool = false) -> some View {
        padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(nsColor: .textBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(
                        isActive ? Color.primary.opacity(0.45) : Color(nsColor: .separatorColor).opacity(0.25),
                        lineWidth: isActive ? 1.5 : 1
                    )
            )
    }
}

private struct ApplicationIconView: View {
    let target: ApplicationLaunchTarget
    let size: CGFloat

    var body: some View {
        Group {
            if FileManager.default.fileExists(atPath: target.url.path) {
                Image(nsImage: NSWorkspace.shared.icon(forFile: target.url.path))
                    .resizable()
            } else {
                Image(systemName: "app")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.secondary)
                    .padding(size * 0.16)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
    }
}

private struct KeyLaunchPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold))
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(configuration.isPressed ? Color.primary.opacity(0.82) : Color.primary)
            .foregroundStyle(Color(nsColor: .windowBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private struct KeyLaunchSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold))
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color(nsColor: .separatorColor).opacity(0.4), lineWidth: 1)
            )
            .foregroundStyle(.primary)
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

private struct SidebarRowButtonStyle: ButtonStyle {
    let isActive: Bool
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .foregroundStyle(isActive ? Color(nsColor: .windowBackgroundColor) : .primary)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(backgroundColor(isPressed: configuration.isPressed))
            )
            .opacity(isEnabled ? 1 : 0.48)
    }

    private func backgroundColor(isPressed: Bool) -> Color {
        if isActive {
            return isPressed ? Color.primary.opacity(0.82) : Color.primary
        }

        return isPressed
            ? Color(nsColor: .controlBackgroundColor).opacity(0.92)
            : Color.clear
    }
}

private struct SidebarActionButtonStyle: ButtonStyle {
    var isDimmed = false
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .foregroundStyle(isDimmed ? .secondary : .primary)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(configuration.isPressed ? Color.primary.opacity(0.12) : Color(nsColor: .controlBackgroundColor).opacity(isDimmed ? 0.36 : 0.62))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color(nsColor: .separatorColor).opacity(0.28), lineWidth: 1)
            )
            .opacity(isEnabled ? (isDimmed ? 0.62 : 1) : 0.46)
    }
}

private struct SidebarIconButtonStyle: ButtonStyle {
    var isEmphasized = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold))
            .padding(7)
            .foregroundStyle(isEmphasized ? Color(nsColor: .windowBackgroundColor) : .primary)
            .background(
                Circle()
                    .fill(backgroundColor(isPressed: configuration.isPressed))
            )
    }

    private func backgroundColor(isPressed: Bool) -> Color {
        if isEmphasized {
            return isPressed ? Color.primary.opacity(0.82) : Color.primary
        }

        return isPressed
            ? Color.primary.opacity(0.14)
            : Color(nsColor: .controlBackgroundColor).opacity(0.72)
    }
}

private struct SidebarInlineIconButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 11, weight: .semibold))
            .padding(7)
            .foregroundStyle(.secondary)
            .background(
                Circle()
                    .fill(configuration.isPressed ? Color.primary.opacity(0.14) : Color.clear)
            )
            .opacity(isEnabled ? 1 : 0.28)
    }
}

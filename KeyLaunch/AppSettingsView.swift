import AppKit
import SwiftUI

struct AppSettingsView: View {
    @ObservedObject var permissions: PermissionCenter
    @ObservedObject var viewModel: KeyLaunchViewModel
    var focusPremium = false
    let onClose: () -> Void
    @StateObject private var accountManager = AccountManager.shared
    @AppStorage(AppLanguage.storageKey) private var appLanguageRawValue = AppLanguage.english.rawValue
    @State private var accountMode: AccountMode = .login
    @State private var isShowingAccountSheet = false
    @State private var isShowingDeleteAccountSheet = false
    @State private var isShowingDeleteAccountLoginSheet = false
    @State private var isShowingLicenseSheet = false
    @State private var isShowingLogoutConfirmation = false
    @State private var accountEmail = ""
    @State private var accountPassword = ""
    @State private var accountPasswordConfirmation = ""
    @State private var accountStatusMessage = ""
    @State private var deleteAccountEmail = ""
    @State private var deleteAccountPassword = ""
    @State private var deleteAccountStatusMessage = ""
    @State private var licenseKey = ""
    @State private var licenseStatusMessage = ""
    @State private var isSubmittingAccountAction = false
    @State private var isDeletingAccount = false
    @State private var isActivatingLicense = false

    private let contentMaxWidth: CGFloat = 980
    private let topCardMinHeight: CGFloat = 116
    private let gumroadProductURL = URL(string: "https://driftwood155.gumroad.com/l/keylaunch-premium")!

    private var language: AppLanguage {
        AppLanguage(rawValue: appLanguageRawValue) ?? .english
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color(nsColor: .windowBackgroundColor)
                .ignoresSafeArea()

            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(language.settingsTitle)
                                .font(.system(size: 28, weight: .bold))
                        }
                        .padding(.trailing, 56)

                        HStack(alignment: .top, spacing: 16) {
                            languageCard
                            accountCard
                        }

                        premiumCard
                        .id("premium")

                        VStack(alignment: .leading, spacing: 16) {
                            Text(language.systemStatusTitle)
                                .font(.system(size: 18, weight: .semibold))

                            permissionSummaryCard
                            accessibilityCard
                            backgroundStartCard

                            Button(language.refreshStatusTitle) {
                                permissions.refresh()
                                viewModel.refreshBackgroundStartStatus()
                            }
                            .buttonStyle(SettingsPrimaryButtonStyle())

                            Button(language.checkForUpdatesTitle) {
                                UpdateManager.shared.checkForUpdates()
                            }
                            .buttonStyle(SettingsSecondaryButtonStyle())

                            Text(language.storageDetail)
                                .font(.system(size: 12))
                                .foregroundStyle(.secondary)
                        }
                        .settingsCardStyle()

                        settingsFooter

                        // TEMPORARY TEST PREMIUM RESET: remove this button when Firebase license activation is connected.
                        Button(language.resetPremiumTitle) {
                            viewModel.resetPremiumUnlock()
                        }
                        .buttonStyle(SettingsSecondaryButtonStyle())
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 22)
                    .padding(.bottom, 28)
                    .frame(maxWidth: contentMaxWidth, alignment: .topLeading)
                    .frame(maxWidth: .infinity, alignment: .top)
                }
                .onAppear {
                    guard focusPremium else {
                        return
                    }

                    DispatchQueue.main.async {
                        proxy.scrollTo("premium", anchor: .top)
                    }
                }
            }

            Button {
                onClose()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .frame(width: 34, height: 34)
            }
            .buttonStyle(.borderless)
            .foregroundStyle(.secondary)
            .background(
                Circle()
                    .fill(Color(nsColor: .windowBackgroundColor).opacity(0.72))
            )
            .padding(.top, 22)
            .padding(.trailing, 22)
        }
        .onAppear {
            permissions.refresh()
            viewModel.refreshBackgroundStartStatus()
            accountManager.startListening()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            permissions.refresh()
            viewModel.refreshBackgroundStartStatus()
        }
        .sheet(isPresented: $isShowingAccountSheet) {
            accountSheet
        }
        .sheet(isPresented: $isShowingLicenseSheet) {
            licenseSheet
        }
        .sheet(isPresented: $isShowingDeleteAccountSheet) {
            deleteAccountSheet
        }
        .sheet(isPresented: $isShowingDeleteAccountLoginSheet) {
            deleteAccountLoginSheet
        }
        .alert(language.logoutConfirmationTitle, isPresented: $isShowingLogoutConfirmation) {
            Button(language.logoutTitle, role: .destructive) {
                signOut()
            }

            Button(language.cancelTitle, role: .cancel) {}
        } message: {
            Text(language.logoutConfirmationDetail)
        }
    }

    private var languageCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(language.languageSectionTitle)
                .font(.system(size: 18, weight: .semibold))

            Picker(language.languagePickerTitle, selection: $appLanguageRawValue) {
                ForEach(AppLanguage.allCases) { language in
                    Text(language.displayName).tag(language.rawValue)
                }
            }
            .pickerStyle(.segmented)

            Text(language.languageDetail)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: topCardMinHeight, alignment: .topLeading)
        .compactSettingsCardStyle()
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private var accountCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(language.accountTitle)
                .font(.system(size: 18, weight: .semibold))

            if accountManager.isSignedIn {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(accountManager.email ?? language.signedInAccountDetail)
                            .font(.system(size: 13, weight: .semibold))
                            .lineLimit(1)
                            .truncationMode(.middle)

                        Text(viewModel.isPremiumUnlocked ? language.premiumAccountTitle : language.freeAccountTitle)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 8)

                    HStack(spacing: 8) {
                        Button {
                            showLicenseSheet()
                        } label: {
                            Image(systemName: "key")
                                .frame(width: 16, height: 16)
                        }
                        .buttonStyle(SettingsIconButtonStyle())
                        .help(language.activateLicenseTitle)

                        Button {
                            isShowingLogoutConfirmation = true
                        } label: {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .frame(width: 16, height: 16)
                        }
                        .buttonStyle(SettingsIconButtonStyle())
                        .help(language.logoutTitle)

                        Button {
                            isShowingDeleteAccountSheet = true
                        } label: {
                            Image(systemName: "trash")
                                .frame(width: 16, height: 16)
                        }
                        .buttonStyle(SettingsIconButtonStyle())
                        .help(language.deleteAccountTitle)
                    }
                }
            } else {
                Text(language.accountDetail)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    Button(language.loginTitle) {
                        showAccountSheet(.login)
                    }
                    .buttonStyle(SettingsPrimaryButtonStyle())

                    Button(language.registerTitle) {
                        showAccountSheet(.register)
                    }
                    .buttonStyle(SettingsSecondaryButtonStyle())
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: topCardMinHeight, alignment: .topLeading)
        .compactSettingsCardStyle()
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private var premiumCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(language.premiumTitle)
                .font(.system(size: 18, weight: .semibold))

            HStack(spacing: 14) {
                Image(systemName: viewModel.isPremiumUnlocked ? "checkmark.seal.fill" : "lock.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.primary)

                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.isPremiumUnlocked ? language.premiumUnlockedTitle : language.premiumLockedTitle)
                        .font(.system(size: 14, weight: .semibold))

                    Text(language.premiumDetail)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 12)

                if !viewModel.isPremiumUnlocked {
                    HStack(spacing: 8) {
                        Button(language.buyPremiumTitle) {
                            NSWorkspace.shared.open(gumroadProductURL)
                        }
                        .buttonStyle(SettingsSecondaryButtonStyle())

                        Button(language.activateLicenseTitle) {
                            showLicenseSheet()
                        }
                        .buttonStyle(SettingsPrimaryButtonStyle())
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(nsColor: .textBackgroundColor))
            )
        }
        .settingsCardStyle()
    }

    private var accountSheet: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(language.accountTitle)
                        .font(.system(size: 24, weight: .bold))

                    Text(language.accountSheetDetail)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    isShowingAccountSheet = false
                } label: {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.borderless)
            }

            Picker(language.accountTitle, selection: $accountMode) {
                Text(language.loginTitle).tag(AccountMode.login)
                Text(language.registerTitle).tag(AccountMode.register)
            }
            .pickerStyle(.segmented)

            VStack(alignment: .leading, spacing: 10) {
                TextField(language.emailTitle, text: $accountEmail)
                    .textFieldStyle(.roundedBorder)

                SecureField(language.passwordTitle, text: $accountPassword)
                    .textFieldStyle(.roundedBorder)

                if accountMode == .register {
                    SecureField(language.confirmPasswordTitle, text: $accountPasswordConfirmation)
                        .textFieldStyle(.roundedBorder)
                }
            }

            if !accountStatusMessage.isEmpty {
                Text(accountStatusMessage)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Button(accountMode == .login ? language.loginTitle : language.createAccountTitle) {
                switch accountMode {
                case .login:
                    submitLogin()
                case .register:
                    submitRegistration()
                }
            }
            .buttonStyle(SettingsPrimaryButtonStyle())
            .disabled(isSubmittingAccountAction)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(24)
        .frame(width: 420)
    }

    private var licenseSheet: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(language.activateLicenseTitle)
                        .font(.system(size: 24, weight: .bold))

                    Text(language.licenseSheetDetail)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    isShowingLicenseSheet = false
                } label: {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.borderless)
            }

            if accountManager.isSignedIn {
                VStack(alignment: .leading, spacing: 10) {
                    TextField(language.licenseKeyTitle, text: $licenseKey)
                        .textFieldStyle(.roundedBorder)

                    licenseWarningBox
                }

                if !licenseStatusMessage.isEmpty {
                    Text(licenseStatusMessage)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Button(language.buyPremiumTitle) {
                        NSWorkspace.shared.open(gumroadProductURL)
                    }
                    .buttonStyle(SettingsSecondaryButtonStyle())

                    Spacer()

                    Button(language.activateLicenseTitle) {
                        activateLicense()
                    }
                    .buttonStyle(SettingsPrimaryButtonStyle())
                    .disabled(isActivatingLicense)
                }
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 20, weight: .semibold))

                    Text(language.licenseLoginRequiredTitle)
                        .font(.system(size: 15, weight: .semibold))

                    Text(language.licenseLoginRequiredDetail)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(nsColor: .textBackgroundColor))
                )

                HStack {
                    Button(language.loginTitle) {
                        isShowingLicenseSheet = false
                        showAccountSheet(.login)
                    }
                    .buttonStyle(SettingsPrimaryButtonStyle())

                    Button(language.registerTitle) {
                        isShowingLicenseSheet = false
                        showAccountSheet(.register)
                    }
                    .buttonStyle(SettingsSecondaryButtonStyle())
                }
            }
        }
        .padding(24)
        .frame(width: 460)
    }

    private var licenseWarningBox: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.orange)

            VStack(alignment: .leading, spacing: 4) {
                Text(language.licenseOneTimeWarningTitle)
                    .font(.system(size: 13, weight: .semibold))

                Text(language.licenseOneTimeWarningDetail)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.orange.opacity(0.12))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.orange.opacity(0.35), lineWidth: 1)
        )
    }

    private var deleteAccountSheet: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.red)

                VStack(alignment: .leading, spacing: 6) {
                    Text(language.deleteAccountConfirmationTitle)
                        .font(.system(size: 24, weight: .bold))

                    Text(language.deleteAccountPremiumWarningDetail)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Label(language.deleteAccountRemovesAccountTitle, systemImage: "person.crop.circle.badge.xmark")
                Label(language.deleteAccountRemovesPremiumTitle, systemImage: "key.slash")
                Label(language.deleteAccountLicenseReuseTitle, systemImage: "lock.trianglebadge.exclamationmark")
            }
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.primary)
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.red.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.red.opacity(0.28), lineWidth: 1)
            )

            HStack {
                Button(language.cancelTitle) {
                    isShowingDeleteAccountSheet = false
                }
                .buttonStyle(SettingsSecondaryButtonStyle())

                Spacer()

                Button(language.deleteAccountTitle) {
                    isShowingDeleteAccountSheet = false
                    deleteAccount()
                }
                .buttonStyle(SettingsDestructiveButtonStyle())
            }
        }
        .padding(24)
        .frame(width: 480)
    }

    private var deleteAccountLoginSheet: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(language.confirmAccountDeletionTitle)
                        .font(.system(size: 24, weight: .bold))

                    Text(language.confirmAccountDeletionDetail)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Button {
                    isShowingDeleteAccountLoginSheet = false
                    clearDeleteAccountFields()
                } label: {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.borderless)
            }

            VStack(alignment: .leading, spacing: 10) {
                TextField(language.emailTitle, text: $deleteAccountEmail)
                    .textFieldStyle(.roundedBorder)

                SecureField(language.passwordTitle, text: $deleteAccountPassword)
                    .textFieldStyle(.roundedBorder)
            }

            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.red)

                Text(language.confirmAccountDeletionWarning)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.red.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.red.opacity(0.28), lineWidth: 1)
            )

            if !deleteAccountStatusMessage.isEmpty {
                Text(deleteAccountStatusMessage)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            HStack {
                Button(language.cancelTitle) {
                    isShowingDeleteAccountLoginSheet = false
                    clearDeleteAccountFields()
                }
                .buttonStyle(SettingsSecondaryButtonStyle())

                Spacer()

                Button(language.loginAndDeleteAccountTitle) {
                    confirmAccountDeletion()
                }
                .buttonStyle(SettingsDestructiveButtonStyle())
                .disabled(isDeletingAccount)
            }
        }
        .padding(24)
        .frame(width: 460)
    }

    private var settingsFooter: some View {
        HStack(spacing: 8) {
            Text(appVersionText)

            Text("·")

            Link("support@keylaunch.org", destination: URL(string: "mailto:support@keylaunch.org")!)
        }
        .font(.system(size: 11, weight: .medium))
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, 2)
    }

    private var appVersionText: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String

        switch (version, build) {
        case let (version?, build?):
            return "KeyLaunch \(version) (\(build))"
        case let (version?, nil):
            return "KeyLaunch \(version)"
        default:
            return "KeyLaunch"
        }
    }

    private var permissionSummaryCard: some View {
        HStack(spacing: 14) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.primary)

            VStack(alignment: .leading, spacing: 4) {
                Text(permissions.summaryTitle(in: language))
                    .font(.system(size: 14, weight: .semibold))

                Text(permissions.summaryDetail(in: language))
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(language.activeTitle)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color(nsColor: .textBackgroundColor))
                )
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .textBackgroundColor))
        )
    }

    private var accessibilityCard: some View {
        HStack(spacing: 14) {
            Image(systemName: permissions.isAccessibilityTrusted ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.primary)

            VStack(alignment: .leading, spacing: 4) {
                Text(permissions.isAccessibilityTrusted ? language.accessibilityGrantedTitle : language.accessibilityMissingTitle)
                    .font(.system(size: 14, weight: .semibold))

                Text(language.accessibilityDetail)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if !permissions.isAccessibilityTrusted {
                Button(language.requestAccessibilityTitle) {
                    permissions.requestAccessibility()
                }
                .buttonStyle(SettingsPrimaryButtonStyle())
            } else {
                Text(language.activeTitle)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color(nsColor: .textBackgroundColor))
                    )
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .textBackgroundColor))
        )
    }

    private var backgroundStartCard: some View {
        HStack(spacing: 14) {
            Image(systemName: viewModel.isBackgroundStartEnabled ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.primary)

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.isBackgroundStartEnabled ? language.backgroundStartEnabledTitle : language.backgroundStartMissingTitle)
                    .font(.system(size: 14, weight: .semibold))

                Text(language.backgroundStartDetail)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if viewModel.isBackgroundStartEnabled {
                Button(language.disableBackgroundStartTitle) {
                    viewModel.disableBackgroundStart()
                }
                .buttonStyle(SettingsSecondaryButtonStyle())
            } else {
                Button(language.enableBackgroundStartTitle) {
                    viewModel.enableBackgroundStart()
                }
                .buttonStyle(SettingsPrimaryButtonStyle())
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .textBackgroundColor))
        )
    }

    private func showAccountSheet(_ mode: AccountMode) {
        accountMode = mode
        accountStatusMessage = ""
        accountPassword = ""
        accountPasswordConfirmation = ""
        isShowingAccountSheet = true
    }

    private func showLicenseSheet() {
        licenseKey = ""
        licenseStatusMessage = accountManager.isSignedIn ? "" : language.licenseLoginRequiredTitle
        isShowingLicenseSheet = true
    }

    private func submitLogin() {
        guard canSubmitAccountCredentials(requireConfirmation: false) else {
            return
        }

        accountStatusMessage = language.accountFirebasePendingTitle
        isSubmittingAccountAction = true

        Task {
            do {
                try await accountManager.signIn(email: accountEmail.trimmingCharacters(in: .whitespacesAndNewlines), password: accountPassword)
                accountStatusMessage = language.accountSignedInTitle
                clearAccountFields()
                isShowingAccountSheet = false
            } catch {
                accountStatusMessage = error.localizedDescription
            }

            isSubmittingAccountAction = false
        }
    }

    private func submitRegistration() {
        guard canSubmitAccountCredentials(requireConfirmation: true) else {
            return
        }

        accountStatusMessage = language.accountFirebasePendingTitle
        isSubmittingAccountAction = true

        Task {
            do {
                try await accountManager.createAccount(email: accountEmail.trimmingCharacters(in: .whitespacesAndNewlines), password: accountPassword)
                accountStatusMessage = language.accountCreatedTitle
                clearAccountFields()
                isShowingAccountSheet = false
            } catch {
                accountStatusMessage = error.localizedDescription
            }

            isSubmittingAccountAction = false
        }
    }

    private func signOut() {
        do {
            try accountManager.signOut()
            viewModel.resetPremiumUnlock()
            accountStatusMessage = language.accountSignedOutTitle
            licenseStatusMessage = ""
        } catch {
            accountStatusMessage = error.localizedDescription
        }
    }

    private func deleteAccount() {
        Task {
            do {
                try await accountManager.deleteAccount()
                viewModel.resetPremiumUnlock()
                accountStatusMessage = language.accountDeletedTitle
                licenseStatusMessage = ""
            } catch {
                if let deletionError = error as? AccountDeletionError,
                   deletionError == .requiresRecentLogin {
                    showDeleteAccountLoginSheet()
                } else {
                    accountStatusMessage = error.localizedDescription
                    showDeleteAccountLoginSheet(statusMessage: error.localizedDescription)
                }
            }
        }
    }

    private func showDeleteAccountLoginSheet(statusMessage: String? = nil) {
        deleteAccountEmail = accountManager.email ?? ""
        deleteAccountPassword = ""
        deleteAccountStatusMessage = statusMessage ?? language.deleteAccountRequiresRecentLoginTitle
        isShowingDeleteAccountLoginSheet = true
    }

    private func confirmAccountDeletion() {
        let trimmedEmail = deleteAccountEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty, !deleteAccountPassword.isEmpty else {
            deleteAccountStatusMessage = language.accountMissingFieldsTitle
            return
        }

        deleteAccountStatusMessage = language.accountFirebasePendingTitle
        isDeletingAccount = true

        Task {
            do {
                try await accountManager.reauthenticateAndDeleteAccount(email: trimmedEmail, password: deleteAccountPassword)
                viewModel.resetPremiumUnlock()
                accountStatusMessage = language.accountDeletedTitle
                licenseStatusMessage = ""
                isShowingDeleteAccountLoginSheet = false
                clearDeleteAccountFields()
            } catch {
                deleteAccountStatusMessage = error.localizedDescription
            }

            isDeletingAccount = false
        }
    }

    private func activateLicense() {
        let trimmedLicenseKey = licenseKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedLicenseKey.isEmpty else {
            licenseStatusMessage = language.licenseMissingKeyTitle
            return
        }

        licenseStatusMessage = language.licenseActivationPendingTitle
        isActivatingLicense = true

        Task {
            do {
                try await accountManager.activateLicense(trimmedLicenseKey)
                licenseStatusMessage = language.licenseActivatedTitle
                licenseKey = ""
                isShowingLicenseSheet = false
            } catch {
                licenseStatusMessage = error.localizedDescription
            }

            isActivatingLicense = false
        }
    }

    private func canSubmitAccountCredentials(requireConfirmation: Bool) -> Bool {
        let trimmedEmail = accountEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty, !accountPassword.isEmpty else {
            accountStatusMessage = language.accountMissingFieldsTitle
            return false
        }

        guard !requireConfirmation || accountPassword == accountPasswordConfirmation else {
            accountStatusMessage = language.accountPasswordsDoNotMatchTitle
            return false
        }

        return true
    }

    private func clearAccountFields() {
        accountEmail = ""
        accountPassword = ""
        accountPasswordConfirmation = ""
    }

    private func clearDeleteAccountFields() {
        deleteAccountEmail = ""
        deleteAccountPassword = ""
        deleteAccountStatusMessage = ""
    }
}

private enum AccountMode: String, Hashable {
    case login
    case register
}

private extension View {
    func settingsCardStyle() -> some View {
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

    func compactSettingsCardStyle() -> some View {
        padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color(nsColor: .separatorColor).opacity(0.35), lineWidth: 1)
            )
    }
}

private struct SettingsPrimaryButtonStyle: ButtonStyle {
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

private struct SettingsSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold))
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(configuration.isPressed ? Color.primary.opacity(0.12) : Color(nsColor: .controlBackgroundColor))
            )
            .foregroundStyle(.primary)
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color(nsColor: .separatorColor).opacity(0.4), lineWidth: 1)
            )
    }
}

private struct SettingsIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.primary)
            .frame(width: 32, height: 32)
            .background(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(configuration.isPressed ? Color.primary.opacity(0.14) : Color(nsColor: .controlBackgroundColor))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .stroke(Color(nsColor: .separatorColor).opacity(0.4), lineWidth: 1)
            )
    }
}

private struct SettingsDestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .semibold))
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(configuration.isPressed ? Color.red.opacity(0.8) : Color.red)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

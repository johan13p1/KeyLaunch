import AppKit
import SwiftUI

struct AppSettingsView: View {
    @ObservedObject var permissions: PermissionCenter
    @ObservedObject var viewModel: KeyLaunchViewModel
    let onClose: () -> Void
    @AppStorage(AppLanguage.storageKey) private var appLanguageRawValue = AppLanguage.english.rawValue

    private let contentMaxWidth: CGFloat = 980
    private let topCardMinHeight: CGFloat = 116

    private var language: AppLanguage {
        AppLanguage(rawValue: appLanguageRawValue) ?? .english
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color(nsColor: .windowBackgroundColor)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(language.settingsTitle)
                            .font(.system(size: 28, weight: .bold))
                    }
                    .padding(.trailing, 56)

                    languageCard

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
                }
                .padding(.horizontal, 20)
                .padding(.top, 22)
                .padding(.bottom, 28)
                .frame(maxWidth: contentMaxWidth, alignment: .topLeading)
                .frame(maxWidth: .infinity, alignment: .top)
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
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            permissions.refresh()
            viewModel.refreshBackgroundStartStatus()
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

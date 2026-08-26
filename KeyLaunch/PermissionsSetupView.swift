import AppKit
import Combine
import SwiftUI

struct PermissionsSetupView: View {
    @ObservedObject var permissions: PermissionCenter
    @ObservedObject var viewModel: KeyLaunchViewModel
    let onContinue: () -> Void
    @State private var isShowingAccessibilityWarning = false
    @AppStorage(AppLanguage.storageKey) private var appLanguageRawValue = AppLanguage.english.rawValue

    private var language: AppLanguage {
        AppLanguage(rawValue: appLanguageRawValue) ?? .english
    }

    private var canContinue: Bool {
        viewModel.isBackgroundStartEnabled
    }

    var body: some View {
        VStack(spacing: 22) {
            header
            introCard
            permissionCard
            backgroundCard
            footer
        }
        .padding(28)
        .frame(maxWidth: 760)
        .onAppear {
            permissions.refresh()
            viewModel.refreshBackgroundStartStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            permissions.refresh()
            viewModel.refreshBackgroundStartStatus()
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            guard !permissions.isAccessibilityTrusted else {
                return
            }

            permissions.refresh()
        }
        .alert(language.accessibilityWarningTitle, isPresented: $isShowingAccessibilityWarning) {
            Button(language.openSystemSettingsTitle) {
                permissions.requestAccessibility()
            }

            Button(language.continueAnywayTitle) {
                onContinue()
            }
        } message: {
            Text(language.accessibilityWarningDetail)
        }
    }

    private var header: some View {
        HStack(spacing: 22) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 82, height: 82)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

            Text(language.permissionsSetupTitle)
                .font(.system(size: 46, weight: .bold))

            Spacer()
        }
    }

    private var introCard: some View {
        VStack(spacing: 6) {
            Text(language.permissionsIntroTitle)
                .font(.system(size: 18, weight: .semibold))
                .multilineTextAlignment(.center)

            Text(language.privacyAssuranceTitle)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .setupCardStyle()
    }

    private var permissionCard: some View {
        setupRow(
            title: language.accessibilityTitle,
            detail: language.accessibilitySetupDetail,
            isActive: permissions.isAccessibilityTrusted,
            activeTitle: language.activeTitle,
            buttonTitle: language.grantPermissionTitle
        ) {
            permissions.requestAccessibility()
        }
    }

    private var backgroundCard: some View {
        setupRow(
            title: language.backgroundStartTitle,
            detail: language.backgroundStartDetail,
            isActive: viewModel.isBackgroundStartEnabled,
            activeTitle: language.activeTitle,
            buttonTitle: language.enableBackgroundStartTitle
        ) {
            viewModel.enableBackgroundStart()
        }
    }

    private func setupRow(
        title: String,
        detail: String,
        isActive: Bool,
        activeTitle: String,
        buttonTitle: String,
        action: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: isActive ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .font(.system(size: 20, weight: .semibold))

                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.system(size: 24, weight: .bold))
                        .underline()

                    Text(detail)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }

            if isActive {
                Text(activeTitle)
                    .font(.system(size: 13, weight: .semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color(nsColor: .textBackgroundColor))
                    )
            } else {
                Button(buttonTitle) {
                    action()
                }
                .buttonStyle(SetupPrimaryButtonStyle())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .setupCardStyle()
    }

    private var footer: some View {
        HStack(spacing: 14) {
            Button(language.quitTitle) {
                NSApp.terminate(nil)
            }
            .buttonStyle(SetupSecondaryButtonStyle())

            Button(language.continueTitle) {
                guard canContinue else {
                    return
                }

                permissions.refresh()

                guard permissions.isAccessibilityTrusted else {
                    isShowingAccessibilityWarning = true
                    return
                }

                onContinue()
            }
            .buttonStyle(SetupPrimaryButtonStyle())
            .disabled(!canContinue)
        }
    }
}

private extension View {
    func setupCardStyle() -> some View {
        background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(nsColor: .separatorColor).opacity(0.3), lineWidth: 1)
        )
    }
}

private struct SetupPrimaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(backgroundColor(isPressed: configuration.isPressed))
            .foregroundStyle(foregroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func backgroundColor(isPressed: Bool) -> Color {
        if !isEnabled {
            return Color(nsColor: .controlBackgroundColor)
        }

        return isPressed ? Color.primary.opacity(0.82) : Color.primary
    }

    private var foregroundColor: Color {
        isEnabled ? Color(nsColor: .windowBackgroundColor) : Color.secondary
    }
}

private struct SetupSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(configuration.isPressed ? Color.primary.opacity(0.12) : Color(nsColor: .controlBackgroundColor))
            )
            .foregroundStyle(.primary)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color(nsColor: .separatorColor).opacity(0.4), lineWidth: 1)
            )
    }
}

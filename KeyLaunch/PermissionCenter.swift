import ApplicationServices
import Combine
import AppKit

@MainActor
final class PermissionCenter: ObservableObject {
    enum Requirement: CaseIterable, Identifiable {
        case none

        var id: String { title }

        var title: String {
            switch self {
            case .none:
                return "None"
            }
        }

        var detail: String {
            switch self {
            case .none:
                return "System key remapping does not need additional permissions."
            }
        }
    }

    static let shared = PermissionCenter()

    @Published private(set) var isAccessibilityTrusted = AXIsProcessTrusted()
    private var accessibilityRefreshTask: Task<Void, Never>?

    var summaryTitle: String {
        summaryTitle(in: .english)
    }

    var summaryDetail: String {
        summaryDetail(in: .english)
    }

    func summaryTitle(in language: AppLanguage) -> String {
        language.permissionSummaryTitle
    }

    func summaryDetail(in language: AppLanguage) -> String {
        language.permissionSummaryDetail
    }

    func requestAccessibility() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        isAccessibilityTrusted = AXIsProcessTrustedWithOptions(options)

        if !isAccessibilityTrusted {
            NSWorkspace.shared.open(
                URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
            )
        }

        refreshAccessibilityStatusForAWhile()
    }

    func refresh() {
        isAccessibilityTrusted = AXIsProcessTrusted()
    }

    private func refreshAccessibilityStatusForAWhile() {
        accessibilityRefreshTask?.cancel()
        accessibilityRefreshTask = Task { [weak self] in
            for _ in 0..<20 {
                guard !Task.isCancelled else {
                    return
                }

                try? await Task.sleep(for: .seconds(1))

                await MainActor.run {
                    self?.refresh()
                }

                if self?.isAccessibilityTrusted == true {
                    return
                }
            }
        }
    }
}

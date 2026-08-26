import Combine
import Foundation

@MainActor
final class PremiumManager: ObservableObject {
    static let shared = PremiumManager()

    @Published private(set) var hasPremiumAccess: Bool

    private let storageKey = "premiumAccessUnlocked"

    private init() {
        hasPremiumAccess = UserDefaults.standard.bool(forKey: storageKey)
    }

    func unlockForCurrentDevice() {
        setPremiumAccess(true)
    }

    func resetLocalUnlock() {
        setPremiumAccess(false)
    }

    private func setPremiumAccess(_ isUnlocked: Bool) {
        UserDefaults.standard.set(isUnlocked, forKey: storageKey)
        hasPremiumAccess = isUnlocked
    }
}

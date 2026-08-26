import Combine
import FirebaseAuth
import Foundation

@MainActor
final class AccountManager: ObservableObject {
    static let shared = AccountManager()

    @Published private(set) var email: String?
    @Published private(set) var isSignedIn = false

    private let temporaryTestLicenseKey = "KL4X9A-7M2Q8P"
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    private init() {}

    func startListening() {
        guard authStateHandle == nil else {
            syncCurrentUser()
            return
        }

        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.email = user?.email
                self?.isSignedIn = user != nil
            }
        }
    }

    func signIn(email: String, password: String) async throws {
        _ = try await Auth.auth().signIn(withEmail: email, password: password)
        syncCurrentUser()
    }

    func createAccount(email: String, password: String) async throws {
        _ = try await Auth.auth().createUser(withEmail: email, password: password)
        syncCurrentUser()
    }

    func signOut() throws {
        try Auth.auth().signOut()
        syncCurrentUser()
    }

    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            return
        }

        do {
            try await user.delete()
            syncCurrentUser()
        } catch {
            if AuthErrorCode(_bridgedNSError: error as NSError)?.code == .requiresRecentLogin {
                throw AccountDeletionError.requiresRecentLogin
            }

            throw error
        }
    }

    func reauthenticateAndDeleteAccount(email: String, password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AccountDeletionError.notSignedIn
        }

        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        try await user.reauthenticate(with: credential)
        try await user.delete()
        syncCurrentUser()
    }

    func activateLicense(_ licenseKey: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw LicenseActivationError.notSignedIn
        }

        _ = try await user.getIDToken()

        // TEMPORARY TEST LICENSE: remove this block when Firebase license activation is connected.
        if licenseKey.uppercased() == temporaryTestLicenseKey {
            PremiumManager.shared.unlockForCurrentDevice()
            return
        }

        throw LicenseActivationError.backendNotConfigured
    }

    private func syncCurrentUser() {
        let user = Auth.auth().currentUser
        email = user?.email
        isSignedIn = user != nil
    }
}

enum AccountDeletionError: LocalizedError, Equatable {
    case notSignedIn
    case requiresRecentLogin

    var errorDescription: String? {
        switch self {
        case .notSignedIn:
            return "Log in before deleting your account."
        case .requiresRecentLogin:
            return "For security, log in again before deleting your account."
        }
    }
}

private enum LicenseActivationError: LocalizedError {
    case notSignedIn
    case backendNotConfigured

    var errorDescription: String? {
        switch self {
        case .notSignedIn:
            return "Log in before activating a license key."
        case .backendNotConfigured:
            return "License activation is ready in the app. Connect the Firebase activation function next."
        }
    }
}

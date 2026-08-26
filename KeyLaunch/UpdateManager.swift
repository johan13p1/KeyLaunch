import AppKit
import Sparkle

@MainActor
final class UpdateManager {
    static let shared = UpdateManager()

    private let updaterController = SPUStandardUpdaterController(
        startingUpdater: false,
        updaterDelegate: nil,
        userDriverDelegate: nil
    )
    private var hasStartedUpdater = false

    private init() {}

    func startUpdaterIfNeeded() {
        guard !hasStartedUpdater else {
            return
        }

        updaterController.startUpdater()
        hasStartedUpdater = true
    }

    func startUpdaterIfAppropriate(isBackgroundLaunch: Bool) {
        guard !isBackgroundLaunch else {
            return
        }

        startUpdaterIfNeeded()
    }

    func checkForUpdates() {
        startUpdaterIfNeeded()
        updaterController.checkForUpdates(nil)
    }
}

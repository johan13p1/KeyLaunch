import AppKit
import FirebaseCore
import SwiftUI

@main
struct KeyLaunchApp: App {
    @NSApplicationDelegateAdaptor(KeyLaunchAppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 840, minHeight: 620)
        }
        .windowResizability(.contentMinSize)
    }
}

final class KeyLaunchAppDelegate: NSObject, NSApplicationDelegate {
    private var isBackgroundLaunch: Bool {
        CommandLine.arguments.contains("--background")
    }

    private var shouldStayAvailableForAppShortcuts: Bool {
        KeyRemappingService.shared.isAppShortcutBackgroundStartEnabled()
            && (
                KeyRemappingService.shared.hasApplicationKeybinds()
                    || KeyRemappingService.shared.hasProfileAssignments()
            )
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        configureFirebaseIfNeeded()
        UpdateManager.shared.startUpdaterIfAppropriate(isBackgroundLaunch: isBackgroundLaunch)

        guard isBackgroundLaunch else {
            return
        }

        NSApp.setActivationPolicy(.accessory)

        DispatchQueue.main.async {
            self.moveToBackground()
        }
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        guard shouldStayAvailableForAppShortcuts else {
            return .terminateNow
        }

        moveToBackground()
        return .terminateCancel
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        UpdateManager.shared.startUpdaterIfNeeded()

        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        if !flag {
            sender.windows.forEach { window in
                window.makeKeyAndOrderFront(nil)
            }
        }

        return true
    }

    private func moveToBackground() {
        NSApp.setActivationPolicy(.accessory)
        NSApp.hide(nil)

        NSApp.windows.forEach { window in
            window.orderOut(nil)
        }
    }

    private func configureFirebaseIfNeeded() {
        guard FirebaseApp.app() == nil else {
            AccountManager.shared.startListening()
            return
        }

        FirebaseApp.configure()
        AccountManager.shared.startListening()
    }
}

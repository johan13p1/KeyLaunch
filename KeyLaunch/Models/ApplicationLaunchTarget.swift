import Foundation

struct ApplicationLaunchTarget: Equatable, Sendable {
    let displayName: String
    let url: URL
    let bundleIdentifier: String?

    nonisolated var id: String {
        bundleIdentifier ?? url.path
    }
}

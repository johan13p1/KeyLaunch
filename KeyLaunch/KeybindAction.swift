import Foundation

enum KeybindAction: Equatable, Sendable {
    case systemFunction(RemapAction)
    case openApplication(ApplicationLaunchTarget)
    case openWebsite(WebsiteLaunchTarget)

    nonisolated var id: String {
        switch self {
        case .systemFunction(let action):
            return "system-\(action.rawValue)"
        case .openApplication(let target):
            return "app-\(target.id)"
        case .openWebsite(let target):
            return "website-\(target.id)"
        }
    }

    nonisolated var systemFunction: RemapAction? {
        if case .systemFunction(let action) = self {
            return action
        }

        return nil
    }

    nonisolated var applicationTarget: ApplicationLaunchTarget? {
        if case .openApplication(let target) = self {
            return target
        }

        return nil
    }

    nonisolated var websiteTarget: WebsiteLaunchTarget? {
        if case .openWebsite(let target) = self {
            return target
        }

        return nil
    }

    func title(in language: AppLanguage) -> String {
        switch self {
        case .systemFunction(let action):
            return action.title(in: language)
        case .openApplication(let target):
            return language.openApplicationMappingTitle(target.displayName)
        case .openWebsite(let target):
            return language.openWebsiteMappingTitle(target.displayName)
        }
    }

    func detail(in language: AppLanguage) -> String {
        switch self {
        case .systemFunction(let action):
            return action.detail(in: language)
        case .openApplication(let target):
            return language.openApplicationMappingDetail(target.displayName)
        case .openWebsite(let target):
            return language.openWebsiteMappingDetail(target.url.absoluteString)
        }
    }
}

struct WebsiteLaunchTarget: Equatable, Sendable {
    let url: URL

    nonisolated var id: String {
        url.absoluteString
    }

    nonisolated var displayName: String {
        if let host = url.host?.trimmingCharacters(in: .whitespacesAndNewlines),
           !host.isEmpty {
            return host
        }

        return url.absoluteString
    }
}

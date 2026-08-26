import Foundation

struct KeyMapping: Identifiable, Equatable, Sendable {
    let source: SourceKey
    let action: KeybindAction

    var id: String {
        "\(source.id)-\(action.id)"
    }

    var summary: String {
        summary(in: .english)
    }

    func summary(in language: AppLanguage) -> String {
        language.mappingSummary(
            sourceName: source.displayName,
            actionTitle: action.title(in: language)
        )
    }
}

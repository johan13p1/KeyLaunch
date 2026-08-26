import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case english
    case german

    static let storageKey = "appLanguage"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english:
            return "English"
        case .german:
            return "Deutsch"
        }
    }

    var settingsTitle: String {
        switch self {
        case .english:
            return "Settings"
        case .german:
            return "Einstellungen"
        }
    }

    var settingsSubtitle: String {
        switch self {
        case .english:
            return "View and adjust KeyLaunch."
        case .german:
            return "Hier siehst du den aktuellen Status von KeyLaunch."
        }
    }

    var settingsButtonTitle: String {
        switch self {
        case .english:
            return "Settings"
        case .german:
            return "Einstellungen"
        }
    }

    var languageSectionTitle: String {
        switch self {
        case .english:
            return "Language"
        case .german:
            return "Sprache"
        }
    }

    var languagePickerTitle: String {
        switch self {
        case .english:
            return "App language"
        case .german:
            return "App-Sprache"
        }
    }

    var languageDetail: String {
        switch self {
        case .english:
            return "English is the default language. Changes apply immediately."
        case .german:
            return "Englisch ist die Standardsprache. Änderungen werden sofort übernommen."
        }
    }

    var systemStatusTitle: String {
        switch self {
        case .english:
            return "System Status"
        case .german:
            return "Systemstatus"
        }
    }

    var refreshStatusTitle: String {
        switch self {
        case .english:
            return "Refresh Status"
        case .german:
            return "Status aktualisieren"
        }
    }

    var checkForUpdatesTitle: String {
        switch self {
        case .english:
            return "Check for Updates..."
        case .german:
            return "Nach Updates suchen..."
        }
    }



    var activeTitle: String {
        switch self {
        case .english:
            return "Active"
        case .german:
            return "Aktiv"
        }
    }

    var editingProfileTitle: String {
        switch self {
        case .english:
            return "Editing"
        case .german:
            return "Bearbeitung"
        }
    }

    func runtimeProfileTitle(_ profileName: String) -> String {
        switch self {
        case .english:
            return "Using \(profileName) for the current app"
        case .german:
            return "\(profileName) ist für die aktuelle App aktiv"
        }
    }

    var storageDetail: String {
        switch self {
        case .english:
            return "Your keybinds are stored locally as a hidutil configuration and LaunchAgent."
        case .german:
            return "Deine Keybinds werden lokal als hidutil-Konfiguration und LaunchAgent gespeichert."
        }
    }

    var createKeybindTitle: String {
        switch self {
        case .english:
            return "Create New Keybind"
        case .german:
            return "Neuen Keybind anlegen"
        }
    }

    var profilesTitle: String {
        switch self {
        case .english:
            return "Profiles"
        case .german:
            return "Profile"
        }
    }

    var newProfileTitle: String {
        switch self {
        case .english:
            return "Profile"
        case .german:
            return "Profil"
        }
    }

    var deleteProfileTitle: String {
        switch self {
        case .english:
            return "Delete Profile"
        case .german:
            return "Profil löschen"
        }
    }

    var renameProfileTitle: String {
        switch self {
        case .english:
            return "Rename Profile"
        case .german:
            return "Profil umbenennen"
        }
    }

    var profileNameTitle: String {
        switch self {
        case .english:
            return "Profile name"
        case .german:
            return "Profilname"
        }
    }

    var saveTitle: String {
        switch self {
        case .english:
            return "Save"
        case .german:
            return "Speichern"
        }
    }

    var cancelTitle: String {
        switch self {
        case .english:
            return "Cancel"
        case .german:
            return "Abbrechen"
        }
    }

    var deleteProfileConfirmationTitle: String {
        switch self {
        case .english:
            return "Delete this profile?"
        case .german:
            return "Dieses Profil löschen?"
        }
    }

    func deleteProfileConfirmationDetail(_ profileName: String) -> String {
        switch self {
        case .english:
            return "\(profileName) and its keybinds will be removed."
        case .german:
            return "\(profileName) und die zugehörigen Keybinds werden entfernt."
        }
    }

    var presetsTitle: String {
        switch self {
        case .english:
            return "Presets"
        case .german:
            return "Presets"
        }
    }

    var assignApplicationTitle: String {
        switch self {
        case .english:
            return "Assign App"
        case .german:
            return "App zuordnen"
        }
    }

    var assignedApplicationsTitle: String {
        switch self {
        case .english:
            return "Assigned Apps"
        case .german:
            return "Zugeordnete Apps"
        }
    }

    var noAssignedApplicationsTitle: String {
        switch self {
        case .english:
            return "No apps assigned yet."
        case .german:
            return "Noch keine Apps zugeordnet."
        }
    }

    var profileAutomationDetail: String {
        switch self {
        case .english:
            return "When an assigned app becomes active, KeyLaunch switches to this profile automatically."
        case .german:
            return "Wenn eine zugeordnete App aktiv wird, wechselt KeyLaunch automatisch zu diesem Profil."
        }
    }

    var keyTitle: String {
        switch self {
        case .english:
            return "Key"
        case .german:
            return "Taste"
        }
    }

    var chooseKeyTitle: String {
        switch self {
        case .english:
            return "Choose key"
        case .german:
            return "Taste auswählen"
        }
    }

    var chooseFunctionKeyDetail: String {
        switch self {
        case .english:
            return "Choose the function key you want to remap."
        case .german:
            return "Wähle die gewünschte F-Taste aus."
        }
    }

    func selectedKeyDetail(_ keyName: String) -> String {
        switch self {
        case .english:
            return "\(keyName) selected."
        case .german:
            return "\(keyName) ausgewählt."
        }
    }

    var functionTitle: String {
        switch self {
        case .english:
            return "Function"
        case .german:
            return "Funktion"
        }
    }

    var actionTypeTitle: String {
        switch self {
        case .english:
            return "Action Type"
        case .german:
            return "Aktionstyp"
        }
    }

    var systemFunctionTitle: String {
        switch self {
        case .english:
            return "System Function"
        case .german:
            return "Systemfunktion"
        }
    }

    var openApplicationTitle: String {
        switch self {
        case .english:
            return "Open App"
        case .german:
            return "App öffnen"
        }
    }

    var openWebsiteTitle: String {
        switch self {
        case .english:
            return "Open Website"
        case .german:
            return "Website öffnen"
        }
    }

    var chooseApplicationTitle: String {
        switch self {
        case .english:
            return "Choose App"
        case .german:
            return "App auswählen"
        }
    }

    var noApplicationSelectedTitle: String {
        switch self {
        case .english:
            return "No app selected."
        case .german:
            return "Keine App ausgewählt."
        }
    }

    func selectedApplicationDetail(_ appName: String) -> String {
        switch self {
        case .english:
            return "\(appName) will open when the key is pressed."
        case .german:
            return "\(appName) wird geöffnet, wenn die Taste gedrückt wird."
        }
    }

    func openApplicationMappingTitle(_ appName: String) -> String {
        switch self {
        case .english:
            return "Open \(appName)"
        case .german:
            return "\(appName) öffnen"
        }
    }

    func openApplicationMappingDetail(_ appName: String) -> String {
        switch self {
        case .english:
            return "Opens \(appName)."
        case .german:
            return "Öffnet \(appName)."
        }
    }

    var websiteURLPlaceholder: String {
        switch self {
        case .english:
            return "Website URL"
        case .german:
            return "Website-URL"
        }
    }

    var websiteURLHelp: String {
        switch self {
        case .english:
            return "Opens in your default browser."
        case .german:
            return "Öffnet sich in deinem Standardbrowser."
        }
    }

    func openWebsiteMappingTitle(_ websiteName: String) -> String {
        switch self {
        case .english:
            return "Open \(websiteName)"
        case .german:
            return "\(websiteName) öffnen"
        }
    }

    func openWebsiteMappingDetail(_ url: String) -> String {
        switch self {
        case .english:
            return "Opens \(url)."
        case .german:
            return "Öffnet \(url)."
        }
    }

    var saveKeybindTitle: String {
        switch self {
        case .english:
            return "Save Keybind"
        case .german:
            return "Keybind speichern"
        }
    }

    var resetTitle: String {
        switch self {
        case .english:
            return "Reset"
        case .german:
            return "Zurücksetzen"
        }
    }

    var savedKeybindsTitle: String {
        switch self {
        case .english:
            return "Saved Keybinds"
        case .german:
            return "Gespeicherte Keybinds"
        }
    }

    var noKeybindsTitle: String {
        switch self {
        case .english:
            return "No keybinds saved yet."
        case .german:
            return "Noch keine Keybinds gespeichert."
        }
    }

    func mappingSummary(sourceName: String, actionTitle: String) -> String {
        switch self {
        case .english:
            return "\(sourceName) is mapped to \(actionTitle)."
        case .german:
            return "\(sourceName) ist auf \(actionTitle) gelegt."
        }
    }

    var permissionSummaryTitle: String {
        switch self {
        case .english:
            return "System key remapping is ready."
        case .german:
            return "System-Tastenbelegung ist bereit."
        }
    }

    var permissionSummaryDetail: String {
        switch self {
        case .english:
            return "System functions are stored in ~/Library/LaunchAgents/com.local.keyRemapping.plist and applied immediately with hidutil."
        case .german:
            return "Systemfunktionen werden in ~/Library/LaunchAgents/com.local.keyRemapping.plist gespeichert und sofort per hidutil angewendet."
        }
    }

    var accessibilityTitle: String {
        switch self {
        case .english:
            return "Accessibility"
        case .german:
            return "Bedienungshilfen"
        }
    }

    var accessibilityGrantedTitle: String {
        switch self {
        case .english:
            return "Accessibility is enabled."
        case .german:
            return "Bedienungshilfen sind aktiviert."
        }
    }

    var accessibilityMissingTitle: String {
        switch self {
        case .english:
            return "Accessibility is needed for app shortcuts."
        case .german:
            return "Bedienungshilfen werden für App-Shortcuts benötigt."
        }
    }

    var accessibilityDetail: String {
        switch self {
        case .english:
            return "Open App keybinds listen for global key presses, so macOS may ask you to allow KeyLaunch in System Settings."
        case .german:
            return "App-Shortcuts hören globale Tastendrücke ab, deshalb kann macOS KeyLaunch in den Systemeinstellungen freigeben lassen."
        }
    }

    var requestAccessibilityTitle: String {
        switch self {
        case .english:
            return "Request Accessibility"
        case .german:
            return "Bedienungshilfen anfragen"
        }
    }

    var permissionsSetupTitle: String {
        switch self {
        case .english:
            return "Permissions"
        case .german:
            return "Berechtigungen"
        }
    }

    var permissionsIntroTitle: String {
        switch self {
        case .english:
            return "KeyLaunch needs permission to detect global function key presses."
        case .german:
            return "KeyLaunch braucht deine Erlaubnis, um globale F-Tasten zu erkennen."
        }
    }

    var privacyAssuranceTitle: String {
        switch self {
        case .english:
            return "No personal information is collected or stored."
        case .german:
            return "Es werden keine persönlichen Informationen gesammelt oder gespeichert."
        }
    }

    var accessibilitySetupDetail: String {
        switch self {
        case .english:
            return "KeyLaunch needs this to open apps from function keys while you use other apps."
        case .german:
            return "KeyLaunch braucht das, um Apps über F-Tasten zu öffnen, während du andere Apps benutzt."
        }
    }

    var grantPermissionTitle: String {
        switch self {
        case .english:
            return "Grant Permission"
        case .german:
            return "Berechtigung erteilen"
        }
    }

    var accessibilityWarningTitle: String {
        switch self {
        case .english:
            return "Accessibility is not enabled"
        case .german:
            return "Bedienungshilfen sind nicht aktiviert"
        }
    }

    var accessibilityWarningDetail: String {
        switch self {
        case .english:
            return "You can continue without Accessibility, but Open App keybinds will only work after KeyLaunch is allowed in System Settings."
        case .german:
            return "Du kannst ohne Bedienungshilfen fortfahren, aber App-Keybinds funktionieren erst, nachdem KeyLaunch in den Systemeinstellungen erlaubt wurde."
        }
    }

    var openSystemSettingsTitle: String {
        switch self {
        case .english:
            return "Open System Settings"
        case .german:
            return "Systemeinstellungen öffnen"
        }
    }

    var continueAnywayTitle: String {
        switch self {
        case .english:
            return "Continue Anyway"
        case .german:
            return "Trotzdem fortfahren"
        }
    }

    var backgroundStartTitle: String {
        switch self {
        case .english:
            return "Run in Background"
        case .german:
            return "Im Hintergrund starten"
        }
    }

    var backgroundStartEnabledTitle: String {
        switch self {
        case .english:
            return "Background start is enabled."
        case .german:
            return "Hintergrundstart ist aktiviert."
        }
    }

    var backgroundStartMissingTitle: String {
        switch self {
        case .english:
            return "Background start is needed after restart."
        case .german:
            return "Hintergrundstart wird nach einem Neustart benötigt."
        }
    }

    var backgroundStartDetail: String {
        switch self {
        case .english:
            return "KeyLaunch starts hidden at login so Open App keybinds keep working after a restart."
        case .german:
            return "KeyLaunch startet beim Login unsichtbar, damit App-Keybinds nach einem Neustart weiter funktionieren."
        }
    }

    var enableBackgroundStartTitle: String {
        switch self {
        case .english:
            return "Enable Background Start"
        case .german:
            return "Hintergrundstart aktivieren"
        }
    }

    var disableBackgroundStartTitle: String {
        switch self {
        case .english:
            return "Disable"
        case .german:
            return "Deaktivieren"
        }
    }

    var quitTitle: String {
        switch self {
        case .english:
            return "Quit"
        case .german:
            return "Beenden"
        }
    }

    var continueTitle: String {
        switch self {
        case .english:
            return "Continue"
        case .german:
            return "Weiter"
        }
    }
}

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

    var accountTitle: String {
        switch self {
        case .english:
            return "Account"
        case .german:
            return "Account"
        }
    }

    var accountDetail: String {
        switch self {
        case .english:
            return "Log in or create an account for future Premium access."
        case .german:
            return "Melde dich an oder erstelle einen Account für den späteren Premium-Zugang."
        }
    }

    var accountSheetDetail: String {
        switch self {
        case .english:
            return "Use the account connected to your KeyLaunch license."
        case .german:
            return "Nutze den Account, der später mit deiner KeyLaunch-Lizenz verbunden ist."
        }
    }

    var signedInAccountDetail: String {
        switch self {
        case .english:
            return "Signed in"
        case .german:
            return "Eingeloggt"
        }
    }

    var freeAccountTitle: String {
        switch self {
        case .english:
            return "Free user"
        case .german:
            return "Free-Nutzer"
        }
    }

    var premiumAccountTitle: String {
        switch self {
        case .english:
            return "Premium user"
        case .german:
            return "Premium-Nutzer"
        }
    }

    var activateLicenseTitle: String {
        switch self {
        case .english:
            return "Activate License"
        case .german:
            return "Lizenz aktivieren"
        }
    }

    var buyPremiumTitle: String {
        switch self {
        case .english:
            return "Buy Premium"
        case .german:
            return "Premium kaufen"
        }
    }

    var licenseKeyTitle: String {
        switch self {
        case .english:
            return "License key"
        case .german:
            return "Lizenzschlüssel"
        }
    }

    var licenseSheetDetail: String {
        switch self {
        case .english:
            return "Connect a purchased KeyLaunch Premium license to this account."
        case .german:
            return "Verbinde eine gekaufte KeyLaunch-Premium-Lizenz mit diesem Account."
        }
    }

    var licenseLoginRequiredTitle: String {
        switch self {
        case .english:
            return "Log in to enter a license key."
        case .german:
            return "Logge dich ein, um einen Lizenzschlüssel einzugeben."
        }
    }

    var licenseLoginRequiredDetail: String {
        switch self {
        case .english:
            return "A Premium license is connected to your KeyLaunch account, so you need to log in or create an account first."
        case .german:
            return "Eine Premium-Lizenz wird mit deinem KeyLaunch-Account verbunden. Logge dich deshalb zuerst ein oder erstelle einen Account."
        }
    }

    var licenseOneTimeWarningTitle: String {
        switch self {
        case .english:
            return "One-time activation"
        case .german:
            return "Einmalige Aktivierung"
        }
    }

    var licenseOneTimeWarningDetail: String {
        switch self {
        case .english:
            return "After activation, this license key belongs to this account. It cannot be used again for another account."
        case .german:
            return "Nach der Aktivierung gehört dieser Lizenzschlüssel zu diesem Account. Er kann danach nicht erneut für einen anderen Account verwendet werden."
        }
    }

    var licenseMissingKeyTitle: String {
        switch self {
        case .english:
            return "Please enter a license key."
        case .german:
            return "Bitte gib einen Lizenzschlüssel ein."
        }
    }

    var licenseActivationPendingTitle: String {
        switch self {
        case .english:
            return "Checking license with Firebase..."
        case .german:
            return "Prüfe die Lizenz mit Firebase..."
        }
    }

    var licenseActivatedTitle: String {
        switch self {
        case .english:
            return "Premium is active on this account."
        case .german:
            return "Premium ist auf diesem Account aktiv."
        }
    }

    var loginTitle: String {
        switch self {
        case .english:
            return "Log In"
        case .german:
            return "Einloggen"
        }
    }

    var registerTitle: String {
        switch self {
        case .english:
            return "Register"
        case .german:
            return "Registrieren"
        }
    }

    var createAccountTitle: String {
        switch self {
        case .english:
            return "Create Account"
        case .german:
            return "Account erstellen"
        }
    }

    var emailTitle: String {
        switch self {
        case .english:
            return "Email"
        case .german:
            return "E-Mail"
        }
    }

    var passwordTitle: String {
        switch self {
        case .english:
            return "Password"
        case .german:
            return "Passwort"
        }
    }

    var confirmPasswordTitle: String {
        switch self {
        case .english:
            return "Confirm password"
        case .german:
            return "Passwort bestätigen"
        }
    }

    var accountFirebasePendingTitle: String {
        switch self {
        case .english:
            return "Connecting to Firebase..."
        case .german:
            return "Verbinde mit Firebase..."
        }
    }

    var accountMissingFieldsTitle: String {
        switch self {
        case .english:
            return "Please enter an email and password."
        case .german:
            return "Bitte gib E-Mail und Passwort ein."
        }
    }

    var accountPasswordsDoNotMatchTitle: String {
        switch self {
        case .english:
            return "Passwords do not match."
        case .german:
            return "Die Passwörter stimmen nicht überein."
        }
    }

    var accountSignedInTitle: String {
        switch self {
        case .english:
            return "You are signed in."
        case .german:
            return "Du bist eingeloggt."
        }
    }

    var accountCreatedTitle: String {
        switch self {
        case .english:
            return "Account created."
        case .german:
            return "Account erstellt."
        }
    }

    var accountSignedOutTitle: String {
        switch self {
        case .english:
            return "You are signed out."
        case .german:
            return "Du bist ausgeloggt."
        }
    }

    var accountDeletedTitle: String {
        switch self {
        case .english:
            return "Account deleted."
        case .german:
            return "Account gelöscht."
        }
    }

    var deleteAccountTitle: String {
        switch self {
        case .english:
            return "Delete Account"
        case .german:
            return "Account löschen"
        }
    }

    var logoutTitle: String {
        switch self {
        case .english:
            return "Log Out"
        case .german:
            return "Ausloggen"
        }
    }

    var logoutConfirmationTitle: String {
        switch self {
        case .english:
            return "Log out?"
        case .german:
            return "Ausloggen?"
        }
    }

    var logoutConfirmationDetail: String {
        switch self {
        case .english:
            return "KeyLaunch will stop showing this account until you log in again."
        case .german:
            return "KeyLaunch zeigt diesen Account nicht mehr an, bis du dich wieder einloggst."
        }
    }

    var deleteAccountConfirmationTitle: String {
        switch self {
        case .english:
            return "Delete this account?"
        case .german:
            return "Diesen Account löschen?"
        }
    }

    var deleteAccountConfirmationDetail: String {
        switch self {
        case .english:
            return "This removes the Firebase account and its license connection."
        case .german:
            return "Das entfernt den Firebase-Account und die verbundene Lizenz."
        }
    }

    var deleteAccountPremiumWarningDetail: String {
        switch self {
        case .english:
            return "If Premium is connected to this account, deleting the account can permanently remove that Premium access. A license key that has already been activated is intended for this account only and cannot simply be reused for another account."
        case .german:
            return "Wenn Premium mit diesem Account verbunden ist, kann das Löschen diesen Premium-Zugang dauerhaft entfernen. Ein bereits aktivierter Lizenzschlüssel ist nur für diesen Account gedacht und kann nicht einfach für einen anderen Account erneut verwendet werden."
        }
    }

    var deleteAccountRequiresRecentLoginTitle: String {
        switch self {
        case .english:
            return "Confirm your password to delete this account."
        case .german:
            return "Bestätige dein Passwort, um diesen Account zu löschen."
        }
    }

    var confirmAccountDeletionTitle: String {
        switch self {
        case .english:
            return "Confirm Account Deletion"
        case .german:
            return "Account-Löschung bestätigen"
        }
    }

    var confirmAccountDeletionDetail: String {
        switch self {
        case .english:
            return "Firebase requires a fresh login before deleting an account. If this login succeeds, KeyLaunch will delete the account immediately."
        case .german:
            return "Firebase verlangt einen frischen Login, bevor ein Account gelöscht wird. Wenn dieser Login erfolgreich ist, löscht KeyLaunch den Account sofort."
        }
    }

    var confirmAccountDeletionWarning: String {
        switch self {
        case .english:
            return "This is not a normal login. It confirms deletion of your account and can remove Premium access linked to it."
        case .german:
            return "Das ist kein normaler Login. Damit bestätigst du die Löschung deines Accounts und Premium-Zugang, der damit verbunden ist, kann entfernt werden."
        }
    }

    var loginAndDeleteAccountTitle: String {
        switch self {
        case .english:
            return "Log In and Delete Account"
        case .german:
            return "Einloggen und Account löschen"
        }
    }

    var deleteAccountRemovesAccountTitle: String {
        switch self {
        case .english:
            return "Your Firebase account will be deleted."
        case .german:
            return "Dein Firebase-Account wird gelöscht."
        }
    }

    var deleteAccountRemovesPremiumTitle: String {
        switch self {
        case .english:
            return "Premium access linked to this account can be lost."
        case .german:
            return "Premium-Zugang für diesen Account kann verloren gehen."
        }
    }

    var deleteAccountLicenseReuseTitle: String {
        switch self {
        case .english:
            return "Used license keys cannot be reused for a different account."
        case .german:
            return "Verwendete Lizenzschlüssel können nicht für einen anderen Account erneut genutzt werden."
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

    var premiumTitle: String {
        switch self {
        case .english:
            return "Premium"
        case .german:
            return "Premium"
        }
    }

    var premiumLockedTitle: String {
        switch self {
        case .english:
            return "Premium features are locked on this Mac."
        case .german:
            return "Premium-Features sind auf diesem Mac gesperrt."
        }
    }

    var premiumUnlockedTitle: String {
        switch self {
        case .english:
            return "Premium features are unlocked on this Mac."
        case .german:
            return "Premium-Features sind auf diesem Mac freigeschaltet."
        }
    }

    var premiumDetail: String {
        switch self {
        case .english:
            return "Unlock profiles, app-based switching and advanced keybinds with a one-time KeyLaunch Premium purchase."
        case .german:
            return "Schalte Profile, appbasiertes Wechseln und erweiterte Keybinds mit einem einmaligen KeyLaunch-Premium-Kauf frei."
        }
    }

    var unlockPremiumTitle: String {
        switch self {
        case .english:
            return "Unlock Preview"
        case .german:
            return "Preview freischalten"
        }
    }

    var resetPremiumTitle: String {
        switch self {
        case .english:
            return "Reset Preview"
        case .german:
            return "Preview zurücksetzen"
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

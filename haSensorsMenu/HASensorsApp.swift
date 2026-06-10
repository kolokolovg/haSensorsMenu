import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBar: StatusBarManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let settings = SettingsManager()
        let store = HASensorStore(settings: settings)
        statusBar = StatusBarManager(store: store, settings: settings)
        store.startFetching()

        AppState.shared.settings = settings
        AppState.shared.store = store
    }
}

class AppState {
    static let shared = AppState()
    var settings: SettingsManager!
    var store: HASensorStore!
}

@main
struct HASensorsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button(L10n("settings")) {
                    SettingsWindowManager.shared.open(
                        settings: AppState.shared.settings,
                        store: AppState.shared.store
                    )
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
    }
}

import SwiftUI
import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBar: StatusBarManager?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Скрываем dock иконку (если не сделано в Info.plist)
        NSApp.setActivationPolicy(.accessory)
        
        // Инициализируем статус-бар
        let settings = SettingsManager()
        let store = HASensorStore(settings: settings)
        statusBar = StatusBarManager(store: store, settings: settings)
        store.startFetching()
        
        // Сохраняем в синглтон для доступа из SwiftUI
        AppState.shared.settings = settings
        AppState.shared.store = store
    }
}

// Синглтон для доступа к состоянию из любого места
class AppState {
    static let shared = AppState()
    var settings: SettingsManager!
    var store: HASensorStore!
}

@main
struct HASensorsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // Пустая сцена - приложение существует только ради статус-бара
        Settings {
            EmptyView()
        }
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Настройки...") {
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

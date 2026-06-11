import SwiftUI
import AppKit

class SettingsWindowManager {
    static let shared = SettingsWindowManager()
    
    private var window: NSWindow?
    
    func open(settings: SettingsManager, store: HASensorStore, languageManager: LanguageManager) {
        // 1. Делаем наше агент-приложение активным
        NSApp.activate(ignoringOtherApps: true)
        
        // 2. Если окна еще нет, создаем его с полным контролем AppKit
        if window == nil {
            let newWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 480, height: 480),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            
            newWindow.title = "Настройки Home Assistant"
            newWindow.level = .floating // Ключевой момент: окно всегда поверх остальных
            newWindow.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            newWindow.isReleasedWhenClosed = false // Не уничтожать окно при закрытии, а скрывать
            
            // Оборачиваем наш SwiftUI View в AppKit
            let hostingController = NSHostingController(rootView: SettingsView(settings: settings, store: store)
                .environmentObject(languageManager))
            newWindow.contentView = hostingController.view
            
            newWindow.center()
            self.window = newWindow
        }
        
        // 3. Жестко выводим окно на передний план (именно так делает Stats)
        window?.makeKeyAndOrderFront(nil)
        window?.orderFrontRegardless()
    }
    
    func close() {
        window?.close()
    }
}

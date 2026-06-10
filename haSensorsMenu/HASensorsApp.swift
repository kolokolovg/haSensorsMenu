import SwiftUI
import AppKit

@main
struct HASensorsApp: App {
    @StateObject private var settings = SettingsManager()
    @StateObject private var store: HASensorStore
    @Environment(\.openWindow) private var openWindow
    
    init() {
        let s = SettingsManager()
        _settings = StateObject(wrappedValue: s)
        _store = StateObject(wrappedValue: HASensorStore(settings: s))
    }
    
    var body: some Scene {
        // Оставляем .window, так как он стабильно отображает данные
        MenuBarExtra("HA Климат", systemImage: store.isUpdating ? "arrow.triangle.2.circlepath" : "house.fill") {
            VStack(alignment: .leading, spacing: 14) {
                // Заголовок
                HStack {
                    Text("Климат в доме")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: store.isUpdating ? "arrow.triangle.2.circlepath" : "checkmark.circle.fill")
                        .foregroundColor(store.isUpdating ? .blue : .green)
                        .symbolEffect(.variableColor, isActive: store.isUpdating)
                        .font(.caption)
                }
                
                Divider()
                
                // Список комнат
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(store.roomsData, id: \.id) { room in
                        RoomView(room: room)
                        
                        if room.name != store.roomsData.last?.name {
                            Divider()
                                .padding(.vertical, 2)
                        }
                    }
                }
                .padding(.horizontal, 2)
                
                Divider()
                
                // Время обновления
                HStack {
                    Image(systemName: "clock")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(store.lastUpdated)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                Divider()
                
                // Кнопка обновления
                Button(action: {
                    Task { await store.fetchAllSensors() }
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Обновить сейчас")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .keyboardShortcut("r", modifiers: .command)
                .disabled(store.isUpdating)
                .buttonStyle(.plain)
                
                Divider()
                
                // Настройки (ИСПРАВЛЕННЫЙ НАДЕЖНЫЙ ВЫЗОВ)
                Button("Настройки...") {
                    // 1. Делаем приложение активным
                    NSApp.activate(ignoringOtherApps: true)
                    
                    // 2. Открываем окно через SwiftUI
                    openWindow(id: "settings")
                    
                    // 3. Ждем 0.1 сек, пока система создаст окно, и принудительно выводим его на передний план
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let window = NSApp.windows.first(where: { $0.identifier?.rawValue == "settings" }) {
                            window.orderFrontRegardless()
                            window.makeKeyAndOrderFront(nil)
                        }
                    }
                }
                .keyboardShortcut(",", modifiers: .command)
                .buttonStyle(.plain)
                
                // Выход
                Button("Выход") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q", modifiers: .command)
                .buttonStyle(.plain)
            }
            .padding(16)
            .frame(width: 300)
            .onAppear {
                store.startFetching()
            }
        }
        .menuBarExtraStyle(.window) // <-- ВАЖНО: оставляем .window для стабильности данных
        
        Window("Настройки Home Assistant", id: "settings") {
            SettingsView(settings: settings, store: store)
        }
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Настройки...") {
                    NSApp.activate(ignoringOtherApps: true)
                    openWindow(id: "settings")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let window = NSApp.windows.first(where: { $0.identifier?.rawValue == "settings" }) {
                            window.orderFrontRegardless()
                            window.makeKeyAndOrderFront(nil)
                        }
                    }
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
    }
}

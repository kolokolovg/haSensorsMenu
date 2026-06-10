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
        MenuBarExtra("HA Климат", systemImage: store.isUpdating ? "arrow.triangle.2.circlepath" : "house.fill") {
            VStack(alignment: .leading, spacing: 12) {
                // Заголовок
                HStack {
                    Text("Климат в доме")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Image(systemName: store.isUpdating ? "arrow.triangle.2.circlepath" : "checkmark.circle.fill")
                        .foregroundColor(store.isUpdating ? .blue : .green)
                        .symbolEffect(.variableColor, isActive: store.isUpdating)
                        .font(.caption)
                }
                
                Divider()
                
                // ПРОСТОЙ VStack ВМЕСТО ScrollView (гарантирует отображение)
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(store.roomsData, id: \.id) { room in
                        RoomView(room: room)
                        
                        if room.name != store.roomsData.last?.name {
                            Divider().padding(.vertical, 4)
                        }
                    }
                }
                .padding(.horizontal, 4)
                
                Divider()
                
                // Время обновления
                Text(store.lastUpdated)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Divider()
                
                // Кнопка обновления
                Button(action: {
                    Task { await store.fetchAllSensors() }
                }) {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Обновить сейчас")
                    }
                }
                .keyboardShortcut("r", modifiers: .command)
                .disabled(store.isUpdating)
                
                Divider()
                
                // Настройки и Выход
                Button("Настройки...") {
                    NSApplication.shared.activate(ignoringOtherApps: true)
                    openWindow(id: "settings")
                }
                .keyboardShortcut(",", modifiers: .command)
                
                Button("Выход") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q", modifiers: .command)
            }
            .padding()
            .frame(width: 280) // Фиксированная ширина помогает SwiftUI
            .onAppear {
                store.startFetching()
            }
        }
        .menuBarExtraStyle(.window)
        
        Window("Настройки Home Assistant", id: "settings") {
            SettingsView(settings: settings, store: store)
        }
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Настройки...") {
                    NSApplication.shared.activate(ignoringOtherApps: true)
                    openWindow(id: "settings")
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
    }
}

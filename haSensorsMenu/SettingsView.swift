import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: SettingsManager
    @ObservedObject var store: HASensorStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab = SettingsTab.connection

    enum SettingsTab: String, CaseIterable, Identifiable {
        case connection = "Подключение"
        case rooms = "Комнаты"

        var id: String { rawValue }
        var icon: String {
            switch self {
            case .connection: return "server.rack"
            case .rooms: return "house"
            }
        }
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedTab) {
                ForEach(SettingsTab.allCases) { tab in
                    Label(tab.rawValue, systemImage: tab.icon)
                        .tag(tab)
                }
            }
            .listStyle(.sidebar)
            .frame(width: 180)
            .padding(.top, 10)
        } detail: {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    switch selectedTab {
                    case .connection:
                        ConnectionSettingsView(settings: settings)
                    case .rooms:
                        RoomsSettingsView(settings: settings)
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        }
        .frame(minWidth: 700, minHeight: 450)
        .navigationTitle(selectedTab.rawValue)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Закрыть") {
                    dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Сохранить") {
                    settings.save()
                    store.rebuildRoomsData()
                    Task { await store.fetchAllSensors() }
                    dismiss()
                }
                .keyboardShortcut(.return, modifiers: [.command])
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

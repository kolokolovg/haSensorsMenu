import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: SettingsManager
    @ObservedObject var store: HASensorStore
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var languageManager: LanguageManager
    @State private var selectedTab = SettingsTab.connection

    enum SettingsTab: String, CaseIterable, Identifiable {
        case connection
        case rooms
        case switches
        case language
        case appearance

        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .connection: return "server.rack"
            case .rooms: return "house"
            case .switches: return "togglepower"
            case .language: return "globe"
            case .appearance: return "paintbrush"
            }
        }
    }
    
    private func getTabName(_ tab: SettingsTab) -> String {
        switch tab {
        case .connection: return L10n("connection")
        case .rooms: return L10n("rooms")
        case .switches: return L10n("switches")
        case .language: return L10n("language")
        case .appearance: return L10n("appearance")
        }
    }

    var body: some View {
        let _ = languageManager.language  // Создаёт зависимость для SwiftUI
        
        NavigationSplitView {
            List(selection: $selectedTab) {
                ForEach(SettingsTab.allCases) { tab in
                    Label(getTabName(tab), systemImage: tab.icon)
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
                    case .switches:
                        SwitchesSettingsView(settings: settings)
                    case .language:
                        LanguageSettingsView(settings: settings)
                    case .appearance:
                        AppearanceSettingsView(settings: settings)
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        }
        .frame(minWidth: 700, minHeight: 450)
        .navigationTitle(getTabName(selectedTab))
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(L10n("close")) {
                    dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])
            }
            ToolbarItem(placement: .primaryAction) {
                Button(L10n("save")) {
                    settings.save()
                    store.rebuildRoomsData()
                    store.rebuildSwitchesData()
                    Task { await store.fetchAllSensors() }
                    dismiss()
                }
                .keyboardShortcut(.return, modifiers: [.command])
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

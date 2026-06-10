import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: SettingsManager
    @ObservedObject var store: HASensorStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedTab = SettingsTab.connection

    enum SettingsTab: String, CaseIterable, Identifiable {
        case connection
        case rooms
        case language
        case appearance

        var id: String { rawValue }
        
        var displayName: String {
            switch self {
            case .connection: return L10n("connection")
            case .rooms: return L10n("rooms")
            case .language: return L10n("language")
            case .appearance: return L10n("appearance")
            }
        }
        
        var icon: String {
            switch self {
            case .connection: return "server.rack"
            case .rooms: return "house"
            case .language: return "globe"
            case .appearance: return "paintbrush"
            }
        }
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedTab) {
                ForEach(SettingsTab.allCases) { tab in
                    Label(tab.displayName, systemImage: tab.icon)
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
        .navigationTitle(selectedTab.displayName)
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
                    Task { await store.fetchAllSensors() }
                    dismiss()
                }
                .keyboardShortcut(.return, modifiers: [.command])
                .buttonStyle(.borderedProminent)
            }
        }
    }
}

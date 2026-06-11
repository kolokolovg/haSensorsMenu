import SwiftUI

struct MenuContentView: View {
    @ObservedObject var store: HASensorStore

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Switches section
            if !store.switchesData.isEmpty {
                Text(L10n("switches"))
                    .font(.headline)

                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    ForEach(store.switchesData) { switchData in
                        SwitchRowView(switchData: switchData, store: store)
                    }
                }
            }

            // Climate section
            if !store.roomsData.isEmpty {
                Divider()

                Text(L10n("home_climate"))
                    .font(.headline)

                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    ForEach(store.roomsData, id: \.id) { room in
                        RoomView(room: room, settings: store.settings)
                        if room.name != store.roomsData.last?.name {
                            Divider().padding(.vertical, 0)
                        }
                    }
                }
            }

            Divider()

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

            Button(action: {
                Task { await store.fetchAllSensors() }
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text(L10n("refresh_now"))
                }
            }
            .buttonStyle(.plain)
            .padding(.bottom, 4)

            Divider()

            Button(L10n("settings")) {
                SettingsWindowManager.shared.open(settings: store.settings, store: store, languageManager: AppState.shared.languageManager)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 4)

            Divider()

            Button(L10n("quit")) {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .frame(width: 260)
    }
}

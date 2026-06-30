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

            // UPS section
            if let ups = store.upsData {
                Divider()

                HStack {
                    Image(systemName: "bolt.fill")
                        .foregroundColor(ups.isOutOfRange ? .red : .yellow)
                        .frame(width: 20)
                    Text(ups.name)
                        .font(.system(size: 14, weight: .semibold))
                    Spacer()
                    if let voltage = ups.voltageValue {
                        Text(String(format: "%.1f", voltage))
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                            .monospacedDigit()
                    } else {
                        Text("--")
                            .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    }
                    Text(ups.unit)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                        .frame(width: 20)
                    Circle()
                        .fill(ups.isOutOfRange ? Color.red : Color.green)
                        .frame(width: 8, height: 8)
                }
                .padding(.vertical, 2)
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

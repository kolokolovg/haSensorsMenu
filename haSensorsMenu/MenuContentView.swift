import SwiftUI

struct MenuContentView: View {
    @ObservedObject var store: HASensorStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Климат в доме")
                    .font(.headline)
                Spacer()
                Image(systemName: store.isUpdating ? "arrow.triangle.2.circlepath" : "checkmark.circle.fill")
                    .foregroundColor(store.isUpdating ? .blue : .green)
                    .font(.caption)
            }

            Divider()

            VStack(alignment: .leading, spacing: 16) {
                ForEach(store.roomsData, id: \.id) { room in
                    RoomView(room: room)
                    if room.name != store.roomsData.last?.name {
                        Divider().padding(.vertical, 2)
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
                    Text("Обновить сейчас")
                }
            }
            .buttonStyle(.plain)
            .padding(.bottom, 4)

            Divider()

            Button("Настройки...") {
                SettingsWindowManager.shared.open(settings: store.settings, store: store)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 4)

            Divider()

            Button("Выход") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .frame(width: 260)
    }
}

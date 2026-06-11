import SwiftUI

struct RoomsSettingsView: View {
    @ObservedObject var settings: SettingsManager
    @State private var showingAddRoom = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(L10n("configured_rooms"))
                    .font(.headline)
                Spacer()
                Button(action: { showingAddRoom = true }) {
                    Label(L10n("add"), systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }

            if settings.rooms.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "house")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text(L10n("no_rooms"))
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(L10n("add_first_room"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, minHeight: 200)
            } else {
                VStack(spacing: 0) {
                    ForEach($settings.rooms) { $room in
                        RoomConfigRow(room: $room, settings: settings)
                        if room.id != settings.rooms.last?.id {
                            Divider()
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .sheet(isPresented: $showingAddRoom) {
            AddRoomView(settings: settings)
        }
    }
}

struct RoomConfigRow: View {
    @Binding var room: RoomConfig
    @ObservedObject var settings: SettingsManager
    @State private var showingEdit = false

    private var index: Int {
        settings.rooms.firstIndex(where: { $0.id == room.id }) ?? 0
    }

    private var isFirst: Bool { index == 0 }
    private var isLast: Bool { index == settings.rooms.count - 1 }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "house.fill")
                .foregroundColor(.accentColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(room.name)
                    .font(.headline)
                HStack(spacing: 16) {
                    Label(room.tempID, systemImage: "thermometer")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Label(room.humidityID, systemImage: "drop.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Button(action: {
                withAnimation {
                    settings.rooms.move(fromOffsets: IndexSet(integer: index), toOffset: index - 1)
                }
            }) {
                Image(systemName: "chevron.up")
            }
            .buttonStyle(.borderless)
            .disabled(isFirst)
            .help(L10n("edit"))

            Button(action: {
                withAnimation {
                    settings.rooms.move(fromOffsets: IndexSet(integer: index), toOffset: index + 2)
                }
            }) {
                Image(systemName: "chevron.down")
            }
            .buttonStyle(.borderless)
            .disabled(isLast)
            .help(L10n("edit"))

            Button(action: { showingEdit = true }) {
                Image(systemName: "pencil.circle")
            }
            .buttonStyle(.borderless)
            .help(L10n("edit"))

            Button(action: {
                withAnimation {
                    settings.rooms.removeAll { $0.id == room.id }
                }
            }) {
                Image(systemName: "trash.circle")
            }
            .buttonStyle(.borderless)
            .foregroundColor(.red)
            .help(L10n("delete"))
        }
        .padding(.vertical, 12)
        .sheet(isPresented: $showingEdit) {
            EditRoomView(room: $room)
        }
    }
}

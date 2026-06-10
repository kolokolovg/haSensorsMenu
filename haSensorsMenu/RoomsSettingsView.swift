import SwiftUI

struct RoomsSettingsView: View {
    @ObservedObject var settings: SettingsManager
    @State private var showingAddRoom = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Настроенные комнаты")
                    .font(.headline)
                Spacer()
                Button(action: { showingAddRoom = true }) {
                    Label("Добавить", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
            
            if settings.rooms.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "house")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("Нет настроенных комнат")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Добавьте первую комнату, чтобы начать отслеживание")
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
            
            Button(action: { showingEdit = true }) {
                Image(systemName: "pencil.circle")
            }
            .buttonStyle(.borderless)
            .help("Редактировать")
            
            Button(action: {
                withAnimation {
                    settings.rooms.removeAll { $0.id == room.id }
                }
            }) {
                Image(systemName: "trash.circle")
            }
            .buttonStyle(.borderless)
            .foregroundColor(.red)
            .help("Удалить")
        }
        .padding(.vertical, 12)
        .sheet(isPresented: $showingEdit) {
            EditRoomView(room: $room)
        }
    }
}

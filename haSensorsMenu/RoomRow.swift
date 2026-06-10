import SwiftUI

struct RoomRow: View {
    @Binding var room: RoomConfig
    @ObservedObject var settings: SettingsManager
    @State private var showingEdit = false

    var body: some View {
        HStack {
            Text(room.name)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: { showingEdit = true }) {
                Image(systemName: "pencil.circle")
            }
            .buttonStyle(.borderless)
            .help(L10n("edit"))

            Button(action: {
                settings.rooms.removeAll { $0.id == room.id }
            }) {
                Image(systemName: "trash.circle")
            }
            .buttonStyle(.borderless)
            .foregroundColor(.red)
            .help(L10n("delete"))
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingEdit) {
            EditRoomView(room: $room)
        }
    }
}

import SwiftUI

struct EditRoomView: View {
    @Binding var room: RoomConfig
    @Environment(\.dismiss) var dismiss
    @State private var name: String
    @State private var tempID: String
    @State private var humidityID: String

    init(room: Binding<RoomConfig>) {
        self._room = room
        self._name = State(initialValue: room.wrappedValue.name)
        self._tempID = State(initialValue: room.wrappedValue.tempID)
        self._humidityID = State(initialValue: room.wrappedValue.humidityID)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(L10n("edit_room"))
                .font(.title2)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    Text(L10n("name"))
                        .frame(width: 120, alignment: .leading)
                    TextField("", text: $name)
                        .textFieldStyle(.roundedBorder)
                }

                HStack(spacing: 16) {
                    Text(L10n("temperature"))
                        .frame(width: 120, alignment: .leading)
                    TextField("", text: $tempID)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                }

                HStack(spacing: 16) {
                    Text(L10n("humidity"))
                        .frame(width: 120, alignment: .leading)
                    TextField("", text: $humidityID)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                }
            }

            HStack {
                Spacer()
                Button(L10n("cancel")) { dismiss() }
                Button(L10n("save")) {
                    room.name = name
                    room.tempID = tempID
                    room.humidityID = humidityID
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(name.isEmpty || tempID.isEmpty || humidityID.isEmpty)
            }
        }
        .padding(20)
        .frame(width: 500, alignment: .leading)
    }
}

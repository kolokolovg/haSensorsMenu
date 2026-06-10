import SwiftUI

struct AddRoomView: View {
    @ObservedObject var settings: SettingsManager
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var tempID = ""
    @State private var humidityID = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(L10n("add_room"))
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
                Button(L10n("add")) {
                    settings.rooms.append(RoomConfig(name: name, tempID: tempID, humidityID: humidityID))
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

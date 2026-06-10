import SwiftUI

struct AddRoomView: View {
    @ObservedObject var settings: SettingsManager
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var tempID = ""
    @State private var humidityID = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Добавление комнаты")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    Text("Название")
                        .frame(width: 120, alignment: .leading)
                    TextField("", text: $name)
                        .textFieldStyle(.roundedBorder)
                }
                
                HStack(spacing: 16) {
                    Text("Температура")
                        .frame(width: 120, alignment: .leading)
                    TextField("", text: $tempID)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                }
                
                HStack(spacing: 16) {
                    Text("Влажность")
                        .frame(width: 120, alignment: .leading)
                    TextField("", text: $humidityID)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                }
            }
            
            HStack {
                Spacer()
                Button("Отмена") { dismiss() }
                Button("Добавить") {
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

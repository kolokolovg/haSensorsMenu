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
            Text("Редактирование комнаты")
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
                Button("Сохранить") {
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

import SwiftUI

struct RoomView: View {
    let room: RoomDisplayData
    
    var body: some View {
        // Отладка: если это печатается, значит данные есть в UI
        // .onAppear { print("👁️ Отрисовка комнаты: \(room.name), Temp: \(room.tempState?.state ?? "nil")") }
        
        VStack(alignment: .leading, spacing: 8) {
            Text(room.name)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            HStack {
                Image(systemName: "thermometer")
                    .foregroundColor(.orange)
                    .frame(width: 20)
                Text("Температура")
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(room.tempState?.state ?? "--") \(room.tempState?.attributes.unitOfMeasurement ?? "°C")")
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.semibold)
            }
            
            HStack {
                Image(systemName: "drop.fill")
                    .foregroundColor(.blue)
                    .frame(width: 20)
                Text("Влажность")
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(room.humidityState?.state ?? "--") \(room.humidityState?.attributes.unitOfMeasurement ?? "%")")
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.semibold)
            }
        }
    }
}

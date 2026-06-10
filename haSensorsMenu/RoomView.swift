import SwiftUI

struct RoomView: View {
    let room: RoomDisplayData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Название комнаты
            Text(room.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            // Температура
            HStack(spacing: 12) {
                Image(systemName: "thermometer")
                    .foregroundColor(.orange)
                    .frame(width: 20, alignment: .center)
                
                Text("Температура")
                    .foregroundColor(.secondary)
                    .frame(width: 100, alignment: .leading) // Фиксированная ширина
                
                Spacer()
                
                HStack(spacing: 2) {
                    Text(room.tempState?.state ?? "--")
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.semibold)
                    Text(room.tempState?.attributes.unitOfMeasurement ?? "°C")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            
            // Влажность
            HStack(spacing: 12) {
                Image(systemName: "drop.fill")
                    .foregroundColor(.blue)
                    .frame(width: 20, alignment: .center)
                
                Text("Влажность")
                    .foregroundColor(.secondary)
                    .frame(width: 100, alignment: .leading) // Фиксированная ширина
                
                Spacer()
                
                HStack(spacing: 2) {
                    Text(room.humidityState?.state ?? "--")
                        .font(.system(.body, design: .monospaced))
                        .fontWeight(.semibold)
                    Text(room.humidityState?.attributes.unitOfMeasurement ?? "%")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

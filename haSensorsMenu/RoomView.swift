import SwiftUI

struct RoomView: View {
    let room: RoomDisplayData
    @ObservedObject var settings: SettingsManager

    var body: some View {
        Group {
            switch settings.roomCardStyle {
            case .compact:
                compactView
            case .oneLine:
                oneLineView
            }
        }
    }
    
    // ========== ВАРИАНТ 2: COMPACT (оптимизированный) ==========
    var compactView: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Название комнаты
            Text(room.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            // Температура
            sensorRow(
                icon: "thermometer",
                label: L10n("temperature"),
                value: room.tempState?.state,
                unit: "°C",
                iconColor: .orange
            )
            
            // Влажность
            sensorRow(
                icon: "drop.fill",
                label: L10n("humidity"),
                value: room.humidityState?.state,
                unit: "%",
                iconColor: .blue
            )
        }
        .padding(.vertical, 2)
    }
    
    // ========== ВАРИАНТ 3: ONE LINE (максимально компактный) ==========
    var oneLineView: some View {
        HStack(spacing: 7) {
            // Название комнаты (сокращённое)
            Text(abbreviatedRoomName)
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(1)
                .frame(maxWidth: 60, alignment: .leading)
            
            // Разделитель
            Divider()
                .frame(height: 16)
            
            // Температура (компактно)
            HStack(spacing: 2) {
                Image(systemName: "thermometer")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .frame(width: 12)
                
                Text(room.tempState?.state ?? "--")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .monospacedDigit()
                    .frame(width: 45, alignment: .leading)
                
                Text("°C")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 18)
            }
            
            // Влажность (компактно)
            HStack(spacing: 2) {
                Image(systemName: "drop.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .frame(width: 12)
                
                Text(room.humidityState?.state ?? "--")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .monospacedDigit()
                    .frame(width: 45, alignment: .leading)
                
                Text("%")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 15)
            }
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 8)
    }
    
    // ========== ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ==========
    
    /// Генерирует сокращённое имя комнаты для режима oneLine
    /// Примеры: "Living Room" → "LR", "Спальня" → "Сн", "Ванная" → "Вн"
    var abbreviatedRoomName: String {
        let name = room.name.trimmingCharacters(in: .whitespaces)
        
        // Если название короче 6 символов, показать целиком
        if name.count <= 6 {
            return name
        }
        
        // Для многословных названий: первые буквы каждого слова
        let words = name.split(separator: " ").map(String.init)
        if words.count > 1 {
            let abbreviation = words.prefix(3).map { word in
                String(word.prefix(1))
            }.joined()
            return abbreviation
        }
        
        // Для односложных длинных названий: первые 3 буквы
        return String(name.prefix(4))
    }
    
    /// Строка датчика для компактного режима
    func sensorRow(
        icon: String,
        label: String,
        value: String?,
        unit: String,
        iconColor: Color
    ) -> some View {
        HStack(spacing: 0) {
            // Иконка
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(iconColor)
                .frame(width: 20)
            
            // Название датчика
            Text(label)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundColor(.secondary)
                .frame(width: 150, alignment: .leading)
            
            // Spacer для выравнивания вправо
            Spacer()
            
            // Значение
            Text(value ?? "--")
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .monospacedDigit()
                .frame(width: 45, alignment: .leading)
            
            // Единица измерения
            Text(unit)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
                .frame(width: 20, alignment: .center)
        }
    }
}

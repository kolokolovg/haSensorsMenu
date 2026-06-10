import SwiftUI

struct AppearanceSettingsView: View {
    @ObservedObject var settings: SettingsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Заголовок секции
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n("room_card_display"))
                    .font(.headline)
                Text(L10n("room_card_display_desc"))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Выбор стиля отображения
            VStack(alignment: .leading, spacing: 12) {
                Picker(L10n("card_style"), selection: $settings.roomCardStyle) {
                    ForEach(RoomCardStyle.allCases, id: \.self) { style in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(style.displayName)
                                .tag(style)
                        }
                    }
                }
                .pickerStyle(.segmented)
                
                // Описание выбранного стиля
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                        
                        Text(settings.roomCardStyle.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(12)
                .background(Color(.controlBackgroundColor))
                .cornerRadius(6)
            }
            
            Divider()
            
            // Предпросмотр
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n("preview"))
                    .font(.headline)
                
                // Пример карточки
                exampleRoomCard
                    .padding(12)
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(6)
            }
        }
    }
    
    var exampleRoomCard: some View {
        Group {
            switch settings.roomCardStyle {
            case .compact:
                compactExample
            case .oneLine:
                oneLineExample
            }
        }
    }
    
    var compactExample: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(L10n("example_room"))
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 0) {
                Image(systemName: "thermometer")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .frame(width: 20)
                
                Text(L10n("temperature"))
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(width: 70, alignment: .leading)
                
                Spacer()
                
                Text("22")
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .monospacedDigit()
                    .frame(width: 40, alignment: .trailing)
                
                Text("°C")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 20, alignment: .center)
            }
            
            HStack(spacing: 0) {
                Image(systemName: "drop.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .frame(width: 20)
                
                Text(L10n("humidity"))
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(width: 70, alignment: .leading)
                
                Spacer()
                
                Text("60")
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .monospacedDigit()
                    .frame(width: 40, alignment: .trailing)
                
                Text("%")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 20, alignment: .center)
            }
        }
        .padding(.vertical, 2)
    }
    
    var oneLineExample: some View {
        HStack(spacing: 8) {
            Text("Сал")
                .font(.system(size: 13, weight: .semibold))
                .lineLimit(1)
                .frame(maxWidth: 55, alignment: .leading)
            
            Divider()
                .frame(height: 16)
            
            HStack(spacing: 2) {
                Image(systemName: "thermometer")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .frame(width: 12)
                
                Text("22")
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .monospacedDigit()
                    .frame(width: 35, alignment: .trailing)
                
                Text("°C")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 15)
            }
            
            HStack(spacing: 2) {
                Image(systemName: "drop.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .frame(width: 12)
                
                Text("60")
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .monospacedDigit()
                    .frame(width: 35, alignment: .trailing)
                
                Text("%")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 10)
            }
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 8)
    }
}

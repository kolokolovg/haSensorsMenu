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

                menuPreview
                    .frame(width: 260)
                    .padding(12)
                    .background(Color(.controlBackgroundColor))
                    .cornerRadius(6)
            }
        }
    }

    var menuPreview: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n("switches"))
                .font(.headline)

            Divider()

            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                    .frame(width: 20)

                Text("Люстра")
                    .font(.system(size: 14, weight: .medium))

                Spacer()

                Circle()
                    .fill(Color.green)
                    .frame(width: 11, height: 11)
                    .overlay(
                        Circle()
                            .stroke(Color.green.opacity(0.5), lineWidth: 3)
                    )
            }
            .padding(.vertical, 2)

            Divider()

            Text(L10n("home_climate"))
                .font(.headline)

            Divider()

            Group {
                switch settings.roomCardStyle {
                case .compact:
                    compactExample
                case .oneLine:
                    oneLineExample
                }
            }
        }
    }
    
    var compactExample: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(L10n("example_room"))
                .font(.headline)
                .foregroundColor(.primary)

            HStack(spacing: 0) {
                Image(systemName: "thermometer")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .frame(width: 20)

                Text(L10n("temperature"))
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(width: 150, alignment: .leading)

                Spacer()

                Text("22")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .monospacedDigit()
                    .frame(width: 45, alignment: .leading)

                Text("°C")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 20, alignment: .center)
            }

            HStack(spacing: 0) {
                Image(systemName: "drop.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .frame(width: 20)

                Text(L10n("humidity"))
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .foregroundColor(.secondary)
                    .frame(width: 150, alignment: .leading)

                Spacer()

                Text("60")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .monospacedDigit()
                    .frame(width: 45, alignment: .leading)

                Text("%")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 20, alignment: .center)
            }
        }
        .padding(.vertical, 2)
    }

    var oneLineExample: some View {
        HStack(spacing: 7) {
            Text("Сал")
                .font(.system(size: 14, weight: .semibold))
                .lineLimit(1)
                .frame(maxWidth: 60, alignment: .leading)

            Divider()
                .frame(height: 16)

            HStack(spacing: 2) {
                Image(systemName: "thermometer")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .frame(width: 12)

                Text("22")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                    .monospacedDigit()
                    .frame(width: 45, alignment: .leading)

                Text("°C")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 18)
            }

            HStack(spacing: 2) {
                Image(systemName: "drop.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .frame(width: 12)

                Text("60")
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
}

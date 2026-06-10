import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: SettingsManager
    @ObservedObject var store: HASensorStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        // Внешний VStack с spacing: 0, чтобы жестко контролировать разделитель и кнопки
        VStack(spacing: 0) {
            Text("Настройки Home Assistant")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 12)
            
            // Form сам по себе отлично справляется с макетом на macOS.
            // .formStyle(.grouped) делает его похожим на системные настройки.
            Form {
                Section("Подключение") {
                    TextField("URL API (например, http://192.168.1.10:8123/api/states)", text: $settings.baseURL)
                    SecureField("Long-Lived Access Token", text: $settings.token)
                }
                
                Section("Обновление") {
                    HStack {
                        Text("Интервал автоматического опроса")
                        Spacer()
                        Stepper("\(settings.pollingInterval) сек", value: $settings.pollingInterval, in: 10...300, step: 10)
                    }
                }
                
                Section("Комнаты и датчики") {
                    ForEach($settings.rooms) { $room in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                TextField("Название комнаты", text: $room.name)
                                    .textFieldStyle(.roundedBorder)
                                Button(role: .destructive) {
                                    settings.rooms.removeAll { $0.id == room.id }
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .buttonStyle(.borderless)
                                .help("Удалить комнату")
                            }
                            HStack {
                                Text("ID датчика температуры:")
                                TextField("sensor.xxx_temp", text: $room.tempID)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.system(.body, design: .monospaced))
                            }
                            HStack {
                                Text("ID датчика влажности:")
                                TextField("sensor.xxx_humidity", text: $room.humidityID)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.system(.body, design: .monospaced))
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Button(action: {
                        let newRoom = RoomConfig(name: "Новая комната", tempID: "sensor.new_temp", humidityID: "sensor.new_humidity")
                        settings.rooms.append(newRoom)
                    }) {
                        Label("Добавить комнату", systemImage: "plus.circle.fill")
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
                }
            }
            .formStyle(.grouped) // Ключевой модификатор для нативного вида macOS
            .frame(minHeight: 300) // Гарантируем, что форма не схлопнется
            
            // Разделитель жестко отделяет форму от кнопок
            Divider()
                .padding(.vertical, 12)
            
            // Нижняя панель с кнопками всегда видна и прижата к низу
            HStack {
                Spacer()
                Button("Отмена") {
                    dismiss()
                }
                .keyboardShortcut(.escape, modifiers: [])
                
                Button("Сохранить и обновить") {
                    settings.save()
                    store.rebuildRoomsData()
                    Task { await store.fetchAllSensors() }
                    dismiss()
                }
                .keyboardShortcut(.return, modifiers: [.command])
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
            .padding(.bottom, 4)
        }
        .padding()
        .frame(minWidth: 450, minHeight: 450) // Минимальный размер окна
    }
}

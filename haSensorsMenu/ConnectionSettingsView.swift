import SwiftUI

struct ConnectionSettingsView: View {
    @ObservedObject var settings: SettingsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Сервер Home Assistant")
                    .font(.headline)
                
                HStack(spacing: 16) {
                    Text("Адрес сервера")
                        .frame(width: 140, alignment: .leading)
                    TextField("", text: $settings.baseURL)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity)
                }
                
                HStack(spacing: 16) {
                    Text("Токен доступа")
                        .frame(width: 140, alignment: .leading)
                    SecureField("", text: $settings.token)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity)
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Обновление данных")
                    .font(.headline)
                
                HStack(spacing: 16) {
                    Text("Интервал опроса")
                        .frame(width: 140, alignment: .leading)
                    Stepper("\(settings.pollingInterval) сек", value: $settings.pollingInterval, in: 10...300, step: 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

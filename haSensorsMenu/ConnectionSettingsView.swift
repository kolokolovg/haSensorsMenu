import SwiftUI

struct ConnectionSettingsView: View {
    @ObservedObject var settings: SettingsManager

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n("ha_server"))
                    .font(.headline)

                HStack(spacing: 16) {
                    Text(L10n("server_address"))
                        .frame(width: 140, alignment: .leading)
                    TextField("", text: $settings.baseURL)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity)
                }

                HStack(spacing: 16) {
                    Text(L10n("access_token"))
                        .frame(width: 140, alignment: .leading)
                    SecureField("", text: $settings.token)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: .infinity)
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text(L10n("data_update"))
                    .font(.headline)

                HStack(spacing: 16) {
                    Text(L10n("polling_interval"))
                        .frame(width: 140, alignment: .leading)
                    Stepper("\(settings.pollingInterval) \(L10n("sec"))", value: $settings.pollingInterval, in: 10...300, step: 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

import SwiftUI

struct UPSSettingsView: View {
    @ObservedObject var settings: SettingsManager

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n("ups_settings"))
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 16) {
                    Text(L10n("ups_entity_id"))
                        .frame(width: 160, alignment: .leading)
                    TextField("sensor.ups_input_voltage", text: $settings.upsConfig.entityID)
                        .textFieldStyle(.roundedBorder)
                        .font(.system(.body, design: .monospaced))
                }

                HStack(spacing: 16) {
                    Text(L10n("ups_name"))
                        .frame(width: 160, alignment: .leading)
                    TextField("UPS", text: $settings.upsConfig.name)
                        .textFieldStyle(.roundedBorder)
                }

                HStack(spacing: 16) {
                    Text(L10n("min_voltage"))
                        .frame(width: 160, alignment: .leading)
                    TextField("", value: $settings.upsConfig.minVoltage, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 120)
                }

                HStack(spacing: 16) {
                    Text(L10n("max_voltage"))
                        .frame(width: 160, alignment: .leading)
                    TextField("", value: $settings.upsConfig.maxVoltage, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 120)
                }

                Toggle(L10n("enable_alerts"), isOn: $settings.upsConfig.alertsEnabled)
                    .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

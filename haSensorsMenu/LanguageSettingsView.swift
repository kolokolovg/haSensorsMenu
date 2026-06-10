import SwiftUI

struct LanguageSettingsView: View {
    @ObservedObject var settings: SettingsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n("language_settings"))
                    .font(.headline)
                
                Picker(L10n("select_language"), selection: $settings.language) {
                    Text(L10n("russian")).tag("ru")
                    Text(L10n("english")).tag("en")
                }
                .pickerStyle(.radioGroup)
                .padding(.vertical, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

import Foundation
import Combine
import SwiftUI

class LanguageManager: ObservableObject {
    @Published var language: String
    
    init() {
        let savedLanguage = UserDefaults.standard.string(forKey: "ha_language") ?? "ru"
        self.language = savedLanguage
        Bundle.setLanguage(savedLanguage)
    }
    
    var languageBinding: Binding<String> {
        Binding(
            get: { self.language },
            set: { newValue in
                // ← СНАЧАЛА обновляем Bundle (перед изменением @Published)
                Bundle.setLanguage(newValue)
                UserDefaults.standard.set(newValue, forKey: "ha_language")
                // ← ПОТОМ обновляем @Published (это вызовет objectWillChange)
                self.language = newValue
            }
        )
    }
}

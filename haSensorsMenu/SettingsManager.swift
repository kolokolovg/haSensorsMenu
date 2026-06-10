import Foundation
import Combine

@MainActor
class SettingsManager: ObservableObject {
    @Published var baseURL: String
    @Published var token: String
    @Published var rooms: [RoomConfig]
    @Published var pollingInterval: Int
    
    private let defaults = UserDefaults.standard
    private let urlKey = "ha_base_url"
    private let tokenKey = "ha_token"
    private let roomsKey = "ha_rooms"
    private let intervalKey = "ha_polling_interval"
    
    init() {
        self.baseURL = defaults.string(forKey: urlKey) ?? "http://homeassistant.local:8123/api/states"
        self.token = defaults.string(forKey: tokenKey) ?? "Bearer YOUR_TOKEN_HERE"
        
        let savedInterval = defaults.integer(forKey: intervalKey)
        self.pollingInterval = (savedInterval >= 10) ? savedInterval : 60
        
        if let data = defaults.data(forKey: roomsKey),
           let decoded = try? JSONDecoder().decode([RoomConfig].self, from: data) {
            self.rooms = decoded
        } else {
            self.rooms = [
                RoomConfig(name: "🛋️ Гостиная", tempID: "sensor.living_room_temp", humidityID: "sensor.living_room_humidity"),
                RoomConfig(name: "🛏️ Спальня", tempID: "sensor.bedroom_temp", humidityID: "sensor.bedroom_humidity")
            ]
            save()
        }
    }
    
    func save() {
        defaults.set(baseURL, forKey: urlKey)
        defaults.set(token, forKey: tokenKey)
        defaults.set(pollingInterval, forKey: intervalKey)
        if let encoded = try? JSONEncoder().encode(rooms) {
            defaults.set(encoded, forKey: roomsKey)
        }
    }
}

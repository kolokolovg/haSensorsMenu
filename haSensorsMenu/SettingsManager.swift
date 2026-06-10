import Foundation
import Combine

class SettingsManager: ObservableObject {
    @Published var baseURL: String
    @Published var token: String
    @Published var pollingInterval: Int
    @Published var rooms: [RoomConfig]
    @Published var language: String {
        didSet {
            Bundle.setLanguage(language)
            objectWillChange.send()
        }
    }
    @Published var roomCardStyle: RoomCardStyle {
        didSet {
            UserDefaults.standard.set(roomCardStyle.rawValue, forKey: "ha_room_card_style")
        }
    }

    private let saveQueue = DispatchQueue(label: "com.hasensors.settings", qos: .background)
    private var cancellables = Set<AnyCancellable>()

    init() {
        let defaults = UserDefaults.standard
        
        let loadedBaseURL = defaults.string(forKey: "ha_base_url") ?? ""
        let loadedToken = defaults.string(forKey: "ha_token") ?? ""
        
        let interval = defaults.integer(forKey: "ha_polling_interval")
        let loadedPollingInterval = interval == 0 ? 60 : interval
        
        let loadedLanguage = defaults.string(forKey: "ha_language") ?? "ru"
        
        let loadedRooms = SettingsManager.loadRooms()
        
        let cardStyleString = defaults.string(forKey: "ha_room_card_style") ?? "compact"
        let loadedCardStyle = RoomCardStyle(rawValue: cardStyleString) ?? .compact
        
        self.baseURL = loadedBaseURL
        self.token = loadedToken
        self.pollingInterval = loadedPollingInterval
        self.rooms = loadedRooms
        self.language = loadedLanguage
        self.roomCardStyle = loadedCardStyle

        // Устанавливаем язык сразу при инициализации
        Bundle.setLanguage(loadedLanguage)
        
        setupObservers()
    }

    private func setupObservers() {
        $baseURL.dropFirst().sink { [weak self] _ in self?.save() }.store(in: &cancellables)
        $token.dropFirst().sink { [weak self] _ in self?.save() }.store(in: &cancellables)
        $pollingInterval.dropFirst().sink { [weak self] _ in self?.save() }.store(in: &cancellables)
        $rooms.dropFirst().sink { [weak self] _ in self?.save() }.store(in: &cancellables)
        $language.dropFirst().sink { [weak self] _ in self?.save() }.store(in: &cancellables)
        $roomCardStyle.dropFirst().sink { [weak self] _ in self?.save() }.store(in: &cancellables)
    }

    func save() {
        saveQueue.async { [weak self] in
            guard let self = self else { return }
            let defaults = UserDefaults.standard
            defaults.set(self.baseURL, forKey: "ha_base_url")
            defaults.set(self.token, forKey: "ha_token")
            defaults.set(self.pollingInterval, forKey: "ha_polling_interval")
            defaults.set(self.language, forKey: "ha_language")
            defaults.set(self.roomCardStyle.rawValue, forKey: "ha_room_card_style")
            defaults.set(try? JSONEncoder().encode(self.rooms), forKey: "ha_rooms")
        }
    }

    private static func loadRooms() -> [RoomConfig] {
        guard let data = UserDefaults.standard.data(forKey: "ha_rooms") else {
            return []
        }
        
        do {
            let rooms = try JSONDecoder().decode([RoomConfig].self, from: data)
            return rooms
        } catch {
            return []
        }
    }
}

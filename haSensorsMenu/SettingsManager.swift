import Foundation
import Combine

class SettingsManager: ObservableObject {
    @Published var baseURL: String {
        didSet {
            if !apiBaseURLManuallySet {
                DispatchQueue.main.async { [weak self] in
                    self?.apiBaseURL = SettingsManager.deriveAPIBaseURL(from: self?.baseURL ?? "")
                }
            }
        }
    }
    @Published var apiBaseURL: String
    @Published var token: String
    @Published var pollingInterval: Int
    @Published var rooms: [RoomConfig]
    @Published var switches: [HASwitchConfig]
    @Published var language: String {
        didSet {
            Bundle.setLanguage(language)
            DispatchQueue.main.async { [weak self] in
                self?.objectWillChange.send()
            }
        }
    }
    @Published var roomCardStyle: RoomCardStyle {
        didSet {
            UserDefaults.standard.set(roomCardStyle.rawValue, forKey: "ha_room_card_style")
        }
    }

    private var apiBaseURLManuallySet = false
    private let saveQueue = DispatchQueue(label: "com.hasensors.settings", qos: .background)
    private var cancellables = Set<AnyCancellable>()

    init() {
        let defaults = UserDefaults.standard
        
        let loadedBaseURL = defaults.string(forKey: "ha_base_url") ?? ""
        let loadedToken = defaults.string(forKey: "ha_token") ?? ""
        let loadedAPIBaseURL = defaults.string(forKey: "ha_api_base_url") ?? ""
        
        let interval = defaults.integer(forKey: "ha_polling_interval")
        let loadedPollingInterval = interval == 0 ? 60 : interval
        
        let loadedLanguage = defaults.string(forKey: "ha_language") ?? "ru"
        
        let loadedRooms = SettingsManager.loadRooms()
        let loadedSwitches = SettingsManager.loadSwitches()
        
        let cardStyleString = defaults.string(forKey: "ha_room_card_style") ?? "compact"
        let loadedCardStyle = RoomCardStyle(rawValue: cardStyleString) ?? .compact
        
        self.baseURL = loadedBaseURL
        self.token = loadedToken

        let derived = SettingsManager.deriveAPIBaseURL(from: loadedBaseURL)
        if !loadedAPIBaseURL.isEmpty {
            self.apiBaseURL = loadedAPIBaseURL
            self.apiBaseURLManuallySet = true
        } else {
            self.apiBaseURL = derived
        }
        self.pollingInterval = loadedPollingInterval
        self.rooms = loadedRooms
        self.switches = loadedSwitches
        self.language = loadedLanguage
        self.roomCardStyle = loadedCardStyle

        // Устанавливаем язык сразу при инициализации
        Bundle.setLanguage(loadedLanguage)
        
        setupObservers()
    }

    private func setupObservers() {
        $baseURL.dropFirst().sink { [weak self] _ in self?.save() }.store(in: &cancellables)
        $apiBaseURL.dropFirst().sink { [weak self] _ in
            self?.apiBaseURLManuallySet = true
            self?.save()
        }.store(in: &cancellables)
        $token.dropFirst().sink { [weak self] _ in self?.save() }.store(in: &cancellables)
        $pollingInterval.dropFirst().sink { [weak self] _ in self?.save() }.store(in: &cancellables)
        $rooms.dropFirst().sink { [weak self] _ in self?.save() }.store(in: &cancellables)
        $switches.dropFirst().sink { [weak self] _ in self?.save() }.store(in: &cancellables)
        $language.dropFirst().sink { [weak self] _ in self?.save() }.store(in: &cancellables)
        $roomCardStyle.dropFirst().sink { [weak self] _ in self?.save() }.store(in: &cancellables)
    }

    func save() {
        saveQueue.async { [weak self] in
            guard let self = self else { return }
            let defaults = UserDefaults.standard
            defaults.set(self.baseURL, forKey: "ha_base_url")
            defaults.set(self.apiBaseURL, forKey: "ha_api_base_url")
            defaults.set(self.token, forKey: "ha_token")
            defaults.set(self.pollingInterval, forKey: "ha_polling_interval")
            defaults.set(self.language, forKey: "ha_language")
            defaults.set(self.roomCardStyle.rawValue, forKey: "ha_room_card_style")
            defaults.set(try? JSONEncoder().encode(self.rooms), forKey: "ha_rooms")
            defaults.set(try? JSONEncoder().encode(self.switches), forKey: "ha_switches")
        }
    }

    private static func deriveAPIBaseURL(from url: String) -> String {
        var result = url
        if result.hasSuffix("/states") {
            result = String(result.dropLast(7))
        } else if result.hasSuffix("/states/") {
            result = String(result.dropLast(8))
        }
        if result.hasSuffix("/") {
            result = String(result.dropLast())
        }
        return result
    }

    private static func loadSwitches() -> [HASwitchConfig] {
        guard let data = UserDefaults.standard.data(forKey: "ha_switches") else {
            return []
        }
        return (try? JSONDecoder().decode([HASwitchConfig].self, from: data)) ?? []
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

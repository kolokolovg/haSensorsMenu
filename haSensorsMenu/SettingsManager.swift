import Foundation
import Combine
import ServiceManagement

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
    @Published var roomCardStyle: RoomCardStyle {
        didSet {
            UserDefaults.standard.set(roomCardStyle.rawValue, forKey: "ha_room_card_style")
        }
    }
    @Published var upsConfig: UPSConfig
    @Published var launchAtLogin: Bool
    @Published var launchAtLoginErrorMessage: String?

    private var apiBaseURLManuallySet = false
    private var isApplyingLoginItem = false
    private let saveQueue = DispatchQueue(label: "com.hasensors.settings", qos: .background)
    private var cancellables = Set<AnyCancellable>()

    init() {
        let defaults = UserDefaults.standard
        
        let loadedBaseURL = defaults.string(forKey: "ha_base_url") ?? ""
        let loadedToken = defaults.string(forKey: "ha_token") ?? ""
        let loadedAPIBaseURL = defaults.string(forKey: "ha_api_base_url") ?? ""
        
        let interval = defaults.integer(forKey: "ha_polling_interval")
        let loadedPollingInterval = interval == 0 ? 60 : interval
        
        let loadedRooms = SettingsManager.loadRooms()
        let loadedSwitches = SettingsManager.loadSwitches()
        
        let cardStyleString = defaults.string(forKey: "ha_room_card_style") ?? "compact"
        let loadedCardStyle = RoomCardStyle(rawValue: cardStyleString) ?? .compact
        
        let loadedUPSConfig = SettingsManager.loadUPSConfig()
        let loadedLaunchAtLogin = defaults.bool(forKey: "ha_launch_at_login")
        
        self.upsConfig = loadedUPSConfig
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
        self.roomCardStyle = loadedCardStyle
        self.launchAtLogin = loadedLaunchAtLogin
        self.launchAtLoginErrorMessage = nil
        
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
        $upsConfig.dropFirst().sink { [weak self] _ in self?.save() }.store(in: &cancellables)
        $roomCardStyle.dropFirst().sink { [weak self] _ in self?.save() }.store(in: &cancellables)
        $launchAtLogin.dropFirst().sink { [weak self] newValue in
            guard let self = self, !self.isApplyingLoginItem else { return }
            self.isApplyingLoginItem = true
            defer { self.isApplyingLoginItem = false }
            do {
                if newValue {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
                UserDefaults.standard.set(newValue, forKey: "ha_launch_at_login")
            } catch {
                self.launchAtLoginErrorMessage = error.localizedDescription
                self.launchAtLogin = !newValue
            }
        }.store(in: &cancellables)
    }

    func save() {
        saveQueue.async { [weak self] in
            guard let self = self else { return }
            let defaults = UserDefaults.standard
            defaults.set(self.baseURL, forKey: "ha_base_url")
            defaults.set(self.apiBaseURL, forKey: "ha_api_base_url")
            defaults.set(self.token, forKey: "ha_token")
            defaults.set(self.pollingInterval, forKey: "ha_polling_interval")
            defaults.set(self.roomCardStyle.rawValue, forKey: "ha_room_card_style")
            defaults.set(self.launchAtLogin, forKey: "ha_launch_at_login")
            defaults.set(try? JSONEncoder().encode(self.rooms), forKey: "ha_rooms")
            defaults.set(try? JSONEncoder().encode(self.switches), forKey: "ha_switches")
            defaults.set(try? JSONEncoder().encode(self.upsConfig), forKey: "ha_ups_config")
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

    private static func loadUPSConfig() -> UPSConfig {
        guard let data = UserDefaults.standard.data(forKey: "ha_ups_config"),
              let config = try? JSONDecoder().decode(UPSConfig.self, from: data) else {
            return UPSConfig()
        }
        return config
    }
}

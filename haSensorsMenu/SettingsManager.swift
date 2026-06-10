import Foundation
import Combine

class SettingsManager: ObservableObject {
    @Published var baseURL: String
    @Published var token: String
    @Published var pollingInterval: Int
    @Published var rooms: [RoomConfig]

    private let saveQueue = DispatchQueue(label: "com.hasensors.settings", qos: .background)
    private var cancellables = Set<AnyCancellable>()

    init() {
        let defaults = UserDefaults.standard
        
        let loadedBaseURL = defaults.string(forKey: "ha_base_url") ?? ""
        let loadedToken = defaults.string(forKey: "ha_token") ?? ""
        
        let interval = defaults.integer(forKey: "ha_polling_interval")
        let loadedPollingInterval = interval == 0 ? 60 : interval
        
        print("Загружено: baseURL=\(loadedBaseURL), pollingInterval=\(loadedPollingInterval)")
        
        let loadedRooms = SettingsManager.loadRooms()
        print("Загружено комнат: \(loadedRooms.count)")
        
        self.baseURL = loadedBaseURL
        self.token = loadedToken
        self.pollingInterval = loadedPollingInterval
        self.rooms = loadedRooms

        setupObservers()
    }

    private func setupObservers() {
        $baseURL.dropFirst().sink { [weak self] _ in self?.save() }.store(in: &cancellables)
        $token.dropFirst().sink { [weak self] _ in self?.save() }.store(in: &cancellables)
        $pollingInterval.dropFirst().sink { [weak self] _ in self?.save() }.store(in: &cancellables)
        $rooms.dropFirst().sink { [weak self] _ in self?.save() }.store(in: &cancellables)
    }

    func save() {
        saveQueue.async { [weak self] in
            guard let self = self else { return }
            let defaults = UserDefaults.standard
            defaults.set(self.baseURL, forKey: "ha_base_url")
            defaults.set(self.token, forKey: "ha_token")
            defaults.set(self.pollingInterval, forKey: "ha_polling_interval")
            defaults.set(try? JSONEncoder().encode(self.rooms), forKey: "ha_rooms")
            print("Сохранено: baseURL=\(self.baseURL), rooms=\(self.rooms.count)")
        }
    }

    private static func loadRooms() -> [RoomConfig] {
        guard let data = UserDefaults.standard.data(forKey: "ha_rooms") else {
            print("Данные комнат не найдены в UserDefaults")
            return []
        }
        
        print("Размер данных комнат: \(data.count) байт")
        
        do {
            let rooms = try JSONDecoder().decode([RoomConfig].self, from: data)
            print("Успешно загружено \(rooms.count) комнат")
            return rooms
        } catch {
            print("Ошибка декодирования комнат: \(error)")
            print("Данные: \(String(data: data, encoding: .utf8) ?? "не читаемо")")
            return []
        }
    }
}

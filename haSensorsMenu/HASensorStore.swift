import Foundation
import Combine

class AllowAllCertificatesDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let trust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

@MainActor
class HASensorStore: ObservableObject {
    @Published var roomsData: [RoomDisplayData] = []
    @Published var isUpdating: Bool = false
    @Published var lastUpdated: String = "Никогда"
    
    private var timerTask: Task<Void, Never>?
    private let settings: SettingsManager
    
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 30
        let delegate = AllowAllCertificatesDelegate()
        return URLSession(configuration: config, delegate: delegate, delegateQueue: nil)
    }()
    
    init(settings: SettingsManager) {
        self.settings = settings
        rebuildRoomsData()
    }
    
    func rebuildRoomsData() {
        roomsData = settings.rooms.map { config in
            RoomDisplayData(
                id: config.tempID,
                name: config.name,
                tempID: config.tempID,
                humidityID: config.humidityID
            )
        }
    }
    
    func startFetching() {
        Task { await fetchAllSensors() }
        
        timerTask = Task {
            while !Task.isCancelled {
                let interval = await MainActor.run { max(10, self.settings.pollingInterval) }
                try? await Task.sleep(for: .seconds(interval))
                if !Task.isCancelled {
                    await fetchAllSensors()
                }
            }
        }
    }
    
    func fetchAllSensors() async {
        isUpdating = true
        
        var fetchedSensors: [String: HASensor] = [:]
        var allEntityIds: [String] = []
        
        for room in self.roomsData {
            allEntityIds.append(room.tempID)
            allEntityIds.append(room.humidityID)
        }
        
        await withTaskGroup(of: (String, HASensor?).self) { group in
            for entityId in allEntityIds {
                group.addTask {
                    let sensor = await self.fetchSensor(id: entityId, token: self.settings.token, baseURL: self.settings.baseURL)
                    return (entityId, sensor)
                }
            }
            
            for await (entityId, sensor) in group {
                if let sensor = sensor {
                    fetchedSensors[entityId] = sensor
                }
            }
        }
        
        var newRoomsData: [RoomDisplayData] = []
        for config in self.settings.rooms {
            let displayRoom = RoomDisplayData(
                id: config.tempID,
                name: config.name,
                tempID: config.tempID,
                humidityID: config.humidityID,
                tempState: fetchedSensors[config.tempID],
                humidityState: fetchedSensors[config.humidityID]
            )
            newRoomsData.append(displayRoom)
        }
        
        // Эта строка критически важна для обновления MenuBarExtra
        self.objectWillChange.send()
        self.roomsData = newRoomsData
        
        isUpdating = false
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        self.lastUpdated = "Обновлено: \(formatter.string(from: Date()))"
    }
    
    private func fetchSensor(id: String, token: String, baseURL: String) async -> HASensor? {
        guard let url = URL(string: "\(baseURL)/\(id)") else { return nil }
        
        var request = URLRequest(url: url)
        let authHeader = token.hasPrefix("Bearer ") ? token : "Bearer \(token)"
        request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                return nil
            }
            return try JSONDecoder().decode(HASensor.self, from: data)
        } catch {
            return nil
        }
    }
}

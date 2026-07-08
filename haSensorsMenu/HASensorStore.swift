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
    @Published var switchesData: [HASwitchDisplayData] = []
    @Published var upsData: UPSDisplayData?
    @Published var isUpdating: Bool = false
    @Published var lastUpdated: String = "Никогда"
    
    private var timerTask: Task<Void, Never>?
    private var upsTimerTask: Task<Void, Never>?
    private var wasUPSOutOfRange = false
    let voltageHistory = VoltageHistoryManager()
    let settings: SettingsManager // Делаем public, чтобы MenuContentView мог его передать
    
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
        rebuildSwitchesData()
        rebuildUPSData()
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

    func rebuildSwitchesData() {
        switchesData = settings.switches.map { config in
            HASwitchDisplayData(
                id: config.id,
                name: config.name,
                entityID: config.entityID
            )
        }
    }

    func rebuildUPSData() {
        let config = settings.upsConfig
        upsData = UPSDisplayData(
            id: config.id,
            name: config.name,
            entityID: config.entityID,
            state: nil,
            minVoltage: config.minVoltage,
            maxVoltage: config.maxVoltage
        )
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

        startUPSPolling()
    }
    
    func fetchAllSensors() async {
        isUpdating = true
        
        var fetchedSensors: [String: HASensor] = [:]
        var allEntityIds: [String] = []
        
        for room in self.roomsData {
            allEntityIds.append(room.tempID)
            allEntityIds.append(room.humidityID)
        }
        for switchConfig in self.switchesData {
            allEntityIds.append(switchConfig.entityID)
        }
        
        await withTaskGroup(of: (String, HASensor?).self) { group in
            for entityId in allEntityIds {
                group.addTask {
                    let sensor = await self.fetchSensor(id: entityId, token: self.settings.token, apiBaseURL: self.settings.apiBaseURL)
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
        self.roomsData = newRoomsData
        
        var newSwitchesData: [HASwitchDisplayData] = []
        for config in self.settings.switches {
            let sensor = fetchedSensors[config.entityID]
            newSwitchesData.append(HASwitchDisplayData(
                id: config.id,
                name: config.name,
                entityID: config.entityID,
                isOn: sensor?.state == "on"
            ))
        }
        self.switchesData = newSwitchesData
        
        isUpdating = false
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        self.lastUpdated = "Обновлено: \(formatter.string(from: Date()))"
    }

    private func startUPSPolling() {
        Task { await fetchUPS() }

        upsTimerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(10))
                if !Task.isCancelled {
                    await fetchUPS()
                }
            }
        }
    }

    func fetchUPS() async {
        let config = self.settings.upsConfig
        guard !config.entityID.isEmpty else { return }

        let sensor = await fetchSensor(id: config.entityID, token: settings.token, apiBaseURL: settings.apiBaseURL)
        let newUPSData = UPSDisplayData(
            id: config.id,
            name: config.name,
            entityID: config.entityID,
            state: sensor,
            minVoltage: config.minVoltage,
            maxVoltage: config.maxVoltage
        )
        self.upsData = newUPSData

        if let voltage = newUPSData.voltageValue {
            voltageHistory.appendSample(value: voltage)
        }

        if config.alertsEnabled, let voltage = newUPSData.voltageValue, newUPSData.isOutOfRange {
            if !wasUPSOutOfRange {
                wasUPSOutOfRange = true
                NotificationManager.sendVoltageAlert(
                    name: config.name,
                    voltage: voltage,
                    unit: newUPSData.unit,
                    min: config.minVoltage,
                    max: config.maxVoltage
                )
                voltageHistory.retentionDays = config.alertHistoryDays ?? 7
                voltageHistory.appendAlert(
                    voltage: voltage,
                    minVoltage: config.minVoltage,
                    maxVoltage: config.maxVoltage,
                    unit: newUPSData.unit,
                    name: config.name
                )
            }
        } else {
            wasUPSOutOfRange = false
        }
    }
    
    func toggleSwitch(entityID: String) async {
        let domain = entityID.components(separatedBy: ".").first ?? ""
        guard let url = URL(string: "\(settings.apiBaseURL)/services/\(domain)/toggle") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let authHeader = settings.token.hasPrefix("Bearer ") ? settings.token : "Bearer \(settings.token)"
        request.setValue(authHeader, forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["entity_id": entityID])
        
        do {
            let (_, response) = try await urlSession.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                if let index = switchesData.firstIndex(where: { $0.entityID == entityID }) {
                    switchesData[index].isOn.toggle()
                }
            }
        } catch {}
    }
    
    private func fetchSensor(id: String, token: String, apiBaseURL: String) async -> HASensor? {
        guard let url = URL(string: "\(apiBaseURL)/states/\(id)") else { return nil }
        
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

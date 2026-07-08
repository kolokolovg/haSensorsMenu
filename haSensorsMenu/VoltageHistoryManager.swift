import Foundation
import Combine

@MainActor
class VoltageHistoryManager: ObservableObject {
    @Published var samples: [VoltageSample] = []
    @Published var alertHistory: [AlertEvent] = []

    private let samplesURL: URL
    private let alertsURL: URL
    private let maxAge: TimeInterval = 60 * 60

    var retentionDays: Int = 7

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = appSupport.appendingPathComponent("haSensorsMenu")
        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        samplesURL = appDir.appendingPathComponent("voltage_history.json")
        alertsURL = appDir.appendingPathComponent("alert_history.json")
        load()
    }

    func appendSample(value: Double) {
        let sample = VoltageSample(value: value)
        samples.append(sample)
        prune()
        saveSamples()
    }

    private func prune() {
        let cutoff = Date().addingTimeInterval(-maxAge)
        samples.removeAll { $0.timestamp < cutoff }
    }

    func appendAlert(voltage: Double, minVoltage: Double, maxVoltage: Double, unit: String, name: String) {
        let event = AlertEvent(voltage: voltage, minVoltage: minVoltage, maxVoltage: maxVoltage, unit: unit, name: name)
        alertHistory.append(event)
        pruneAlerts()
        saveAlerts()
    }

    func clearAlerts() {
        alertHistory.removeAll()
        saveAlerts()
    }

    private func pruneAlerts() {
        let cutoff = Calendar.current.date(byAdding: .day, value: -retentionDays, to: Date()) ?? Date()
        alertHistory.removeAll { $0.timestamp < cutoff }
    }

    private func load() {
        loadSamples()
        loadAlerts()
    }

    private func loadSamples() {
        guard let data = try? Data(contentsOf: samplesURL),
              let decoded = try? JSONDecoder().decode([VoltageSample].self, from: data) else {
            return
        }
        samples = decoded
        prune()
    }

    private func saveSamples() {
        guard let data = try? JSONEncoder().encode(samples) else { return }
        try? data.write(to: samplesURL, options: .atomic)
    }

    private func loadAlerts() {
        guard let data = try? Data(contentsOf: alertsURL),
              let decoded = try? JSONDecoder().decode([AlertEvent].self, from: data) else {
            return
        }
        alertHistory = decoded
        pruneAlerts()
    }

    private func saveAlerts() {
        guard let data = try? JSONEncoder().encode(alertHistory) else { return }
        try? data.write(to: alertsURL, options: .atomic)
    }
}

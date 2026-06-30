import Foundation
import Combine

@MainActor
class VoltageHistoryManager: ObservableObject {
    @Published var samples: [VoltageSample] = []

    private let fileURL: URL
    private let maxAge: TimeInterval = 60 * 60

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = appSupport.appendingPathComponent("haSensorsMenu")
        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        fileURL = appDir.appendingPathComponent("voltage_history.json")
        load()
    }

    func appendSample(value: Double) {
        let sample = VoltageSample(value: value)
        samples.append(sample)
        prune()
        save()
    }

    private func prune() {
        let cutoff = Date().addingTimeInterval(-maxAge)
        samples.removeAll { $0.timestamp < cutoff }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([VoltageSample].self, from: data) else {
            return
        }
        samples = decoded
        prune()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(samples) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}

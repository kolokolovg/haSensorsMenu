import Foundation

enum RoomCardStyle: String, CaseIterable, Codable {
    case compact = "compact"
    case oneLine = "oneLine"
    
    var displayName: String {
        switch self {
        case .compact:
            return L10n("room_card_style_compact")
        case .oneLine:
            return L10n("room_card_style_oneline")
        }
    }
    
    var description: String {
        switch self {
        case .compact:
            return L10n("room_card_style_compact_desc")
        case .oneLine:
            return L10n("room_card_style_oneline_desc")
        }
    }
}

struct RoomConfig: Identifiable, Codable {
    var id: UUID
    var name: String
    var tempID: String
    var humidityID: String

    init(id: UUID = UUID(), name: String, tempID: String, humidityID: String) {
        self.id = id
        self.name = name
        self.tempID = tempID
        self.humidityID = humidityID
    }
}

struct HASensor: Codable {
    let entityId: String
    let state: String
    let attributes: HAAttributes

    enum CodingKeys: String, CodingKey {
        case entityId = "entity_id"
        case state
        case attributes
    }
}

struct HAAttributes: Codable {
    let unitOfMeasurement: String?
    let friendlyName: String?

    enum CodingKeys: String, CodingKey {
        case unitOfMeasurement = "unit_of_measurement"
        case friendlyName = "friendly_name"
    }
}

struct HASwitchConfig: Identifiable, Codable {
    var id: UUID
    var name: String
    var entityID: String

    init(id: UUID = UUID(), name: String, entityID: String) {
        self.id = id
        self.name = name
        self.entityID = entityID
    }
}

struct HASwitchDisplayData: Identifiable {
    let id: UUID
    let name: String
    let entityID: String
    var isOn: Bool

    var domain: String {
        entityID.components(separatedBy: ".").first ?? ""
    }

    init(id: UUID, name: String, entityID: String, isOn: Bool = false) {
        self.id = id
        self.name = name
        self.entityID = entityID
        self.isOn = isOn
    }
}

struct UPSConfig: Codable {
    var id: UUID
    var name: String
    var entityID: String
    var minVoltage: Double
    var maxVoltage: Double
    var alertsEnabled: Bool

    init(id: UUID = UUID(), name: String = "UPS", entityID: String = "sensor.ups_input_voltage",
         minVoltage: Double = 210, maxVoltage: Double = 245, alertsEnabled: Bool = true) {
        self.id = id
        self.name = name
        self.entityID = entityID
        self.minVoltage = minVoltage
        self.maxVoltage = maxVoltage
        self.alertsEnabled = alertsEnabled
    }
}

struct UPSDisplayData: Identifiable {
    let id: UUID
    let name: String
    let entityID: String
    let state: HASensor?
    let minVoltage: Double
    let maxVoltage: Double

    var voltageValue: Double? {
        guard let stateStr = state?.state, let value = Double(stateStr) else { return nil }
        return value
    }

    var unit: String {
        state?.attributes.unitOfMeasurement ?? "V"
    }

    var isOutOfRange: Bool {
        guard let value = voltageValue else { return false }
        return value < minVoltage || value > maxVoltage
    }
}

struct VoltageSample: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let value: Double

    init(timestamp: Date = Date(), value: Double) {
        self.id = UUID()
        self.timestamp = timestamp
        self.value = value
    }
}

struct RoomDisplayData: Identifiable {
    let id: String
    let name: String
    let tempID: String
    let humidityID: String
    var tempState: HASensor?
    var humidityState: HASensor?

    init(id: String, name: String, tempID: String, humidityID: String, tempState: HASensor? = nil, humidityState: HASensor? = nil) {
        self.id = id
        self.name = name
        self.tempID = tempID
        self.humidityID = humidityID
        self.tempState = tempState
        self.humidityState = humidityState
    }
}

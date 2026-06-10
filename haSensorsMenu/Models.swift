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

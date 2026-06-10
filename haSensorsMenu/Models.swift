import Foundation

struct RoomConfig: Identifiable, Codable, Sendable {
    var id: UUID = UUID()
    var name: String
    var tempID: String
    var humidityID: String
}

struct HASensor: Codable, Sendable {
    let state: String
    let attributes: Attributes
    
    struct Attributes: Codable, Sendable {
        let unitOfMeasurement: String?
        let friendlyName: String?
        
        enum CodingKeys: String, CodingKey {
            case unitOfMeasurement = "unit_of_measurement"
            case friendlyName = "friendly_name"
        }
    }
}

struct RoomDisplayData: Identifiable, Sendable {
    let id: String
    let name: String
    let tempID: String
    let humidityID: String
    var tempState: HASensor?
    var humidityState: HASensor?
}

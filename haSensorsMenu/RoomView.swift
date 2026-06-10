import SwiftUI

struct RoomView: View {
    let room: RoomDisplayData

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(room.name)
                .font(.headline)
                .foregroundColor(.primary)

            HStack(spacing: 0) {
                Image(systemName: "thermometer")
                    .foregroundColor(.orange)
                    .frame(width: 20)
                Text(L10n("temperature"))
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(width: 100, alignment: .leading)
                Spacer()
                Text(room.tempState?.state ?? "--")
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.semibold)
                    .frame(width: 60, alignment: .trailing)
                    .monospacedDigit()
                Text("°C")
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(width: 25, alignment: .center)
            }

            HStack(spacing: 0) {
                Image(systemName: "drop.fill")
                    .foregroundColor(.blue)
                    .frame(width: 20)
                Text(L10n("humidity"))
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(width: 100, alignment: .leading)
                Spacer()
                Text(room.humidityState?.state ?? "--")
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.semibold)
                    .frame(width: 60, alignment: .trailing)
                    .monospacedDigit()
                Text("%")
                    .font(.system(.body, design: .monospaced))
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(width: 25, alignment: .center)
            }
        }
        .padding(.vertical, 6)
    }
}

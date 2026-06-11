import SwiftUI

struct SwitchRowView: View {
    let switchData: HASwitchDisplayData
    let store: HASensorStore

    var body: some View {
        Button(action: {
            Task { await store.toggleSwitch(entityID: switchData.entityID) }
        }) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(switchData.isOn ? .yellow : .secondary)
                    .frame(width: 20)

                Text(switchData.name)
                    .font(.system(size: 14, weight: .medium))

                Spacer()

                Circle()
                    .fill(switchData.isOn ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 11, height: 11)
                    .overlay(
                        Circle()
                            .stroke(switchData.isOn ? Color.green.opacity(0.5) : Color.clear, lineWidth: 3)
                    )
            }
        }
        .buttonStyle(.plain)
        .padding(.vertical, 2)
    }

    var iconName: String {
        switchData.domain == "light" ? "lightbulb.fill" : "powerplug.fill"
    }
}

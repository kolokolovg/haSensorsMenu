import SwiftUI

struct AlertHistoryView: View {
    @ObservedObject var historyManager: VoltageHistoryManager
    @State private var showClearConfirmation = false

    var body: some View {
        VStack(spacing: 0) {
            Text(L10n("alert_history_title"))
                .font(.headline)
                .padding()

            if historyManager.alertHistory.isEmpty {
                Spacer()
                Text(L10n("no_alerts"))
                    .foregroundColor(.secondary)
                Spacer()
            } else {
                List {
                    ForEach(historyManager.alertHistory.sorted(by: { $0.timestamp > $1.timestamp })) { event in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(event.isBelowMin ? Color.red : Color.orange)
                                .frame(width: 8, height: 8)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(event.timestamp, style: .time)
                                    .font(.system(.caption, design: .monospaced))
                                    .foregroundColor(.secondary)
                                Text(event.timestamp, style: .date)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                Text(String(format: "%.1f %@", event.voltage, event.unit))
                                    .font(.system(.body, design: .monospaced))
                                    .foregroundColor(.red)
                                Text(L10n(event.isBelowMin ? "alert_below_min" : "alert_above_max"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }
                .listStyle(.plain)

                Divider()

                Button(role: .destructive) {
                    showClearConfirmation = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text(L10n("clear_history"))
                    }
                }
                .buttonStyle(.plain)
                .padding()
                .confirmationDialog(L10n("clear_history"), isPresented: $showClearConfirmation) {
                    Button(L10n("clear_history"), role: .destructive) {
                        historyManager.clearAlerts()
                    }
                    Button(L10n("cancel"), role: .cancel) {}
                } message: {
                    Text(L10n("clear_history_confirm"))
                }
            }
        }
        .frame(width: 360, height: 300)
    }
}

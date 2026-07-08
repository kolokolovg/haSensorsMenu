import SwiftUI
import Charts

struct VoltageGraphView: View {
    let samples: [VoltageSample]
    let minVoltage: Double
    let maxVoltage: Double
    let name: String
    let unit: String
    let historyManager: VoltageHistoryManager?

    private var yDomain: ClosedRange<Double> {
        let center = (minVoltage + maxVoltage) / 2
        let halfRange = (maxVoltage - minVoltage) / 2
        let padding = halfRange * 0.5
        return (center - halfRange - padding)...(center + halfRange + padding)
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(L10n("voltage_history"))
                .font(.system(size: 14, weight: .semibold))

            if samples.isEmpty {
                Text(L10n("no_voltage_data"))
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                Chart {
                    ForEach(samples, id: \.id) { sample in
                        LineMark(
                            x: .value("Time", sample.timestamp),
                            y: .value("Voltage", sample.value)
                        )
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .foregroundStyle(Color.blue)
                    }

                    RuleMark(y: .value("Min", minVoltage))
                        .foregroundStyle(.orange)
                        .lineStyle(StrokeStyle(dash: [4, 2]))

                    RuleMark(y: .value("Max", maxVoltage))
                        .foregroundStyle(.orange)
                        .lineStyle(StrokeStyle(dash: [4, 2]))
                }
                .chartYScale(domain: yDomain)
                .chartPlotStyle { plotArea in
                    plotArea
                        .background(Color.gray.opacity(0.08))
                        .cornerRadius(6)
                }
                .chartYAxis {
                    AxisMarks(values: .stride(by: 10)) { value in
                        AxisGridLine()
                            .foregroundStyle(Color.gray.opacity(0.15))
                        AxisValueLabel()
                            .foregroundStyle(Color.secondary)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .minute, count: 10)) { value in
                        AxisValueLabel(format: .dateTime.hour().minute())
                            .foregroundStyle(Color.secondary)
                    }
                }
                .frame(height: 200)
            }

            HStack {
                HStack(spacing: 4) {
                    Text(L10n("voltage_range"))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                    Text("\(Int(minVoltage))–\(Int(maxVoltage)) \(unit)")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                        .monospacedDigit()
                }
                Spacer()
                Text(samples.last.map { String(format: "%.1f \(unit)", $0.value) } ?? "--")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }

            if let historyManager = historyManager {
                Divider()

                Button {
                    AlertHistoryWindowManager.shared.open(historyManager: historyManager)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 14, weight: .semibold))
                        Text(L10n("alert_history"))
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .frame(width: 320)
    }
}

import SwiftUI
import Charts

struct VoltageGraphView: View {
    let samples: [VoltageSample]
    let minVoltage: Double
    let maxVoltage: Double
    let name: String
    let unit: String

    private var yDomain: ClosedRange<Double> {
        let center = (minVoltage + maxVoltage) / 2
        let halfRange = (maxVoltage - minVoltage) / 2
        let padding = halfRange * 0.5
        return (center - halfRange - padding)...(center + halfRange + padding)
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(L10n("voltage_history"))
                .font(.headline)

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
                    }
                    .foregroundStyle(by: .value("Type", "Voltage"))

                    RuleMark(y: .value("Min", minVoltage))
                        .foregroundStyle(.orange)
                        .lineStyle(StrokeStyle(dash: [4, 2]))

                    RuleMark(y: .value("Max", maxVoltage))
                        .foregroundStyle(.orange)
                        .lineStyle(StrokeStyle(dash: [4, 2]))
                }
                .chartForegroundStyleScale(["Voltage": Color.blue])
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

            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                    Text(L10n("voltage_legend"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                HStack(spacing: 4) {
                    RoundedRectangle(cornerRadius: 1)
                        .fill(Color.orange)
                        .frame(width: 14, height: 3)
                    Text("\(Int(minVoltage))–\(Int(maxVoltage)) \(unit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(samples.last.map { String(format: "%.1f \(unit)", $0.value) } ?? "--")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
        }
        .padding()
        .frame(width: 320)
    }
}

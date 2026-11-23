import Charts
import SwiftUI

struct WorkoutDetailCharts: View {
    let details: WorkoutDetails
    let speedSplits: [SpeedSplit]
    let unit: UnitLength

    var body: some View {
        if !details.heartRate.isEmpty || details.averageHeartRate != nil ||
            details.peakHeartRate != nil || details.activeCalories != nil {
            Section {
                if let peak = details.peakHeartRate {
                    WorkoutDetailValueRow("Peak Heart Rate", value: bpm(peak))
                }
                if let calories = details.activeCalories {
                    let value = Measurement(value: calories, unit: UnitEnergy.kilocalories)
                    WorkoutDetailValueRow("Active Calories", value: value.formatted(.measurement(
                        width: .abbreviated, usage: .asProvided, numberFormatStyle: .number.precision(.fractionLength(0))
                    )))
                }
                if let average = details.averageHeartRate {
                    WorkoutDetailValueRow("Average Heart Rate", value: bpm(average))
                }
                if !details.heartRate.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Heart Rate Over Time")
                            .workoutChartTitleStyle()

                        Chart(details.heartRate) { reading in
                            LineMark(x: .value("Time", reading.time), y: .value("BPM", reading.beatsPerMinute))
                            if details.heartRate.count == 1 {
                                PointMark(x: .value("Time", reading.time), y: .value("BPM", reading.beatsPerMinute))
                            }
                        }
                        .foregroundStyle(Color.Theme.primary)
                        .chartXAxisLabel("Time")
                        .chartYAxisLabel("BPM")
                        .frame(minHeight: 180)
                    }
                    .listRowBackground(Color.Theme.appBackground)
                }
            } header: {
                Text("Effort")
                    .font(.system(.body, design: .rounded).weight(.bold))
                    .foregroundStyle(Color.Theme.accentSecondary)
            }
        }

        if !speedSplits.isEmpty {
            let isMiles = unit == .miles
            let splitName: LocalizedStringKey = isMiles ? "Mile" : "Kilometer"
            let speedUnit = unit.speedUnit

            VStack(alignment: .leading, spacing: 8) {
                Text(isMiles ? "Speed by Mile" : "Speed by Kilometer")
                    .workoutChartTitleStyle()

                Chart(speedSplits) { split in
                    let speed = split.speed(in: speedUnit)
                    LineMark(x: .value(splitName, split.index), y: .value("Average speed", speed.value))
                        .accessibilityHidden(true)
                    PointMark(x: .value(splitName, split.index), y: .value("Average speed", speed.value))
                        .accessibilityLabel(isMiles ? Text("Mile \(split.index)") : Text("Kilometer \(split.index)"))
                        .accessibilityValue(Text(speed.formatted(SpeedFormat.speedFormat())))
                }
                .foregroundStyle(Color.Theme.primary)
                .chartXAxis { AxisMarks(values: .automatic(desiredCount: 5)) }
                .chartXAxisLabel(splitName)
                .chartYAxisLabel("Average speed (\(speedUnit.symbol))")
                .frame(minHeight: 180)
            }
            .listRowBackground(Color.Theme.appBackground)
        }
    }

    private func bpm(_ value: Double) -> String {
        String(localized: "\(value.formatted(.number.precision(.fractionLength(0)))) bpm")
    }
}

private extension Text {
    func workoutChartTitleStyle() -> some View {
        font(.system(.body, design: .rounded).weight(.bold))
        .foregroundStyle(Color.Theme.accentSecondary)
    }
}

import Charts
import SwiftUI

struct WorkoutDetailCharts: View {
    let details: WorkoutDetails

    var body: some View {
        if !details.heartRate.isEmpty || details.averageHeartRate != nil ||
            details.peakHeartRate != nil || details.activeCalories != nil {
            Section("Effort") {
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
                        .foregroundStyle(Color.Theme.red)
                        .chartXAxisLabel("Time")
                        .chartYAxisLabel("BPM")
                        .frame(minHeight: 180)
                        .accessibilityLabel("Heart rate over time")
                    }
                }
            }
        }

        if !details.mileSpeeds.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Speed by Mile")
                    .workoutChartTitleStyle()

                Chart(details.mileSpeeds) { split in
                    LineMark(x: .value("Mile", split.mile), y: .value("Average speed", split.milesPerHour))
                        .accessibilityHidden(true)
                    PointMark(x: .value("Mile", split.mile), y: .value("Average speed", split.milesPerHour))
                        .accessibilityLabel(Text("Mile \(split.mile)"))
                        .accessibilityValue(Text("\(split.milesPerHour, format: .number.precision(.fractionLength(1))) mph"))
                }
                .foregroundStyle(Color.Theme.teal)
                .chartXAxis { AxisMarks(values: .automatic(desiredCount: 5)) }
                .chartXAxisLabel("Mile")
                .chartYAxisLabel("Average speed (mph)")
                .frame(minHeight: 180)
                .accessibilityLabel("Average speed by completed mile")
            }
        }
    }

    private func bpm(_ value: Double) -> String {
        String(localized: "\(value.formatted(.number.precision(.fractionLength(0)))) bpm")
    }
}

private extension Text {
    func workoutChartTitleStyle() -> some View {
        font(.headline)
            .accessibilityAddTraits(.isHeader)
    }
}

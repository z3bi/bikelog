import Foundation
import OSLog

struct WorkoutPeriodTotal: Identifiable {
    private static let logger = Logger(subsystem: "BikeLog", category: "Workout totals")

    let startDate: Date
    let count: Int
    let miles: Double

    var id: Date { startDate }

    var formattedMiles: String {
        Self.formatMiles(miles)
    }

    static func formatMiles(_ miles: Double, width: LengthFormat.UnitWidth = .abbreviated) -> String {
        Measurement(value: miles, unit: UnitLength.miles)
            .formatted(LengthFormat.lengthFormat(fractions: 1, width: width))
    }

    static func yearly(_ workouts: [Workout], calendar: Calendar) -> [Self] {
        summarize(workouts, by: .year, calendar: calendar)
    }

    static func monthly(_ workouts: [Workout], in year: Date, calendar: Calendar) -> [Self] {
        let workoutsInYear = workouts.filter {
            calendar.isDate($0.startDate, equalTo: year, toGranularity: .year)
        }
        return summarize(workoutsInYear, by: .month, calendar: calendar)
    }

    static func workouts(_ workouts: [Workout], in interval: DateInterval) -> [Workout] {
        workouts.filter { $0.startDate >= interval.start && $0.startDate < interval.end }
    }

    static func distance(of workouts: [Workout], in unit: UnitLength) -> Measurement<UnitLength> {
        let distance = workouts.reduce(0.0) { $0 + $1.distance.converted(to: unit).value }
        return Measurement(value: distance, unit: unit)
    }

    private static func summarize(_ workouts: [Workout], by component: Calendar.Component, calendar: Calendar) -> [Self] {
        let groups = Dictionary(grouping: workouts) { workout in
            calendar.dateInterval(of: component, for: workout.startDate)?.start
        }
        return groups.compactMap { start, periodWorkouts -> Self? in
            guard let start else {
                logger.error("Could not determine the calendar period for \(periodWorkouts.count) workouts.")
                return nil
            }
            return Self(startDate: start,
                        count: periodWorkouts.count,
                        miles: distance(of: periodWorkouts, in: .miles).value)
        }
        .sorted { $0.startDate > $1.startDate }
    }
}

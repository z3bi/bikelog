import Foundation
import OSLog

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "BikeLog"

    static let healthKit = Logger(subsystem: subsystem, category: "HealthKit")
    static let workouts = Logger(subsystem: subsystem, category: "Workouts")
    static let workoutCache = Logger(subsystem: subsystem, category: "Workout cache")
    static let workoutDetail = Logger(subsystem: subsystem, category: "Workout detail")
    static let workoutTotals = Logger(subsystem: subsystem, category: "Workout totals")
}

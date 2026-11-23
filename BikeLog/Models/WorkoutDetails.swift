import CoreLocation
import Foundation

struct WorkoutDetails: Sendable {
    struct HeartRateReading: Identifiable, Sendable {
        let id: UUID
        let time: Date
        let beatsPerMinute: Double
    }

    var route: [[CLLocationCoordinate2D]] = []
    var heartRate: [HeartRateReading] = []
    var averageHeartRate: Double?
    var peakHeartRate: Double?
    var activeCalories: Double?
    var elevationGain: Measurement<UnitLength>?
    var distanceSamples: [SpeedSplit.DistanceSample] = []
    var hasPartialFailure = false
}
